import '../models/disease_model.dart';
import '../models/treatment_model.dart';
import '../mock/mock_diseases_data.dart';
import '../mock/mock_treatments_data.dart';

/// DiseaseRepository manages disease encyclopedia and treatment lookups
/// reflecting Chapter 5 query specifications.
class DiseaseRepository {
  Future<List<DiseaseModel>> getAllDiseases() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = List<DiseaseModel>.from(mockDiseasesData);
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<DiseaseModel?> getDiseaseByCode(String code) async {
    try {
      return mockDiseasesData.firstWhere(
        (d) => d.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<TreatmentModel?> getTreatment(String diseaseCode, String severity) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockTreatmentsData.firstWhere(
        (t) =>
            t.diseaseCode.toLowerCase() == diseaseCode.toLowerCase() &&
            t.severity.toLowerCase() == severity.toLowerCase(),
      );
    } catch (_) {
      // Return first treatment for this disease as fallback
      try {
        return mockTreatmentsData.firstWhere(
          (t) => t.diseaseCode.toLowerCase() == diseaseCode.toLowerCase(),
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
