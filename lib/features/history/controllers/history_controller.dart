import 'package:flutter/material.dart';
import '../../../core/utils/flock_status_helper.dart';
import '../../../data/models/diagnostic_record.dart';
import '../../../data/repositories/diagnostic_repository.dart';

/// HistoryController manages search, category filtering,
/// and pagination of diagnostic scan records.
class HistoryController extends ChangeNotifier {
  final DiagnosticRepository _repo;

  bool _isLoading = false;
  List<DiagnosticRecord> _records = [];
  String _selectedDiseaseFilter = 'all';
  String _selectedSeverityFilter = 'all';
  String _searchQuery = '';

  HistoryController(this._repo) {
    loadRecords();
  }

  bool get isLoading => _isLoading;
  String get selectedDiseaseFilter => _selectedDiseaseFilter;
  String get selectedSeverityFilter => _selectedSeverityFilter;
  String get searchQuery => _searchQuery;
  List<DiagnosticRecord> get allRecords => _records;

  /// Computes whether a flock currently has active risk based on scans in the last 30 days.
  bool isFlockAtRisk(String flockId) {
    return FlockStatusHelper.isAtRiskFromRecords(_records, flockId: flockId);
  }

  List<DiagnosticRecord> get filteredRecords {
    var list = _records;

    if (_selectedDiseaseFilter != 'all') {
      list = list.where((r) =>
        r.prediction.predictedClass?.toLowerCase() == _selectedDiseaseFilter.toLowerCase()
      ).toList();
    }

    if (_selectedSeverityFilter != 'all') {
      list = list.where((r) =>
        r.prediction.severity?.toLowerCase() == _selectedSeverityFilter.toLowerCase()
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        (r.prediction.predictedClass ?? '').toLowerCase().contains(q) ||
        r.scan.id.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await _repo.getAllRecords();
    _isLoading = false;
    notifyListeners();
  }

  /// Deletes a scan record from the local SQLite database.
  Future<void> deleteRecord(String scanId) async {
    _isLoading = true;
    notifyListeners();

    await _repo.deleteRecord(scanId);
    _records = await _repo.getAllRecords();

    _isLoading = false;
    notifyListeners();
  }

  /// Clears all scan history from the local SQLite database.
  Future<void> clearAllHistory() async {
    _isLoading = true;
    notifyListeners();

    await _repo.clearAllHistory();
    _records = [];

    _isLoading = false;
    notifyListeners();
  }

  void setDiseaseFilter(String filter) {
    _selectedDiseaseFilter = filter;
    notifyListeners();
  }

  void setSeverityFilter(String filter) {
    _selectedSeverityFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
