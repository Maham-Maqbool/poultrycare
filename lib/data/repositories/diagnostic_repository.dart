import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../../services/tflite_service.dart';
import '../models/detection_history_record.dart';
import '../models/diagnostic_record.dart';
import '../models/scan_model.dart';
import '../models/prediction_model.dart';
import '../models/feedback_model.dart';

/// DiagnosticRepository provides 100% on-device TFLite inference,
/// standalone SQLite history persistence, and clinical flock triage rules.
class DiagnosticRepository {
  final List<DiagnosticRecord> _records = [];
  final DatabaseService _dbService = DatabaseService.instance;
  final TFLiteService _tfliteService;

  DiagnosticRepository({TFLiteService? tfliteService})
      : _tfliteService = tfliteService ?? TFLiteService();

  /// Converts a database row to a high-level domain DiagnosticRecord.
  DiagnosticRecord _mapDbRecordToDiagnosticRecord(DetectionHistoryRecord dbRec) {
    final scan = ScanModel(
      id: 'scn-db-${dbRec.id ?? dbRec.timestamp.millisecondsSinceEpoch}',
      userId: null,
      deviceId: '',
      flockId: dbRec.flockId,
      idempotencyKey: 'idemp-db-${dbRec.id}',
      imagePath: dbRec.imagePath,
      locale: 'en',
      createdAt: dbRec.timestamp,
    );

    final String rawDiseaseCode = dbRec.diseaseName.toLowerCase().trim();
    final String diseaseCode = (rawDiseaseCode == 'ncd') ? 'newcastle' : rawDiseaseCode;
    final String rawSev = dbRec.severityLevel.toLowerCase().trim();
    final String severity = (rawSev == 'healthy') ? 'mild' : rawSev;
    final String urgency = (diseaseCode == 'healthy')
        ? 'monitor'
        : ((severity == 'severe' || diseaseCode == 'newcastle')
            ? 'vet_now'
            : 'treat_today');

    final String derivedCertainty = dbRec.confidenceScore >= 0.95
        ? 'high'
        : (dbRec.confidenceScore >= 0.80 ? 'moderate' : 'uncertain');

    Map<String, dynamic> signals = {
      'lethargy': 'None',
      'intakeDrop': 'Normal',
      'suddenMortality': 'None in 24h'
    };
    if (dbRec.notes != null && dbRec.notes!.startsWith('{')) {
      try {
        final decoded = jsonDecode(dbRec.notes!);
        if (decoded is Map<String, dynamic>) {
          signals = decoded;
        } else if (decoded is Map) {
          signals = decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }

    final prediction = PredictionModel(
      id: 'prd-db-${dbRec.id ?? dbRec.timestamp.millisecondsSinceEpoch}',
      scanId: scan.id,
      modelVersionId: 'PC-VisionAI-v2.4',
      predictedClass: diseaseCode,
      probabilities: dbRec.probabilities ??
          {diseaseCode: dbRec.confidenceScore},
      calibratedConfidence: dbRec.confidenceScore,
      certainty: derivedCertainty,
      conformalSet: [diseaseCode],
      abstained: false,
      severity: severity,
      urgency: urgency,
      triageRules: const [],
      flockSignals: signals,
      createdAt: dbRec.timestamp,
    );

    return DiagnosticRecord(scan: scan, prediction: prediction);
  }

  /// Fetches all records dynamically from the local SQLite database.
  Future<List<DiagnosticRecord>> getAllRecords({
    String? filterDisease,
    String? filterSeverity,
    String? flockId,
  }) async {
    final savedDbRecords = await _dbService.fetchAllRecords();
    _records.clear();
    for (final dbRec in savedDbRecords) {
      _records.add(_mapDbRecordToDiagnosticRecord(dbRec));
    }

    var results = List<DiagnosticRecord>.from(_records);

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

  /// Fetches a single diagnostic record by its scan ID.
  Future<DiagnosticRecord?> getRecordById(String scanId) async {
    try {
      return _records.firstWhere((r) => r.scan.id == scanId);
    } catch (_) {
      final all = await getAllRecords();
      try {
        return all.firstWhere((r) => r.scan.id == scanId);
      } catch (_) {
        return null;
      }
    }
  }

  /// Deletes a specific diagnostic record from SQLite and local memory.
  Future<bool> deleteRecord(String scanId) async {
    if (scanId.startsWith('scn-db-')) {
      final dbId = int.tryParse(scanId.replaceFirst('scn-db-', ''));
      if (dbId != null) {
        await _dbService.deleteRecord(dbId);
      }
    } else {
      final savedDbRecords = await _dbService.fetchAllRecords();
      for (final rec in savedDbRecords) {
        if (rec.id != null &&
            (scanId.contains('${rec.id}') || rec.imagePath.contains(scanId))) {
          await _dbService.deleteRecord(rec.id!);
          break;
        }
      }
    }
    _records.removeWhere((r) => r.scan.id == scanId);
    return true;
  }

  /// Clears all historical scans from the SQLite database.
  Future<void> clearAllHistory() async {
    await _dbService.deleteAllRecords();
    _records.clear();
  }

  /// Executes image validation, on-device deep learning classification,
  /// clinical flock triage rules evaluation, and local SQLite persistence.
  Future<DiagnosticRecord> runDiagnosis({
    required String imagePath,
    String? flockId,
    required Map<String, dynamic> flockSignals,
  }) async {
    // 1. Run real on-device TFLite model inference
    TFLiteDiagnosisResult? tfliteResult;
    try {
      tfliteResult = await _tfliteService.diagnoseImage(imagePath);
    } catch (e) {
      debugPrint('[DiagnosticRepository] TFLite diagnosis exception: $e');
    }

    double? preprocessMs;
    double? decodeMs;
    double? inferenceMs;
    String predictedClass = 'healthy';
    double confidence = 0.95;
    Map<String, double> probabilities = {'healthy': 0.95};
    String derivedSeverity = 'healthy';
    String derivedUrgency = 'monitor';
    final List<String> rulesFired = [];
    String modelVersionId = 'PC-VisionAI-v2.4';

    if (tfliteResult != null) {
      final rawClass = tfliteResult.predictedClass.toLowerCase().trim();
      predictedClass = (rawClass == 'ncd') ? 'newcastle' : rawClass;
      confidence = tfliteResult.confidence;
      probabilities = tfliteResult.probabilities
          .map((k, v) => MapEntry(k.toLowerCase().trim(), v));
      derivedSeverity = tfliteResult.severity.toLowerCase().trim();
      preprocessMs = tfliteResult.preprocessMs;
      decodeMs = null;
      inferenceMs = tfliteResult.inferenceMs;
      modelVersionId = tfliteResult.modelName;
      rulesFired.add('tflite_ondevice_inference');
      rulesFired.add('ratio_severity_$derivedSeverity');
    } else {
      throw StateError('AI engine unavailable. Please restart the app.');
    }

    // 2. Evaluate Clinical Flock Triage Escalations
    final String lethargy = (flockSignals['lethargy'] ?? 'None').toString();
    final String intakeDrop =
        (flockSignals['intakeDrop'] ?? 'Normal').toString();
    final String suddenMortality =
        (flockSignals['suddenMortality'] ?? 'None in 24h').toString();

    if (predictedClass != 'healthy' && derivedSeverity != 'uncertain') {
      if (suddenMortality.contains('Multiple') ||
          suddenMortality.contains('died')) {
        derivedSeverity = 'severe';
        rulesFired.add('mortality_escalation_severe');
      } else if (suddenMortality.contains('1 to 2')) {
        if (derivedSeverity == 'mild') {
          derivedSeverity = 'moderate';
          rulesFired.add('mortality_early_warning_escalation');
        }
      }

      if (intakeDrop.contains('Severely') && derivedSeverity != 'severe') {
        derivedSeverity = 'moderate';
        rulesFired.add('feed_intake_drop_escalation');
      }

      if (lethargy.contains('Over 10%') && derivedSeverity != 'severe') {
        derivedSeverity = 'moderate';
        rulesFired.add('flock_wide_lethargy_escalation');
      }
    }

    // 3. Urgency mapping rule (do not change):
    // Uncertain -> RETAKE PHOTO;
    // Healthy -> MONITOR (green);
    // Mild/Moderate -> TREAT TODAY (orange);
    // Severe -> VET NOW (red);
    // Newcastle -> VET NOW.
    if (derivedSeverity == 'uncertain') {
      derivedUrgency = 'retake_photo';
      rulesFired.add('uncertain_low_confidence_retake');
    } else if (predictedClass == 'healthy') {
      derivedUrgency = 'monitor';
      rulesFired.add('healthy_specimen_routine_monitoring');
    } else if (predictedClass == 'newcastle' || derivedSeverity == 'severe') {
      derivedUrgency = 'vet_now';
      rulesFired.add('pathogen_or_severity_urgent_vet');
    } else {
      derivedUrgency = 'treat_today';
      rulesFired.add('standard_treatment_protocol');
    }

    final now = DateTime.now();

    final Map<String, dynamic> enrichedSignals = Map<String, dynamic>.from(flockSignals);
    final ratios = tfliteResult.clinicalRatios;
    if (ratios != null) {
      enrichedSignals['wateryRatio'] = ratios.wateryRatio;
      enrichedSignals['bloodRatio'] = ratios.bloodRatio;
      enrichedSignals['abnormalRatio'] = ratios.abnormalRatio;
      enrichedSignals['ratioScore'] = ratios.severityScore;
    }

    // 3. Persist diagnosis session directly to local SQLite database
    int? insertedDbId;
    try {
      insertedDbId = await _dbService.insertRecord(
        DetectionHistoryRecord(
          imagePath: imagePath,
          diseaseName: predictedClass,
          severityLevel: derivedSeverity,
          confidenceScore: confidence,
          timestamp: now,
          flockId: flockId,
          notes: jsonEncode(enrichedSignals),
          probabilities: probabilities,
        ),
      );
    } catch (e) {
      debugPrint('[DiagnosticRepository] Local SQLite persistence note: $e');
    }

    final scanId = 'scn-db-${insertedDbId ?? now.millisecondsSinceEpoch}';

    final String derivedCertainty = confidence >= 0.95
        ? 'high'
        : (confidence >= 0.80 ? 'moderate' : 'uncertain');

    final scan = ScanModel(
      id: scanId,
      userId: null,
      deviceId: '',
      flockId: flockId,
      idempotencyKey: 'idemp-${now.millisecondsSinceEpoch}',
      imagePath: imagePath,
      imageWidth: tfliteResult.rawImageWidth,
      imageHeight: tfliteResult.rawImageHeight,
      locale: 'en',
      createdAt: now,
    );

    final prediction = PredictionModel(
      id: 'prd-${now.millisecondsSinceEpoch}',
      scanId: scanId,
      modelVersionId: modelVersionId,
      predictedClass: predictedClass,
      probabilities: probabilities,
      calibratedConfidence: confidence,
      certainty: derivedCertainty,
      conformalSet: [predictedClass],
      abstained: false,
      severity: derivedSeverity,
      urgency: derivedUrgency,
      triageRules: rulesFired,
      flockSignals: enrichedSignals,
      decodeMs: decodeMs,
      preprocessMs: preprocessMs,
      inferenceMs: inferenceMs,
      totalMs: tfliteResult.totalMs,
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
}
