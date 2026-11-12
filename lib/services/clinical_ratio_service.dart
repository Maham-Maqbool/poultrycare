import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Encapsulates the clinical sign pixel ratios and derived severity score
/// measured directly from a poultry fecal specimen image.
class ClinicalSignRatios {
  final double bloodRatio;
  final double abnormalRatio;
  final double wateryRatio;
  final double severityScore;
  final String severity; // 'Mild' | 'Moderate' | 'Severe'

  // Parameter thresholds used during assessment
  final double bloodCeiling;
  final double abnormalCeiling;
  final double wateryCeiling;
  final double mildMax;
  final double moderateMax;

  const ClinicalSignRatios({
    required this.bloodRatio,
    required this.abnormalRatio,
    required this.wateryRatio,
    required this.severityScore,
    required this.severity,
    this.bloodCeiling = 0.2239,
    this.abnormalCeiling = 0.05,
    this.wateryCeiling = 0.1676,
    this.mildMax = 1.0,
    this.moderateMax = 2.0,
  });

  /// Default baseline representation
  factory ClinicalSignRatios.initial() {
    return const ClinicalSignRatios(
      bloodRatio: 0.0,
      abnormalRatio: 0.0,
      wateryRatio: 0.0,
      severityScore: 0.0,
      severity: 'Mild',
    );
  }

  Map<String, dynamic> toJson() => {
    'blood_ratio': bloodRatio,
    'abnormal_ratio': abnormalRatio,
    'watery_ratio': wateryRatio,
    'severity_score': severityScore,
    'severity': severity,
    'blood_ceiling': bloodCeiling,
    'abnormal_ceiling': abnormalCeiling,
    'watery_ceiling': wateryCeiling,
  };

  @override
  String toString() {
    return 'ClinicalSignRatios(blood: ${(bloodRatio * 100).toStringAsFixed(2)}%, '
        'abnormal: ${(abnormalRatio * 100).toStringAsFixed(2)}%, '
        'watery: ${(wateryRatio * 100).toStringAsFixed(2)}% -> '
        'score: ${severityScore.toStringAsFixed(3)}, severity: $severity)';
  }
}

/// ClinicalRatioService measures clinical signs from a 224x224 specimen image
/// using HSV pixel classification matching the empirical research script.
class ClinicalRatioService {
  static const double defaultBloodCeiling = 0.2239;
  static const double defaultAbnormalCeiling = 0.05;
  static const double defaultWateryCeiling = 0.1676;
  static const double defaultMildMax = 1.0;
  static const double defaultModerateMax = 2.0;

  /// Computes the 3 clinical ratios on a 224x224 image buffer.
  /// If the input image is not 224x224, it is directly resized with average interpolation.
  static ClinicalSignRatios computeFromImage(
    img.Image image, {
    double bloodCeiling = defaultBloodCeiling,
    double abnormalCeiling = defaultAbnormalCeiling,
    double wateryCeiling = defaultWateryCeiling,
    double mildMax = defaultMildMax,
    double moderateMax = defaultModerateMax,
  }) {
    final img.Image targetImage;
    if (image.width == 224 && image.height == 224) {
      targetImage = image;
    } else {
      targetImage = img.copyResize(
        image,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.average,
      );
    }

    int bloodCount = 0;
    int abnormalCount = 0;
    int wateryCount = 0;
    const int totalPixels = 224 * 224; // 50176

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = targetImage.getPixel(x, y);
        final int r = pixel.r.toInt().clamp(0, 255);
        final int g = pixel.g.toInt().clamp(0, 255);
        final int b = pixel.b.toInt().clamp(0, 255);

        // Convert RGB to PIL-equivalent HSV (H: 0..255, S: 0..255, V: 0..255)
        final int maxc = r > g ? (r > b ? r : b) : (g > b ? g : b);
        final int minc = r < g ? (r < b ? r : b) : (g < b ? g : b);
        final int uv = maxc;
        int uh = 0;
        int us = 0;

        if (minc != maxc) {
          final double cr = (maxc - minc).toDouble();
          final double s = cr / maxc.toDouble();
          final double rc = (maxc - r) / cr;
          final double gc = (maxc - g) / cr;
          final double bc = (maxc - b) / cr;

          double h;
          if (r == maxc) {
            h = bc - gc;
          } else if (g == maxc) {
            h = 2.0 + rc - bc;
          } else {
            h = 4.0 + gc - rc;
          }

          h = (h / 6.0 + 1.0) % 1.0;
          uh = (h * 255.0).toInt().clamp(0, 255);
          us = (s * 255.0).toInt().clamp(0, 255);
        }

        // 1. blood: hue <= 24 or hue >= 243, saturation >= 50, value >= 25
        if ((uh <= 24 || uh >= 243) && us >= 50 && uv >= 25) {
          bloodCount++;
        }

        // 2. abnormal: saturation >= 70, hue 75..242
        if (us >= 70 && uh >= 75 && uh <= 242) {
          abnormalCount++;
        }

        // 3. watery: value >= 205, saturation <= 90
        if (uv >= 205 && us <= 90) {
          wateryCount++;
        }
      }
    }

    final double bloodRatio = bloodCount / totalPixels;
    final double abnormalRatio = abnormalCount / totalPixels;
    final double wateryRatio = wateryCount / totalPixels;

    final double score = (bloodRatio / bloodCeiling) +
        (abnormalRatio / abnormalCeiling) +
        (wateryRatio / wateryCeiling);

    final String severity;
    if (score < mildMax) {
      severity = 'Mild';
    } else if (score <= moderateMax) {
      severity = 'Moderate';
    } else {
      severity = 'Severe';
    }

    return ClinicalSignRatios(
      bloodRatio: bloodRatio,
      abnormalRatio: abnormalRatio,
      wateryRatio: wateryRatio,
      severityScore: score,
      severity: severity,
      bloodCeiling: bloodCeiling,
      abnormalCeiling: abnormalCeiling,
      wateryCeiling: wateryCeiling,
      mildMax: mildMax,
      moderateMax: moderateMax,
    );
  }

  /// Measures clinical ratios from a local file path or Flutter asset.
  static Future<ClinicalSignRatios> computeFromPath(
    String path, {
    double bloodCeiling = defaultBloodCeiling,
    double abnormalCeiling = defaultAbnormalCeiling,
    double wateryCeiling = defaultWateryCeiling,
    double mildMax = defaultMildMax,
    double moderateMax = defaultModerateMax,
  }) async {
    final Uint8List bytes;
    final file = File(path);
    if (await file.exists()) {
      bytes = await file.readAsBytes();
    } else {
      final byteData = await rootBundle.load(path);
      bytes = byteData.buffer.asUint8List();
    }

    return computeFromBytes(
      bytes,
      bloodCeiling: bloodCeiling,
      abnormalCeiling: abnormalCeiling,
      wateryCeiling: wateryCeiling,
      mildMax: mildMax,
      moderateMax: moderateMax,
    );
  }

  /// Measures clinical ratios from raw encoded image bytes.
  static ClinicalSignRatios computeFromBytes(
    Uint8List bytes, {
    double bloodCeiling = defaultBloodCeiling,
    double abnormalCeiling = defaultAbnormalCeiling,
    double wateryCeiling = defaultWateryCeiling,
    double mildMax = defaultMildMax,
    double moderateMax = defaultModerateMax,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return ClinicalSignRatios.initial();
    }
    return computeFromImage(
      decoded,
      bloodCeiling: bloodCeiling,
      abnormalCeiling: abnormalCeiling,
      wateryCeiling: wateryCeiling,
      mildMax: mildMax,
      moderateMax: moderateMax,
    );
  }
}
