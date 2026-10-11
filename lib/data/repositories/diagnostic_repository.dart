import '../models/scan_model.dart';
import '../models/prediction_model.dart';
import '../models/feedback_model.dart';
import '../mock/mock_scans_data.dart';

/// DiagnosticRepository provides the simulated MobileNetV3 classifier
/// combined with the explainable clinical triage rules engine.
class DiagnosticRepository {
  final List<DiagnosticRecord> _records = List.from(mockDiagnosticRecords);

  Future<List<DiagnosticRecord>> getAllRecords({
    String? filterDisease,
    String? filterSeverity,
    String? flockId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = _records;

    if (flockId != null) {
      results = results.where((r) => r.scan.flockId == flockId).toList();
    }
    if (filterDisease != null && filterDisease != 'all') {
      results = results
          .where((r) =>
              r.prediction.predictedClass?.toLowerCase() ==
              filterDisease.toLowerCase())
          .toList();
    }
    if (filterSeverity != null && filterSeverity != 'all') {
      results = results
          .where((r) =>
              r.prediction.severity?.toLowerCase() ==
              filterSeverity.toLowerCase())
          .toList();
    }
    return List.unmodifiable(results);
  }

  Future<DiagnosticRecord?> getRecordById(String scanId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _records.firstWhere((r) => r.scan.id == scanId);
    } catch (_) {
      return null;
    }
  }

