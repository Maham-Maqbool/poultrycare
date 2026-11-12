import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Status enumeration for automated image quality checks.
enum QualityCheckStatus {
  notChecked,
  checking,
  passed,
  failed,
}

/// Structured report containing the outcome of automatic image quality checks.
class ImageQualityReport {
  final QualityCheckStatus lightingStatus;
  final QualityCheckStatus sharpnessStatus;
  final double meanLuminance;
  final double laplacianVariance;

  const ImageQualityReport({
    required this.lightingStatus,
    required this.sharpnessStatus,
    this.meanLuminance = 0.0,
    this.laplacianVariance = 0.0,
  });

  factory ImageQualityReport.initial() {
    return const ImageQualityReport(
      lightingStatus: QualityCheckStatus.notChecked,
      sharpnessStatus: QualityCheckStatus.notChecked,
    );
  }

  factory ImageQualityReport.checking() {
    return const ImageQualityReport(
      lightingStatus: QualityCheckStatus.checking,
      sharpnessStatus: QualityCheckStatus.checking,
    );
  }

  bool get isPassed =>
      lightingStatus == QualityCheckStatus.passed &&
      sharpnessStatus == QualityCheckStatus.passed;

  bool get isFailed =>
      lightingStatus == QualityCheckStatus.failed ||
      sharpnessStatus == QualityCheckStatus.failed;

  bool get isChecking =>
      lightingStatus == QualityCheckStatus.checking ||
      sharpnessStatus == QualityCheckStatus.checking;

  bool get isNotChecked =>
      lightingStatus == QualityCheckStatus.notChecked &&
      sharpnessStatus == QualityCheckStatus.notChecked;

  String getLightingMessage(bool isUrdu) {
    switch (lightingStatus) {
      case QualityCheckStatus.notChecked:
        return isUrdu ? 'جانچ نہیں ہوئی' : 'Not checked';
      case QualityCheckStatus.checking:
        return isUrdu ? 'روشنی کا معائنہ جاری ہے...' : 'Checking lighting...';
      case QualityCheckStatus.passed:
        return isUrdu ? 'مناسب روشنی اور واضح منظر' : 'Optimal lighting and visibility';
      case QualityCheckStatus.failed:
        if (meanLuminance < ImageQualityService.minLuminanceThreshold) {
          return isUrdu
              ? 'تصویر بہت تاریک ہے - روشنی میں دوبارہ لیں (Photo buhat dark hai - roshni mein dobara lo)'
              : 'Photo is too dark - retake in better lighting';
        } else {
          return isUrdu
              ? 'بہت زیادہ روشنی ہے - سائے میں دوبارہ لیں (Buhat zyada roshni hai - saaye mein dobara lo)'
              : 'Photo is too bright - retake in shaded lighting';
        }
    }
  }

  String getSharpnessMessage(bool isUrdu) {
    switch (sharpnessStatus) {
      case QualityCheckStatus.notChecked:
        return isUrdu ? 'جانچ نہیں ہوئی' : 'Not checked';
      case QualityCheckStatus.checking:
        return isUrdu ? 'فوکس اور تفصیلات کی جانچ جاری ہے...' : 'Measuring sharpness...';
      case QualityCheckStatus.passed:
        return isUrdu ? 'فوکس واضح اور تفصیلات صاف ہیں' : 'Sharp focus and clear detail';
      case QualityCheckStatus.failed:
        return isUrdu
            ? 'تصویر دھندلی ہے - ہاتھ ساکت رکھ کر دوبارہ لیں (Photo blurry hai - haath steady rakh kar dobara lo)'
            : 'Photo is blurry - hold steady and retake';
    }
  }
}

/// ImageQualityService provides real-time automated visual quality validation
/// for poultry fecal specimens:
/// 1. Lighting & Specimen Visibility: Computes mean luminance (0..255).
/// 2. Focal Sharpness & Detail: Computes Laplacian variance on grayscale tensor.
class ImageQualityService {
  // Calibrated thresholds from real poultry dropping photos:
  // - Minimum mean luminance: 35.0 (below this, droppings are obscured by shadow/unlit sheds)
  // - Maximum mean luminance: 248.0 (above this, details are washed out by direct flash blowout)
  // - Minimum Laplacian variance: 35.0 (below this, images suffer from severe focal/motion blur)
  static const double minLuminanceThreshold = 35.0;
  static const double maxLuminanceThreshold = 248.0;
  static const double minSharpnessThreshold = 35.0;

