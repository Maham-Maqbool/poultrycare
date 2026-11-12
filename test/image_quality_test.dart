import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poultrycare/services/image_quality_service.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/data/repositories/disease_repository.dart';
import 'package:poultrycare/features/scanner/controllers/scanner_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Automated ImageQualityService Tests', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('poultrycare_quality_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Initial quality report defaults to not checked and isImageValid is false', () {
      final report = ImageQualityReport.initial();
      expect(report.lightingStatus, QualityCheckStatus.notChecked);
      expect(report.sharpnessStatus, QualityCheckStatus.notChecked);
      expect(report.isPassed, isFalse);
      expect(report.isNotChecked, isTrue);
      expect(report.getLightingMessage(false), 'Not checked');
      expect(report.getLightingMessage(true), 'جانچ نہیں ہوئی');
      expect(report.getSharpnessMessage(false), 'Not checked');
      expect(report.getSharpnessMessage(true), 'جانچ نہیں ہوئی');
    });

    test('Checking quality report shows progress state', () {
      final report = ImageQualityReport.checking();
      expect(report.lightingStatus, QualityCheckStatus.checking);
      expect(report.sharpnessStatus, QualityCheckStatus.checking);
      expect(report.isChecking, isTrue);
      expect(report.isPassed, isFalse);
      expect(report.getLightingMessage(false), 'Checking lighting...');
      expect(report.getLightingMessage(true), 'روشنی کا معائنہ جاری ہے...');
    });

    test('Dark photo (<35.0 luminance) fails lighting check with specific message', () async {
      // Create dark image (luminance ~ 15)
      final darkImg = img.Image(width: 400, height: 400);
      for (int y = 0; y < 400; y++) {
        for (int x = 0; x < 400; x++) {
          darkImg.setPixelRgb(x, y, 15, 15, 15);
        }
      }
      final file = File('${tempDir.path}/dark_test.jpg');
      await file.writeAsBytes(img.encodeJpg(darkImg));

      final report = await ImageQualityService.evaluateImage(file.path);
      expect(report.lightingStatus, QualityCheckStatus.failed);
      expect(report.isPassed, isFalse);
      expect(report.meanLuminance < 35.0, isTrue);
      expect(report.getLightingMessage(false).contains('too dark'), isTrue);
      expect(report.getLightingMessage(true).contains('Photo buhat dark hai'), isTrue);
    });

    test('Overexposed photo (>248.0 luminance) fails lighting check with specific message', () async {
      // Create overexposed washed-out image (luminance ~ 254)
      final brightImg = img.Image(width: 400, height: 400);
      for (int y = 0; y < 400; y++) {
        for (int x = 0; x < 400; x++) {
          brightImg.setPixelRgb(x, y, 254, 254, 254);
        }
      }
      final file = File('${tempDir.path}/bright_test.jpg');
      await file.writeAsBytes(img.encodeJpg(brightImg));

      final report = await ImageQualityService.evaluateImage(file.path);
      expect(report.lightingStatus, QualityCheckStatus.failed);
      expect(report.isPassed, isFalse);
      expect(report.meanLuminance > 248.0, isTrue);
      expect(report.getLightingMessage(false).contains('too bright'), isTrue);
      expect(report.getLightingMessage(true).contains('Buhat zyada roshni hai'), isTrue);
    });

    test('Blurry photo (Laplacian variance < 35.0) fails sharpness check with specific message', () async {
      // Create a smooth gradient image with no high-frequency edge contrast
      final smoothImg = img.Image(width: 400, height: 400);
      for (int y = 0; y < 400; y++) {
        for (int x = 0; x < 400; x++) {
          final val = (100 + (x * 0.1)).round().clamp(0, 255);
          smoothImg.setPixelRgb(x, y, val, val, val);
        }
      }
      final blurred = img.gaussianBlur(smoothImg, radius: 10);
      final file = File('${tempDir.path}/blurry_test.jpg');
      await file.writeAsBytes(img.encodeJpg(blurred));

      final report = await ImageQualityService.evaluateImage(file.path);
      expect(report.sharpnessStatus, QualityCheckStatus.failed);
      expect(report.isPassed, isFalse);
      expect(report.laplacianVariance < 35.0, isTrue);
      expect(report.getSharpnessMessage(false).contains('blurry'), isTrue);
      expect(report.getSharpnessMessage(true).contains('Photo blurry hai'), isTrue);
    });

    test('All 4 bundled authentic poultry sample images pass automatic quality checks', () async {
      final samples = [
        'assets/images/samples/coccidiosis.jpg',
        'assets/images/samples/newcastle.jpg',
        'assets/images/samples/salmonella.jpg',
        'assets/images/samples/healthy.png',
      ];

      for (final samplePath in samples) {
        final report = await ImageQualityService.evaluateImage(samplePath);
        expect(report.lightingStatus, QualityCheckStatus.passed,
            reason: 'Sample $samplePath lighting should pass (meanLuminance: ${report.meanLuminance})');
        expect(report.sharpnessStatus, QualityCheckStatus.passed,
            reason: 'Sample $samplePath sharpness should pass (laplacianVariance: ${report.laplacianVariance})');
        expect(report.isPassed, isTrue);
      }
    });

    test('ScannerController executeDiagnosis halts silently and flags quality failure on blurry image', () async {
      final smoothImg = img.Image(width: 400, height: 400);
      for (int y = 0; y < 400; y++) {
        for (int x = 0; x < 400; x++) {
          final val = (100 + (x * 0.1)).round().clamp(0, 255);
          smoothImg.setPixelRgb(x, y, val, val, val);
        }
      }
      final blurred = img.gaussianBlur(smoothImg, radius: 10);
      final file = File('${tempDir.path}/blurry_fecal.jpg');
      await file.writeAsBytes(img.encodeJpg(blurred));

      final diseaseRepo = DiseaseRepository();
      final diagnosticRepo = DiagnosticRepository();
      final controller = ScannerController(diagnosticRepo, diseaseRepo);

      controller.setImagePath(file.path, isLocal: true);
      controller.setFlockSignals(
        lethargy: 'None',
        intakeDrop: 'Normal',
        suddenMortality: 'None in 24h',
      );

      final result = await controller.executeDiagnosis();
      expect(result, isNull);
      expect(controller.isQualityFailed, isTrue);
      expect(controller.qualityReport.sharpnessStatus, QualityCheckStatus.failed);
      expect(controller.errorMessage?.contains('blurry'), isTrue);
    });
  });
}

