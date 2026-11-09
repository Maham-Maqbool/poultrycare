import '../models/disease_model.dart';
import '../models/treatment_model.dart';
import '../mock/mock_diseases_data.dart';
import '../mock/mock_treatments_data.dart';

/// DiseaseRepository manages disease encyclopedia and treatment lookups
/// reflecting enterprise poultry health specifications.
class DiseaseRepository {
  Future<List<DiseaseModel>> getAllDiseases() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = List<DiseaseModel>.from(mockDiseasesData);
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  static String _normalizeCode(String code) {
    final lower = code.toLowerCase().trim();
    if (lower.contains('newcastle') || lower == 'ncd') return 'ncd';
    return lower;
  }

  Future<DiseaseModel?> getDiseaseByCode(String code) async {
    final normalized = _normalizeCode(code);
    try {
      return mockDiseasesData.firstWhere(
        (d) => _normalizeCode(d.code) == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  Future<TreatmentModel?> getTreatment(String diseaseCode, String severity) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final normalizedDisease = _normalizeCode(diseaseCode);
    final normalizedSeverity = severity.toLowerCase().trim();
    try {
      return mockTreatmentsData.firstWhere(
        (t) =>
            _normalizeCode(t.diseaseCode) == normalizedDisease &&
            t.severity.toLowerCase() == normalizedSeverity,
      );
    } catch (_) {
      // Return first treatment for this disease as fallback
      try {
        return mockTreatmentsData.firstWhere(
          (t) => _normalizeCode(t.diseaseCode) == normalizedDisease,
        );
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<TreatmentModel>> getAllTreatments() async {
    return List.unmodifiable(mockTreatmentsData);
  }
}
