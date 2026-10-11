/// TreatmentModel stores medical recommendations, care steps, and biosecurity protocols
/// reflecting the Chapter 5 `treatments` schema.
class TreatmentModel {
  final String id;
  final String diseaseCode;
  final String severity; // 'mild' | 'moderate' | 'severe'
  final List<String> medicinesEn;
  final List<String> medicinesUr;
  final List<String> careStepsEn;
  final List<String> careStepsUr;
  final List<String> biosecurityEn;
  final List<String> biosecurityUr;
  final bool vetRequired;
  final String urgency; // 'monitor' | 'treat_today' | 'vet_soon' | 'vet_now'
  final bool isReviewed;

  const TreatmentModel({
    required this.id,
    required this.diseaseCode,
    required this.severity,
    required this.medicinesEn,
    required this.medicinesUr,
    required this.careStepsEn,
    required this.careStepsUr,
    required this.biosecurityEn,
    required this.biosecurityUr,
    required this.vetRequired,
    required this.urgency,
    this.isReviewed = true,
  });

  List<String> getMedicines(bool isUrdu) => isUrdu ? medicinesUr : medicinesEn;
  List<String> getCareSteps(bool isUrdu) => isUrdu ? careStepsUr : careStepsEn;
  List<String> getBiosecurity(bool isUrdu) => isUrdu ? biosecurityUr : biosecurityEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'diseaseCode': diseaseCode,
    'severity': severity,
    'medicinesEn': medicinesEn,
    'medicinesUr': medicinesUr,
    'careStepsEn': careStepsEn,
    'careStepsUr': careStepsUr,
    'biosecurityEn': biosecurityEn,
    'biosecurityUr': biosecurityUr,
    'vetRequired': vetRequired,
    'urgency': urgency,
    'isReviewed': isReviewed,
  };

  factory TreatmentModel.fromJson(Map<String, dynamic> json) => TreatmentModel(
    id: json['id'] as String,
    diseaseCode: json['diseaseCode'] as String,
    severity: json['severity'] as String,
    medicinesEn: List<String>.from(json['medicinesEn'] as List),
    medicinesUr: List<String>.from(json['medicinesUr'] as List),
    careStepsEn: List<String>.from(json['careStepsEn'] as List),
    careStepsUr: List<String>.from(json['careStepsUr'] as List),
    biosecurityEn: List<String>.from(json['biosecurityEn'] as List),
    biosecurityUr: List<String>.from(json['biosecurityUr'] as List),
    vetRequired: json['vetRequired'] as bool? ?? false,
    urgency: json['urgency'] as String,
    isReviewed: json['isReviewed'] as bool? ?? true,
  );
}
