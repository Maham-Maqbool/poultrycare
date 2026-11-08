/// PredictionModel captures AI classification outputs, certainty metrics,
/// and clinical rules-based triage decisions reflecting the enterprise predictions schema.
class PredictionModel {
  final String id;
  final String scanId;
  final String? modelVersionId;
  final String? predictedClass; // 'coccidiosis' | 'healthy' | 'ncd' | 'salmonella'
  final Map<String, double> probabilities;
  final double? calibratedConfidence;
  final String certainty; // 'confident' | 'uncertain' | 'cannot_tell'
  final List<String> conformalSet;
  final bool abstained;
  final String? abstainReason;
  final double? energyScore;
  final String? severity; // 'mild' | 'moderate' | 'severe'
  final String? urgency; // 'monitor' | 'treat_today' | 'vet_soon' | 'vet_now'
  final List<String> triageRules;
  final Map<String, dynamic>? flockSignals; // lethargy, intakeDrop, suddenMortality
  final double? decodeMs;
  final double? preprocessMs;
  final double? inferenceMs;
  final double? totalMs;
  final DateTime createdAt;

  const PredictionModel({
    required this.id,
    required this.scanId,
    this.modelVersionId,
    this.predictedClass,
    this.probabilities = const {},
    this.calibratedConfidence,
    this.certainty = 'confident',
    this.conformalSet = const [],
    this.abstained = false,
    this.abstainReason,
    this.energyScore,
    this.severity,
    this.urgency,
    this.triageRules = const [],
    this.flockSignals,
    this.decodeMs,
    this.preprocessMs,
    this.inferenceMs,
    this.totalMs,
    required this.createdAt,
  });

  bool get isHealthy => predictedClass == 'healthy';
  bool get isNotifiable => predictedClass == 'ncd' || predictedClass == 'newcastle' || (predictedClass?.toLowerCase().contains('newcastle') ?? false);

  PredictionModel copyWith({
    String? id,
    String? scanId,
    String? modelVersionId,
    String? predictedClass,
    Map<String, double>? probabilities,
    double? calibratedConfidence,
    String? certainty,
    List<String>? conformalSet,
    bool? abstained,
    String? abstainReason,
    double? energyScore,
    String? severity,
    String? urgency,
    List<String>? triageRules,
    Map<String, dynamic>? flockSignals,
    double? decodeMs,
    double? preprocessMs,
    double? inferenceMs,
    double? totalMs,
    DateTime? createdAt,
  }) {
    return PredictionModel(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      modelVersionId: modelVersionId ?? this.modelVersionId,
      predictedClass: predictedClass ?? this.predictedClass,
      probabilities: probabilities ?? this.probabilities,
      calibratedConfidence: calibratedConfidence ?? this.calibratedConfidence,
      certainty: certainty ?? this.certainty,
      conformalSet: conformalSet ?? this.conformalSet,
      abstained: abstained ?? this.abstained,
      abstainReason: abstainReason ?? this.abstainReason,
      energyScore: energyScore ?? this.energyScore,
      severity: severity ?? this.severity,
      urgency: urgency ?? this.urgency,
      triageRules: triageRules ?? this.triageRules,
      flockSignals: flockSignals ?? this.flockSignals,
      decodeMs: decodeMs ?? this.decodeMs,
      preprocessMs: preprocessMs ?? this.preprocessMs,
      inferenceMs: inferenceMs ?? this.inferenceMs,
      totalMs: totalMs ?? this.totalMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scanId': scanId,
    'modelVersionId': modelVersionId,
    'predictedClass': predictedClass,
    'probabilities': probabilities,
    'calibratedConfidence': calibratedConfidence,
    'certainty': certainty,
    'conformalSet': conformalSet,
    'abstained': abstained,
    'abstainReason': abstainReason,
    'energyScore': energyScore,
    'severity': severity,
    'urgency': urgency,
    'triageRules': triageRules,
    'flockSignals': flockSignals,
    'decodeMs': decodeMs,
    'preprocessMs': preprocessMs,
    'inferenceMs': inferenceMs,
    'totalMs': totalMs,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PredictionModel.fromJson(Map<String, dynamic> json) => PredictionModel(
    id: json['id'] as String,
    scanId: json['scanId'] as String,
    modelVersionId: json['modelVersionId'] as String?,
    predictedClass: json['predictedClass'] as String?,
    probabilities: Map<String, double>.from(json['probabilities'] as Map? ?? {}),
    calibratedConfidence: (json['calibratedConfidence'] as num?)?.toDouble(),
    certainty: json['certainty'] as String? ?? 'confident',
    conformalSet: List<String>.from(json['conformalSet'] as List? ?? []),
    abstained: json['abstained'] as bool? ?? false,
    abstainReason: json['abstainReason'] as String?,
    energyScore: (json['energyScore'] as num?)?.toDouble(),
    severity: json['severity'] as String?,
    urgency: json['urgency'] as String?,
    triageRules: List<String>.from(json['triageRules'] as List? ?? []),
    flockSignals: json['flockSignals'] as Map<String, dynamic>?,
    decodeMs: (json['decodeMs'] as num?)?.toDouble(),
    preprocessMs: (json['preprocessMs'] as num?)?.toDouble(),
    inferenceMs: (json['inferenceMs'] as num?)?.toDouble(),
    totalMs: (json['totalMs'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
