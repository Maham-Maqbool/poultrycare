import 'package:flutter/material.dart';
import '../../../data/mock/mock_scans_data.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../../data/repositories/flock_repository.dart';

/// DashboardController aggregates farm-wide metrics, recent scans,
/// and disease outbreak warnings.
class DashboardController extends ChangeNotifier {
  final DiagnosticRepository _diagRepo;
  final FlockRepository _flockRepo;

  bool _isLoading = false;
  List<DiagnosticRecord> _recentRecords = [];
  int _totalScans = 0;
  int _healthyScans = 0;
  int _flockCount = 0;
  int _severeAlerts = 0;

  DashboardController(this._diagRepo, this._flockRepo) {
    loadDashboard();
  }

  bool get isLoading => _isLoading;
  List<DiagnosticRecord> get recentRecords => _recentRecords;
  int get totalScans => _totalScans;
  int get flockCount => _flockCount;
  int get severeAlerts => _severeAlerts;

  double? get healthyRate {
    if (_totalScans == 0) return null;
    return (_healthyScans / _totalScans * 100).clamp(0.0, 100.0);
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    final allScans = await _diagRepo.getAllRecords();
    final allFlocks = await _flockRepo.getFlocks();

    _totalScans = allScans.length;
    _healthyScans = allScans.where((r) => r.prediction.predictedClass == 'healthy').length;
    _severeAlerts = allScans.where((r) => r.prediction.severity == 'severe').length;
    _flockCount = allFlocks.length;
    _recentRecords = allScans.take(4).toList();

    _isLoading = false;
    notifyListeners();
  }
}
