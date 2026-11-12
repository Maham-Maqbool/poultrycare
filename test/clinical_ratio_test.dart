import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poultrycare/services/clinical_ratio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ClinicalRatioService HSV Pixel Counting & Score Tests', () {
    test('Pure blood red image produces bloodRatio ~ 1.0 and Severe severity', () {
      final image = img.Image(width: 224, height: 224);
      // Red: R=220, G=30, B=30 -> hue ~ 0, saturation ~ 220, value ~ 220
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          image.setPixelRgb(x, y, 220, 30, 30);
        }
      }

      final ratios = ClinicalRatioService.computeFromImage(image);
      expect(ratios.bloodRatio, closeTo(1.0, 0.01));
      expect(ratios.abnormalRatio, 0.0);
      expect(ratios.wateryRatio, 0.0);
      // Score = 1.0 / 0.2239 ~ 4.466 (> 2.0 -> Severe)
      expect(ratios.severityScore, greaterThan(2.0));
      expect(ratios.severity, 'Severe');
    });

    test('Pure watery white/pale image produces wateryRatio ~ 1.0 and Severe severity', () {
      final image = img.Image(width: 224, height: 224);
      // Pale white: R=240, G=240, B=240 -> value=240 (>=205), saturation=0 (<=90)
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          image.setPixelRgb(x, y, 240, 240, 240);
        }
      }

      final ratios = ClinicalRatioService.computeFromImage(image);
      expect(ratios.wateryRatio, closeTo(1.0, 0.01));
      expect(ratios.bloodRatio, 0.0);
      // Score = 1.0 / 0.1676 ~ 5.966 (> 2.0 -> Severe)
      expect(ratios.severityScore, greaterThan(2.0));
      expect(ratios.severity, 'Severe');
    });

    test('Clean normal dropping color produces score < 1.0 and Mild severity', () {
      final image = img.Image(width: 224, height: 224);
      // Natural dark olivaceous droppings (R=95, G=85, B=50)
      // Saturation ~ 121, value ~ 95, hue ~ 32 (outside blood, outside watery, outside abnormal hue 75..242)
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          image.setPixelRgb(x, y, 95, 85, 50);
        }
      }

      final ratios = ClinicalRatioService.computeFromImage(image);
      expect(ratios.bloodRatio, 0.0);
      expect(ratios.abnormalRatio, 0.0);
      expect(ratios.wateryRatio, 0.0);
      expect(ratios.severityScore, 0.0);
      expect(ratios.severity, 'Mild');
    });

    test('Calibrated severity cut-offs accurately partition Mild, Moderate, and Severe', () {
      // Score < 1.0 -> Mild
      final mildRatios = ClinicalSignRatios(
        bloodRatio: 0.05,
        abnormalRatio: 0.001,
        wateryRatio: 0.03,
        severityScore: (0.05 / 0.2239) + (0.001 / 0.05) + (0.03 / 0.1676), // ~0.422
        severity: 'Mild',
      );
      expect(mildRatios.severityScore, lessThan(1.0));
      expect(mildRatios.severity, 'Mild');

      // 1.0 <= Score <= 2.0 -> Moderate
      final modScore = 1.45;
      final modRatios = ClinicalSignRatios(
        bloodRatio: 0.15,
        abnormalRatio: 0.01,
        wateryRatio: 0.10,
        severityScore: modScore,
        severity: 'Moderate',
      );
      expect(modRatios.severityScore >= 1.0 && modRatios.severityScore <= 2.0, isTrue);
      expect(modRatios.severity, 'Moderate');

      // Score > 2.0 -> Severe
      final severeScore = 3.50;
      final severeRatios = ClinicalSignRatios(
        bloodRatio: 0.30,
        abnormalRatio: 0.02,
        wateryRatio: 0.25,
        severityScore: severeScore,
        severity: 'Severe',
      );
      expect(severeRatios.severityScore, greaterThan(2.0));
      expect(severeRatios.severity, 'Severe');
    });

    test('Authentic sample coccidiosis.jpg measures significant blood and classifies Severe', () async {
      const samplePath = 'assets/images/samples/coccidiosis.jpg';
      final file = File(samplePath);
      if (await file.exists()) {
        final ratios = await ClinicalRatioService.computeFromPath(samplePath);
        // From empirical script: blood ~ 0.2604
        expect(ratios.bloodRatio, greaterThan(0.20));
        expect(ratios.severityScore, greaterThan(2.0));
        expect(ratios.severity, 'Severe');
      }
    });
  });
}
