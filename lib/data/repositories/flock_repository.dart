import '../models/flock_model.dart';
import '../mock/mock_flocks_data.dart';

/// FlockRepository manages farmer flocks/sheds in memory
/// enforcing the Chapter 5 limit of 20 flocks per user.
class FlockRepository {
  final List<FlockModel> _flocks = List.from(mockFlocksData);

  Future<List<FlockModel>> getFlocks() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_flocks);
  }

  Future<FlockModel?> getFlockById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _flocks.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<FlockModel> addFlock({
    required String name,
    int? birdCount,
    String? breed,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_flocks.length >= 20) {
      throw Exception('Maximum limit of 20 flocks reached per farm.');
    }
    final newFlock = FlockModel(
      id: 'flock-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr-001',
      name: name,
      birdCount: birdCount,
      breed: breed,
      notes: notes,
      createdAt: DateTime.now(),
      activeDiseaseCount: 0,
    );
    _flocks.insert(0, newFlock);
    return newFlock;
  }

  Future<FlockModel> updateFlock(FlockModel updated) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _flocks.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      _flocks[index] = updated;
      return updated;
    }
    throw Exception('Flock not found');
  }

  Future<void> deleteFlock(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _flocks.removeWhere((f) => f.id == id);
  }
}