  /// Loads image bytes from local file, asset bundle, or network URL.
  static Future<Uint8List?> loadImageBytes(String path) async {
    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        final client = HttpClient();
        client.userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
        final req = await client.getUrl(Uri.parse(path)).timeout(const Duration(seconds: 8));
        final resp = await req.close().timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          final List<int> bytesList = [];
          await for (final chunk in resp) {
            bytesList.addAll(chunk);
          }
          return Uint8List.fromList(bytesList);
        }
      } else {
        final file = File(path);
        if (await file.exists()) {
          return await file.readAsBytes();
        } else {
          final byteData = await rootBundle.load(path);
          return byteData.buffer.asUint8List();
        }
      }
    } catch (e) {
      debugPrint('[ImageQualityService] Image load error: $e');
    }
    return null;
  }

  /// Automatically evaluates the image quality for lighting and focal sharpness.
  static Future<ImageQualityReport> evaluateImage(String imagePath) async {
    try {
      final bytes = await loadImageBytes(imagePath);
      if (bytes == null || bytes.isEmpty) {
        return const ImageQualityReport(
          lightingStatus: QualityCheckStatus.failed,
          sharpnessStatus: QualityCheckStatus.failed,
        );
      }

      // Decode image
      final rawImage = img.decodeImage(bytes);
      if (rawImage == null) {
        return const ImageQualityReport(
          lightingStatus: QualityCheckStatus.failed,
          sharpnessStatus: QualityCheckStatus.failed,
        );
      }

      // Resize to standardized width of 400px for high-speed, noise-resistant measurement
      final thumb = img.copyResize(rawImage, width: 400);
      final int w = thumb.width;
      final int h = thumb.height;
      final int totalPixels = w * h;

      // 1. Measure Mean Luminance (Rec. 601: 0.299 R + 0.587 G + 0.114 B)
      double totalLuminance = 0.0;
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final p = thumb.getPixel(x, y);
          final lum = (0.299 * p.r) + (0.587 * p.g) + (0.114 * p.b);
          totalLuminance += lum;
        }
      }
      final double meanLuminance = totalPixels > 0 ? (totalLuminance / totalPixels) : 0.0;

      // 2. Measure Blur via Laplacian Variance on Grayscale
      final gray = img.grayscale(thumb);
      final List<double> lapValues = [];
      double lapSum = 0.0;

      for (int y = 1; y < h - 1; y++) {
        for (int x = 1; x < w - 1; x++) {
          final top = gray.getPixel(x, y - 1).r.toDouble();
          final bottom = gray.getPixel(x, y + 1).r.toDouble();
          final left = gray.getPixel(x - 1, y).r.toDouble();
          final right = gray.getPixel(x + 1, y).r.toDouble();
          final center = gray.getPixel(x, y).r.toDouble();

          final lap = top + bottom + left + right - (4.0 * center);
          lapValues.add(lap);
          lapSum += lap;
        }
      }

      final int count = lapValues.length;
      final double meanLap = count > 0 ? (lapSum / count) : 0.0;
      double varianceSum = 0.0;
      for (final val in lapValues) {
        final diff = val - meanLap;
        varianceSum += diff * diff;
      }
      final double laplacianVariance = count > 0 ? (varianceSum / count) : 0.0;

      // Evaluate Lighting Check
      QualityCheckStatus lightingStatus;
      if (meanLuminance < minLuminanceThreshold || meanLuminance > maxLuminanceThreshold) {
        lightingStatus = QualityCheckStatus.failed;
      } else {
        lightingStatus = QualityCheckStatus.passed;
      }

      // Evaluate Focal Sharpness Check
      QualityCheckStatus sharpnessStatus;
      if (laplacianVariance < minSharpnessThreshold) {
        sharpnessStatus = QualityCheckStatus.failed;
      } else {
        sharpnessStatus = QualityCheckStatus.passed;
      }

      return ImageQualityReport(
        lightingStatus: lightingStatus,
        sharpnessStatus: sharpnessStatus,
        meanLuminance: meanLuminance,
        laplacianVariance: laplacianVariance,
      );
    } catch (e) {
      debugPrint('[ImageQualityService] Evaluation exception: $e');
      return const ImageQualityReport(
        lightingStatus: QualityCheckStatus.failed,
        sharpnessStatus: QualityCheckStatus.failed,
      );
    }
  }
}
