import 'package:flutter_test/flutter_test.dart';
import 'package:poultrycare/data/models/diagnostic_record.dart';
import 'package:poultrycare/data/models/prediction_model.dart';
import 'package:poultrycare/data/models/scan_model.dart';
import 'package:poultrycare/data/mock/mock_treatments_data.dart';
import 'package:poultrycare/services/disease_cause_service.dart';

void main() {
  group('DiseaseCauseService Unit & Integration Tests', () {
    test('Healthy specimen produces shouldShow == false and no checklist', () {
      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'healthy',
        currentSeverity: 'mild',
        wateryRatio: 0.25,
        bloodRatio: 0.30,
        scanDate: DateTime(2026, 8, 15), // Monsoon
      );

      expect(result.shouldShow, isFalse);
      expect(result.dynamicObservations, isEmpty);
      expect(result.checklistItems, isEmpty);
    });

    test('Coccidiosis in monsoon with wet and bloody dropping triggers all lines', () {
      final augustDate = DateTime(2026, 8, 10);
      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'coccidiosis',
        currentSeverity: 'severe',
        wateryRatio: 0.20, // > 0.1676
        bloodRatio: 0.25, // > 0.2239
        scanDate: augustDate,
      );

      expect(result.shouldShow, isTrue);
      expect(result.dynamicObservations.length, 3);

      // 1. Watery line
      expect(result.dynamicObservations[0].textEn, contains('Droppings are very watery'));
      expect(result.dynamicObservations[0].textUr, contains('بیٹھ بہت گیلی ہے'));

      // 2. Blood line
      expect(result.dynamicObservations[1].textEn, contains('Blood is high'));
      expect(result.dynamicObservations[1].textUr, contains('خون زیادہ ہے'));
      expect(result.dynamicObservations[1].isUrgent, isTrue);

      // 3. Monsoon line
      expect(result.dynamicObservations[2].textEn, contains('Rainy season is the most dangerous time'));
      expect(result.dynamicObservations[2].textUr, contains('بارش کا موسم اس بیماری کے لیے سب سے خطرناک ہوتا ہے'));

      // 4. Checklist: 6 exact items
      expect(result.checklistItems.length, 6);
      expect(result.checklistItems[0].textEn, contains('Damp litter'));
      expect(result.checklistItems[1].textEn, contains('Rainy season'));
      expect(result.checklistItems[2].textEn, contains('Age 6 to 10 weeks'));
      expect(result.checklistItems[3].textEn, contains('Floor litter system'));
      expect(result.checklistItems[4].textEn, contains('Feed medication deficiency'));
      expect(result.checklistItems[5].textEn, contains('Weakened immunity'));
    });

    test('Coccidiosis in November (outside monsoon) does NOT trigger monsoon line', () {
      final novemberDate = DateTime(2026, 11, 14);
      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'coccidiosis',
        currentSeverity: 'mild',
        wateryRatio: 0.05, // Normal
        bloodRatio: 0.02, // Normal
        scanDate: novemberDate,
      );

      expect(result.shouldShow, isTrue);
      expect(result.dynamicObservations, isEmpty); // No watery, blood, or monsoon
      expect(result.checklistItems.length, 6);
    });

    test('Newcastle disease gets vaccine check line and NO monsoon line even in August', () {
      final augustDate = DateTime(2026, 8, 15);
      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'newcastle',
        currentSeverity: 'severe',
        wateryRatio: 0.05,
        bloodRatio: 0.02,
        scanDate: augustDate,
      );

      expect(result.shouldShow, isTrue);
      expect(result.dynamicObservations, isEmpty); // Newcastle gets NO season line
      expect(result.checklistItems.isNotEmpty, isTrue);

      // First item must be vaccination check
      expect(result.checklistItems[0].textEn, contains('The biggest cause of this disease is missing vaccination'));
      expect(result.checklistItems[0].textUr, contains('اس بیماری کی سب سے بڑی وجہ ویکسین کا نہ ہونا ہوتا ہے'));
    });

    test('Salmonella gets library checklist and NO season line in August', () {
      final augustDate = DateTime(2026, 8, 15);
      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'salmonella',
        currentSeverity: 'moderate',
        wateryRatio: 0.05,
        bloodRatio: 0.02,
        scanDate: augustDate,
      );

      expect(result.shouldShow, isTrue);
      expect(result.dynamicObservations, isEmpty);
      expect(result.checklistItems.length, 4);
      expect(result.checklistItems[0].textEn, contains('Drinking water quality'));
    });

    test('Shed history: recurring disease within 30 days triggers recurrence line', () {
      final now = DateTime(2026, 11, 14);
      final prevDate = now.subtract(const Duration(days: 10));

      final prevScan = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-old-1',
          userId: 'usr-001',
          deviceId: 'dev-001',
          flockId: 'flk-shed-1',
          idempotencyKey: 'idemp-1',
          imagePath: 'assets/images/samples/coccidiosis.jpg',
          createdAt: prevDate,
        ),
        prediction: PredictionModel(
          id: 'prd-old-1',
          scanId: 'scn-old-1',
          predictedClass: 'coccidiosis',
          severity: 'mild',
          urgency: 'treat_today',
          createdAt: prevDate,
        ),
      );

      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'coccidiosis',
        currentSeverity: 'mild',
        scanDate: now,
        flockId: 'flk-shed-1',
        currentScanId: 'scn-current',
        shedScans: [prevScan],
      );

      expect(result.dynamicObservations.length, 1);
      expect(result.dynamicObservations[0].textEn, contains('This disease was found again in this shed'));
      expect(result.dynamicObservations[0].textUr, contains('اس شیڈ میں یہ بیماری دوبارہ ملی ہے'));
    });

    test('Shed history: rising severity triggers urgent vet line', () {
      final now = DateTime(2026, 11, 14);
      final prevDate = now.subtract(const Duration(days: 5));

      final prevScan = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-old-2',
          userId: 'usr-001',
          deviceId: 'dev-001',
          flockId: 'flk-shed-1',
          idempotencyKey: 'idemp-2',
          imagePath: 'assets/images/samples/coccidiosis.jpg',
          createdAt: prevDate,
        ),
        prediction: PredictionModel(
          id: 'prd-old-2',
          scanId: 'scn-old-2',
          predictedClass: 'coccidiosis',
          severity: 'moderate',
          urgency: 'treat_today',
          createdAt: prevDate,
        ),
      );

      final result = DiseaseCauseService.evaluate(
        diseaseCode: 'coccidiosis',
        currentSeverity: 'severe', // Risen from moderate to severe
        scanDate: now,
        flockId: 'flk-shed-1',
        currentScanId: 'scn-current',
        shedScans: [prevScan],
      );

      expect(result.dynamicObservations.length, 2);
      expect(result.dynamicObservations[0].textEn, contains('This disease was found again in this shed'));
      expect(result.dynamicObservations[1].textEn, contains('Severity is rising - see the vet immediately.'));
      expect(result.dynamicObservations[1].textUr, contains('شدت بڑھ رہی ہے - فوراً ڈاکٹر کو دکھائیں۔'));
      expect(result.dynamicObservations[1].isUrgent, isTrue);
    });

    test('Part A: Newcastle treatment cards in mock data lead with no cure and no antibiotics', () {
      final ncdTreatments = mockTreatmentsData.where((t) => t.diseaseCode == 'ncd').toList();
      expect(ncdTreatments.length, 3);

      for (final t in ncdTreatments) {
        // Must lead with no cure in EN and UR
        expect(t.medicinesEn.first, contains('There is no specific treatment for Newcastle disease - no medicine kills this virus.'));
        expect(t.medicinesUr.first, contains('رانی کھیت کا کوئی خاص علاج نہیں ہے - کوئی دوا اس وائرس کو ختم نہیں کرتی۔'));

        // All medicines must be supportive care only or official notifiable notification
        for (final med in t.medicinesEn) {
          expect(med.contains('Doxycycline'), isFalse);
          expect(med.contains('Colistin'), isFalse);
        }

        // Urgency must be vet_now and vetRequired must be true
        expect(t.vetRequired, isTrue);
        expect(t.urgency, 'vet_now');
      }
    });
  });
}
