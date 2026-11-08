/// ModelVersionModel tracks registered deep learning models
/// reflecting the AI model registry schema.
class ModelVersionModel {
  final String id;
  final String version;
  final String source;
  final String backbone;
  final double macroF1;
  final double balancedAccuracy;
  final double mcc;
  final bool isActive;
  final DateTime createdAt;

  const ModelVersionModel({
    required this.id,
    required this.version,
    required this.source,
    required this.backbone,
    required this.macroF1,
    required this.balancedAccuracy,
    required this.mcc,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'source': source,
    'backbone': backbone,
    'macroF1': macroF1,
    'balancedAccuracy': balancedAccuracy,
    'mcc': mcc,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ModelVersionModel.fromJson(Map<String, dynamic> json) => ModelVersionModel(
    id: json['id'] as String,
    version: json['version'] as String,
    source: json['source'] as String,
    backbone: json['backbone'] as String,
    macroF1: (json['macroF1'] as num).toDouble(),
    balancedAccuracy: (json['balancedAccuracy'] as num).toDouble(),
    mcc: (json['mcc'] as num).toDouble(),
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
