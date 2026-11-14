import '../../data/models/diagnostic_record.dart';
import '../../data/models/flock_model.dart';

/// FlockStatusHelper provides a single source of truth for evaluating
/// whether a flock or shed is considered 'Active Risk' or 'Healthy'.
class FlockStatusHelper {
  /// Evaluates whether a flock currently has active risk.
  /// A flock is 'Active Risk' if:
  /// 1. Its persisted activeDiseaseCount is > 0, OR
  /// 2. Any scan associated with the flock in the last 30 days is Severe or Moderate.
  /// Otherwise, returns false ('Healthy').
  static bool isAtRisk({
    required FlockModel flock,
    List<DiagnosticRecord>? records,
  }) {
    if (flock.activeDiseaseCount > 0) {
      return true;
    }

    if (records != null && records.isNotEmpty) {
      return isAtRiskFromRecords(records, flockId: flock.id);
    }

    return false;
  }

  /// Helper to evaluate directly from a list of records for a specific flock ID.
  /// Consistent with DatabaseService: disease != 'healthy' and (severe or moderate) within 30 days.
  static bool isAtRiskFromRecords(List<DiagnosticRecord> records, {String? flockId}) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return records.any((r) {
      if (flockId != null && r.scan.flockId != flockId) return false;
      if (r.scan.createdAt.isBefore(thirtyDaysAgo)) return false;

      final disease = r.prediction.predictedClass?.toLowerCase() ?? 'healthy';
      final severity = r.prediction.severity?.toLowerCase() ?? 'mild';

      return disease != 'healthy' && (severity == 'severe' || severity == 'moderate');
    });
  }
}
