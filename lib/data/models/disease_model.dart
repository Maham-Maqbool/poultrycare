/// DiseaseModel represents a poultry disease classification master record
/// reflecting the enterprise disease domain schema.
class DiseaseModel {
  final String code; // 'coccidiosis' | 'healthy' | 'ncd' | 'salmonella'
  final String nameEn;
  final String nameUr;
  final String summaryEn;
  final String summaryUr;
  final List<String> signsEn;
  final List<String> signsUr;
  final String baselineSeverity; // 'mild' | 'moderate' | 'severe'
  final String baselineUrgency; // 'monitor' | 'treat_today' | 'vet_soon' | 'vet_now'
  final bool isNotifiable; // true for Newcastle Disease
  final String? audioEn;
  final String? audioUr;
  final int displayOrder;

  const DiseaseModel({
    required this.code,
    required this.nameEn,
    required this.nameUr,
    required this.summaryEn,
    required this.summaryUr,
    required this.signsEn,
    required this.signsUr,
    required this.baselineSeverity,
    required this.baselineUrgency,
    this.isNotifiable = false,
    this.audioEn,
    this.audioUr,
    this.displayOrder = 0,
  });

  String getName(bool isUrdu) => isUrdu ? nameUr : nameEn;
  String getSummary(bool isUrdu) => isUrdu ? summaryUr : summaryEn;
  List<String> getSigns(bool isUrdu) => isUrdu ? signsUr : signsEn;

  Map<String, dynamic> toJson() => {
    'code': code,
    'nameEn': nameEn,
    'nameUr': nameUr,
    'summaryEn': summaryEn,
    'summaryUr': summaryUr,
    'signsEn': signsEn,
    'signsUr': signsUr,
    'baselineSeverity': baselineSeverity,
    'baselineUrgency': baselineUrgency,
    'isNotifiable': isNotifiable,
    'audioEn': audioEn,
    'audioUr': audioUr,
    'displayOrder': displayOrder,
  };

  factory DiseaseModel.fromJson(Map<String, dynamic> json) => DiseaseModel(
    code: json['code'] as String,
    nameEn: json['nameEn'] as String,
    nameUr: json['nameUr'] as String,
    summaryEn: json['summaryEn'] as String,
    summaryUr: json['summaryUr'] as String,
    signsEn: List<String>.from(json['signsEn'] as List),
    signsUr: List<String>.from(json['signsUr'] as List),
    baselineSeverity: json['baselineSeverity'] as String,
    baselineUrgency: json['baselineUrgency'] as String,
    isNotifiable: json['isNotifiable'] as bool? ?? false,
    audioEn: json['audioEn'] as String?,
    audioUr: json['audioUr'] as String?,
    displayOrder: json['displayOrder'] as int? ?? 0,
  );
}
