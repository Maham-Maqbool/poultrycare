/// FlockModel represents a poultry flock/shed managed by a farmer
/// reflecting the commercial farm flock schema.
class FlockModel {
  final String id;
  final String userId;
  final String name;
  final int? birdCount;
  final String? breed;
  final String? notes;
  final DateTime createdAt;
  final int activeDiseaseCount;

  const FlockModel({
    required this.id,
    required this.userId,
    required this.name,
    this.birdCount,
    this.breed,
    this.notes,
    required this.createdAt,
    this.activeDiseaseCount = 0,
  });

  FlockModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? birdCount,
    String? breed,
    String? notes,
    DateTime? createdAt,
    int? activeDiseaseCount,
  }) {
    return FlockModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      birdCount: birdCount ?? this.birdCount,
      breed: breed ?? this.breed,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      activeDiseaseCount: activeDiseaseCount ?? this.activeDiseaseCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'birdCount': birdCount,
    'breed': breed,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'activeDiseaseCount': activeDiseaseCount,
  };

  factory FlockModel.fromJson(Map<String, dynamic> json) => FlockModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    birdCount: json['birdCount'] as int?,
    breed: json['breed'] as String?,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    activeDiseaseCount: json['activeDiseaseCount'] as int? ?? 0,
  );
}
