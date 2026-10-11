import '../models/scan_model.dart';
import '../models/prediction_model.dart';
import '../models/feedback_model.dart';
import '../../core/constants/app_assets.dart';

class DiagnosticRecord {
  final ScanModel scan;
  final PredictionModel prediction;
  final FeedbackModel? feedback;

  const DiagnosticRecord({
    required this.scan,
    required this.prediction,
    this.feedback,
  });
}

/// mockScansData provides 8 comprehensive historical diagnosis sessions
/// spanning Coccidiosis, Newcastle Disease, Salmonella, and Healthy droppings.
final List<DiagnosticRecord> mockDiagnosticRecords = [
  // Record 1: Coccidiosis - Moderate in Shed 1
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-101',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-101',
      idempotencyKey: 'idemp-2026-10-10-0914',
      imagePath: AppAssets.sampleCoccidiosis,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    prediction: PredictionModel(
      id: 'prd-101',
      scanId: 'scn-101',
      modelVersionId: 'mod-v120',
      predictedClass: 'coccidiosis',
      probabilities: {
        'coccidiosis': 0.942,
        'salmonella': 0.041,
        'healthy': 0.012,
        'ncd': 0.005,
      },
      calibratedConfidence: 0.942,
      certainty: 'confident',
      conformalSet: ['coccidiosis'],
      abstained: false,
      severity: 'moderate',
      urgency: 'treat_today',
      triageRules: [
        'baseline_coccidiosis_moderate',
        'intake_drop_moderate_confirmed',
        'treat_toltrazuril_prescribed',
      ],
      flockSignals: {
        'lethargy': 'Under 10% of birds',
        'intakeDrop': 'Reduced consumption',
        'suddenMortality': 'None in 24h',
      },
      decodeMs: 14.2,
      preprocessMs: 18.5,
      inferenceMs: 82.1,
      totalMs: 114.8,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    feedback: FeedbackModel(
      id: 'fb-101',
      scanId: 'scn-101',
      wasHelpful: true,
      actualClass: 'coccidiosis',
      confirmedByVet: true,
      comment: 'Vet confirmed oocysts in fecal smear. Toltrazuril administered.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ),

  // Record 2: Newcastle Disease - Severe in Isolation Bay
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-102',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-104',
      idempotencyKey: 'idemp-2026-10-09-1422',
      imagePath: AppAssets.sampleNewcastle,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    prediction: PredictionModel(
      id: 'prd-102',
      scanId: 'scn-102',
      modelVersionId: 'mod-v120',
      predictedClass: 'ncd',
      probabilities: {
        'ncd': 0.981,
        'coccidiosis': 0.012,
        'salmonella': 0.005,
        'healthy': 0.002,
      },
      calibratedConfidence: 0.981,
      certainty: 'confident',
      conformalSet: ['ncd'],
      abstained: false,
      severity: 'severe',
      urgency: 'vet_now',
      triageRules: [
        'pathogen_ncd_inherently_severe',
        'sudden_mortality_escalation',
        'notifiable_alert_blocking_active',
        'vet_now_immediate_dispatch',
      ],
      flockSignals: {
        'lethargy': 'Over 10% of birds',
        'intakeDrop': 'Severely dropped',
        'suddenMortality': 'Multiple birds died',
      },
      decodeMs: 12.0,
      preprocessMs: 19.1,
      inferenceMs: 80.4,
      totalMs: 111.5,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    feedback: FeedbackModel(
      id: 'fb-102',
      scanId: 'scn-102',
      wasHelpful: true,
      actualClass: 'ncd',
      confirmedByVet: true,
      comment: 'Reported to government district officer. Strict quarantine initiated.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ),

  // Record 3: Healthy in Shed 2 (Commercial Layers)
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-103',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-102',
      idempotencyKey: 'idemp-2026-10-08-0800',
      imagePath: AppAssets.sampleHealthy,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    prediction: PredictionModel(
      id: 'prd-103',
      scanId: 'scn-103',
      modelVersionId: 'mod-v120',
      predictedClass: 'healthy',
      probabilities: {
        'healthy': 0.967,
        'salmonella': 0.019,
        'coccidiosis': 0.010,
        'ncd': 0.004,
      },
      calibratedConfidence: 0.967,
      certainty: 'confident',
      conformalSet: ['healthy'],
      abstained: false,
      severity: 'mild',
      urgency: 'monitor',
      triageRules: [
        'baseline_healthy_droppings',
        'normal_intake_confirmed',
        'routine_monitoring_continue',
      ],
      flockSignals: {
        'lethargy': 'None',
        'intakeDrop': 'Normal',
        'suddenMortality': 'None in 24h',
      },
      decodeMs: 15.1,
      preprocessMs: 17.8,
      inferenceMs: 78.6,
      totalMs: 111.5,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    feedback: null,
  ),

  // Record 4: Salmonella - Moderate in Pen 3
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-104',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-103',
      idempotencyKey: 'idemp-2026-10-07-1130',
      imagePath: AppAssets.sampleSalmonella,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    prediction: PredictionModel(
      id: 'prd-104',
      scanId: 'scn-104',
      modelVersionId: 'mod-v120',
      predictedClass: 'salmonella',
      probabilities: {
        'salmonella': 0.915,
        'coccidiosis': 0.052,
        'healthy': 0.021,
        'ncd': 0.012,
      },
      calibratedConfidence: 0.915,
      certainty: 'confident',
      conformalSet: ['salmonella'],
      abstained: false,
      severity: 'moderate',
      urgency: 'treat_today',
      triageRules: [
        'baseline_salmonella_moderate',
        'white_pasting_detected',
        'enrofloxacin_regimen_started',
      ],
      flockSignals: {
        'lethargy': 'Under 10% of birds',
        'intakeDrop': 'Reduced consumption',
        'suddenMortality': '1 to 2 birds',
      },
      decodeMs: 13.9,
      preprocessMs: 18.2,
      inferenceMs: 84.1,
      totalMs: 116.2,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    feedback: FeedbackModel(
      id: 'fb-104',
      scanId: 'scn-104',
      wasHelpful: true,
      actualClass: 'salmonella',
      confirmedByVet: false,
      comment: 'Vents washed and acidifier introduced into water tanks.',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
    ),
  ),

  // Record 5: Coccidiosis - Mild early stage
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-105',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-101',
      idempotencyKey: 'idemp-2026-10-06-1645',
      imagePath: AppAssets.sampleCoccidiosis,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    prediction: PredictionModel(
      id: 'prd-105',
      scanId: 'scn-105',
      modelVersionId: 'mod-v120',
      predictedClass: 'coccidiosis',
      probabilities: {
        'coccidiosis': 0.884,
        'salmonella': 0.071,
        'healthy': 0.035,
        'ncd': 0.010,
      },
      calibratedConfidence: 0.884,
      certainty: 'confident',
      conformalSet: ['coccidiosis'],
      abstained: false,
      severity: 'mild',
      urgency: 'treat_today',
      triageRules: [
        'baseline_coccidiosis_early',
        'amprolium_preventative_dose',
      ],
      flockSignals: {
        'lethargy': 'Single bird',
        'intakeDrop': 'Normal',
        'suddenMortality': 'None in 24h',
      },
      decodeMs: 14.5,
      preprocessMs: 19.0,
      inferenceMs: 81.2,
      totalMs: 114.7,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    feedback: null,
  ),

  // Record 6: Healthy in Desi pen
  DiagnosticRecord(
    scan: ScanModel(
      id: 'scn-106',
      userId: 'usr-001',
      deviceId: 'dev-pk-9921',
      flockId: 'flock-103',
      idempotencyKey: 'idemp-2026-10-05-1015',
      imagePath: AppAssets.sampleHealthy,
      imageWidth: 1024,
      imageHeight: 1024,
      locale: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    prediction: PredictionModel(
      id: 'prd-106',
      scanId: 'scn-106',
      modelVersionId: 'mod-v120',
      predictedClass: 'healthy',
      probabilities: {
        'healthy': 0.978,
        'salmonella': 0.012,
        'coccidiosis': 0.007,
        'ncd': 0.003,
      },
      calibratedConfidence: 0.978,
      certainty: 'confident',
      conformalSet: ['healthy'],
      abstained: false,
      severity: 'mild',
      urgency: 'monitor',
      triageRules: [
        'baseline_healthy_status',
        'flock_parameters_stable',
      ],
      flockSignals: {
        'lethargy': 'None',
        'intakeDrop': 'Normal',
        'suddenMortality': 'None in 24h',
      },
      decodeMs: 13.2,
      preprocessMs: 18.0,
      inferenceMs: 79.5,
      totalMs: 110.7,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    feedback: null,
  ),
];
