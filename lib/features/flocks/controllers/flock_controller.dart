import 'package:flutter/material.dart';
import '../../../data/models/flock_model.dart';
import '../../../data/repositories/flock_repository.dart';

/// FlockController manages flock lists, CRUD operations,
/// and shed health metrics.
class FlockController extends ChangeNotifier {
  final FlockRepository _repo;

  bool _isLoading = false;
  List<FlockModel> _flocks = [];
  String? _errorMessage;

  FlockController(this._repo) {
    loadFlocks();
  }

  bool get isLoading => _isLoading;
  List<FlockModel> get flocks => _flocks;
  String? get errorMessage => _errorMessage;

  Future<void> loadFlocks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _flocks = await _repo.getFlocks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addFlock({
    required String name,
    int? birdCount,
    String? breed,
    String? notes,
  }) async {
    try {
      await _repo.addFlock(
        name: name,
        birdCount: birdCount,
        breed: breed,
        notes: notes,
      );
      await loadFlocks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteFlock(String id) async {
    await _repo.deleteFlock(id);
    await loadFlocks();
  }
}
