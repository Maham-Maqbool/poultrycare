import '../models/flock_model.dart';
import '../../services/database_service.dart';
import '../../services/session_service.dart';

/// FlockRepository manages farmer flocks/sheds with local SQLite persistence
/// via DatabaseService, enforcing the commercial tier limit of 20 flocks per user.
/// Fresh installs start with an empty list.
class FlockRepository {
  final DatabaseService _db = DatabaseService.instance;
  final SessionService _session = SessionService.instance;

  Future<List<FlockModel>> getFlocks({String? userId}) async {
    final effectiveUserId = userId ?? await _session.getUserId();
    return await _db.fetchAllFlocks(userId: effectiveUserId);
  }

  Future<FlockModel?> getFlockById(String id) async {
    return await _db.getFlockById(id);
  }

  Future<FlockModel> addFlock({
    required String name,
    int? birdCount,
    String? breed,
    String? notes,
    String? userId,
  }) async {
    final effectiveUserId = userId ?? await _session.getUserId();
    final currentFlocks = await _db.fetchAllFlocks(userId: effectiveUserId);
    if (currentFlocks.length >= 20) {
      throw Exception('Maximum limit of 20 flocks reached per farm.');
    }
    final newFlock = FlockModel(
      id: 'flock-${DateTime.now().millisecondsSinceEpoch}',
      userId: effectiveUserId,
      name: name,
      birdCount: birdCount,
      breed: breed,
      notes: notes,
      createdAt: DateTime.now(),
      activeDiseaseCount: 0,
    );
    await _db.insertFlock(newFlock);
    return newFlock;
  }

  Future<FlockModel> updateFlock(FlockModel updated) async {
    return await _db.updateFlock(updated);
  }

  Future<void> deleteFlock(String id) async {
    await _db.deleteFlock(id);
  }
}
