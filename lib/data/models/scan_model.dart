/// ScanModel represents a diagnostic session or scan submission
/// reflecting the commercial scan domain schema.
class ScanModel {
  final String id;
  final String? userId;
  final String deviceId;
  final String? flockId;
  final String idempotencyKey;
  final String imagePath;
  final int? imageWidth;
  final int? imageHeight;
  final String locale;
  final DateTime createdAt;

  const ScanModel({
    required this.id,
    this.userId,
    required this.deviceId,
    this.flockId,
    required this.idempotencyKey,
    required this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.locale = 'en',
    required this.createdAt,
  });

  ScanModel copyWith({
    String? id,
    String? userId,
    String? deviceId,
    String? flockId,
    String? idempotencyKey,
    String? imagePath,
    int? imageWidth,
    int? imageHeight,
    String? locale,
    DateTime? createdAt,
  }) {
    return ScanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      flockId: flockId ?? this.flockId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      imagePath: imagePath ?? this.imagePath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'deviceId': deviceId,
    'flockId': flockId,
    'idempotencyKey': idempotencyKey,
    'imagePath': imagePath,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'locale': locale,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
    id: json['id'] as String,
    userId: json['userId'] as String?,
    deviceId: json['deviceId'] as String,
    flockId: json['flockId'] as String?,
    idempotencyKey: json['idempotencyKey'] as String,
    imagePath: json['imagePath'] as String,
    imageWidth: json['imageWidth'] as int?,
    imageHeight: json['imageHeight'] as int?,
    locale: json['locale'] as String? ?? 'en',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
