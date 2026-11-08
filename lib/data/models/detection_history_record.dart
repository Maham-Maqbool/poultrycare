import 'dart:convert';

/// DetectionHistoryRecord represents a single diagnosis session
/// stored in the local SQLite database.
class DetectionHistoryRecord {
  final int? id;
  final String imagePath;
  final String diseaseName;
  final String severityLevel;
  final double confidenceScore;
  final DateTime timestamp;
  final String? flockId;
  final String? notes;
  final Map<String, double>? probabilities;

  const DetectionHistoryRecord({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.severityLevel,
    required this.confidenceScore,
    required this.timestamp,
    this.flockId,
    this.notes,
    this.probabilities,
  });

  /// Converts the record to a map representation for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'image_path': imagePath,
      'disease_name': diseaseName,
      'severity_level': severityLevel,
      'confidence_score': confidenceScore,
      'timestamp': timestamp.toIso8601String(),
      'flock_id': flockId ?? 'flock-101',
      'notes': notes,
      'probabilities_json':
          probabilities != null ? jsonEncode(probabilities) : null,
    };
  }

  /// Creates a DetectionHistoryRecord from a SQLite map row.
  factory DetectionHistoryRecord.fromMap(Map<String, dynamic> map) {
    Map<String, double>? parsedProbabilities;
    if (map['probabilities_json'] != null) {
      try {
        final decoded = jsonDecode(map['probabilities_json'] as String);
        if (decoded is Map) {
          parsedProbabilities = decoded.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          );
        }
      } catch (_) {}
    }

    return DetectionHistoryRecord(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String? ?? '',
      diseaseName: map['disease_name'] as String? ?? 'Healthy',
      severityLevel: map['severity_level'] as String? ?? 'Mild',
      confidenceScore: (map['confidence_score'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      flockId: map['flock_id'] as String?,
      notes: map['notes'] as String?,
      probabilities: parsedProbabilities,
    );
  }

  /// Returns a copy of the record with modified fields.
  DetectionHistoryRecord copyWith({
    int? id,
    String? imagePath,
    String? diseaseName,
    String? severityLevel,
    double? confidenceScore,
    DateTime? timestamp,
    String? flockId,
    String? notes,
    Map<String, double>? probabilities,
  }) {
    return DetectionHistoryRecord(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      diseaseName: diseaseName ?? this.diseaseName,
      severityLevel: severityLevel ?? this.severityLevel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      timestamp: timestamp ?? this.timestamp,
      flockId: flockId ?? this.flockId,
      notes: notes ?? this.notes,
      probabilities: probabilities ?? this.probabilities,
    );
  }

  @override
  String toString() {
    return 'DetectionHistoryRecord(id: $id, disease: $diseaseName, '
        'severity: $severityLevel, confidence: ${(confidenceScore * 100).toStringAsFixed(1)}%, '
        'time: $timestamp)';
  }
}