  /// Executes image validation, deep learning classification,
  /// and clinical flock triage rules evaluation.
  Future<DiagnosticRecord> runDiagnosis({
    required String imagePath,
    String? flockId,
    required Map<String, dynamic> flockSignals,
    String? forcedDisease, // for testing specific disease categories
  }) async {
    // 1. Simulate image preprocessing and normalization latency
    await Future.delayed(const Duration(milliseconds: 300));
    final preprocessMs = 18.5;
    final decodeMs = 14.0;

    // 2. Determine target disease class
    final String predictedClass = (forcedDisease ?? _detectClassFromImage(imagePath)).toLowerCase();

    // 3. Simulate inference latency and confidence metrics
    await Future.delayed(const Duration(milliseconds: 400));
    final inferenceMs = 82.0;

    double confidence;
    Map<String, double> probabilities;

    switch (predictedClass) {
      case 'ncd':
        confidence = 0.975;
        probabilities = {
          'ncd': 0.975,
          'coccidiosis': 0.015,
          'salmonella': 0.007,
          'healthy': 0.003,
        };
        break;
      case 'coccidiosis':
        confidence = 0.938;
        probabilities = {
          'coccidiosis': 0.938,
          'salmonella': 0.042,
          'healthy': 0.014,
          'ncd': 0.006,
        };
        break;
      case 'salmonella':
        confidence = 0.912;
        probabilities = {
          'salmonella': 0.912,
          'coccidiosis': 0.055,
          'healthy': 0.021,
          'ncd': 0.012,
        };
        break;
      case 'healthy':
      default:
        confidence = 0.965;
        probabilities = {
          'healthy': 0.965,
          'salmonella': 0.018,
          'coccidiosis': 0.012,
          'ncd': 0.005,
        };
        break;
    }

    // 4. Clinical Rules Engine: Derive Severity and Urgency from baseline + flock signals
    String derivedSeverity = 'mild';
    String derivedUrgency = 'monitor';
    final List<String> rulesFired = [];

    final String lethargy = (flockSignals['lethargy'] ?? 'None').toString();
    final String intakeDrop = (flockSignals['intakeDrop'] ?? 'Normal').toString();
    final String suddenMortality = (flockSignals['suddenMortality'] ?? 'None in 24h').toString();

    if (predictedClass == 'healthy') {
      derivedSeverity = 'mild';
      derivedUrgency = 'monitor';
      rulesFired.add('baseline_healthy_droppings');
      rulesFired.add('routine_monitoring_continue');
    } else if (predictedClass == 'ncd') {
      // Newcastle Disease is inherently severe and reportable
      derivedSeverity = 'severe';
      derivedUrgency = 'vet_now';
      rulesFired.add('pathogen_ncd_inherently_severe');
      rulesFired.add('notifiable_alert_blocking_active');
      rulesFired.add('vet_now_immediate_dispatch');
    } else if (predictedClass == 'coccidiosis') {
      derivedSeverity = 'moderate';
      derivedUrgency = 'treat_today';
      rulesFired.add('baseline_coccidiosis_moderate');
      rulesFired.add('anticoccidial_regimen_indicated');
    } else if (predictedClass == 'salmonella') {
      derivedSeverity = 'moderate';
      derivedUrgency = 'treat_today';
      rulesFired.add('baseline_salmonella_moderate');
      rulesFired.add('systemic_enteritis_protocol');
    }

    // Evaluate Flock Signals Escalations
    if (suddenMortality.contains('Multiple') || suddenMortality.contains('died')) {
      derivedSeverity = 'severe';
      derivedUrgency = 'vet_now';
      rulesFired.add('mortality_escalation_severe');
    } else if (suddenMortality.contains('1 to 2')) {
      if (derivedSeverity == 'mild') derivedSeverity = 'moderate';
      if (derivedUrgency == 'monitor') derivedUrgency = 'treat_today';
      rulesFired.add('mortality_early_warning_escalation');
    }

    if (intakeDrop.contains('Severely') && derivedSeverity != 'severe') {
      derivedSeverity = 'moderate';
      if (derivedUrgency == 'monitor') derivedUrgency = 'treat_today';
      rulesFired.add('feed_intake_drop_escalation');
    }

    if (lethargy.contains('Over 10%') && derivedSeverity != 'severe') {
      derivedSeverity = 'moderate';
      rulesFired.add('flock_wide_lethargy_escalation');
    }

    final now = DateTime.now();
    final scanId = 'scn-${now.millisecondsSinceEpoch}';

    final scan = ScanModel(
      id: scanId,
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: flockId ?? 'flock-101',
      idempotencyKey: 'idemp-${now.millisecondsSinceEpoch}',
      imagePath: imagePath,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: now,
    );

    final prediction = PredictionModel(
      id: 'prd-${now.millisecondsSinceEpoch}',
      scanId: scanId,
      modelVersionId: 'mod-v120',
      predictedClass: predictedClass,
      probabilities: probabilities,
      calibratedConfidence: confidence,
      certainty: 'confident',
      conformalSet: [predictedClass],
      abstained: false,
      severity: derivedSeverity,
      urgency: derivedUrgency,
      triageRules: rulesFired,
      flockSignals: flockSignals,
      decodeMs: decodeMs,
      preprocessMs: preprocessMs,
      inferenceMs: inferenceMs,
      totalMs: decodeMs + preprocessMs + inferenceMs,
      createdAt: now,
    );

    final record = DiagnosticRecord(scan: scan, prediction: prediction);
    _records.insert(0, record);
    return record;
  }

  Future<void> submitFeedback(
    String scanId, {
    bool? wasHelpful,
    String? actualClass,
    bool confirmedByVet = false,
    String? comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _records.indexWhere((r) => r.scan.id == scanId);
    if (index != -1) {
      final old = _records[index];
      final newFeedback = FeedbackModel(
        id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
        scanId: scanId,
        wasHelpful: wasHelpful,
        actualClass: actualClass,
        confirmedByVet: confirmedByVet,
        comment: comment,
        createdAt: DateTime.now(),
      );
      _records[index] = DiagnosticRecord(
        scan: old.scan,
        prediction: old.prediction,
        feedback: newFeedback,
      );
    }
  }

  String _detectClassFromImage(String path) {
    final lower = path.toLowerCase();
    if (lower.contains('newcastle') || lower.contains('ncd')) return 'ncd';
    if (lower.contains('salmonella')) return 'salmonella';
    if (lower.contains('coccidiosis')) return 'coccidiosis';
    if (lower.contains('healthy')) return 'healthy';
    return 'coccidiosis';
  }
}
