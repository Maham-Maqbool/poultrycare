/// FeedbackModel captures farmer helpfulness and veterinarian confirmed labels
/// reflecting the enterprise feedback domain schema.
class FeedbackModel {
  final String id;
  final String scanId;
  final bool? wasHelpful;
  final String? actualClass; // If vet confirmed a different class
  final bool confirmedByVet;
  final String? comment;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.scanId,
    this.wasHelpful,
    this.actualClass,
    this.confirmedByVet = false,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'scanId': scanId,
    'wasHelpful': wasHelpful,
    'actualClass': actualClass,
    'confirmedByVet': confirmedByVet,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
    id: json['id'] as String,
    scanId: json['scanId'] as String,
    wasHelpful: json['wasHelpful'] as bool?,
    actualClass: json['actualClass'] as String?,
    confirmedByVet: json['confirmedByVet'] as bool? ?? false,
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
