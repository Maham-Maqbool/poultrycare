import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poultrycare/core/constants/app_colors.dart';
import 'package:poultrycare/data/mock/mock_treatments_data.dart';
import 'package:poultrycare/data/models/diagnostic_record.dart';
import 'package:poultrycare/data/models/scan_model.dart';
import 'package:poultrycare/data/models/prediction_model.dart';
import 'package:poultrycare/data/repositories/auth_repository.dart';
import 'package:poultrycare/data/repositories/flock_repository.dart';
import 'package:poultrycare/data/repositories/disease_repository.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/features/auth/controllers/auth_controller.dart';
import 'package:poultrycare/features/flocks/controllers/flock_controller.dart';
import 'package:poultrycare/features/scanner/controllers/scanner_controller.dart';
import 'package:poultrycare/features/home/controllers/dashboard_controller.dart';
import 'package:poultrycare/features/history/controllers/history_controller.dart';
import 'package:poultrycare/features/profile/controllers/settings_controller.dart';
import 'package:poultrycare/features/scanner/views/diagnostic_result_screen.dart';
import 'package:poultrycare/services/clinical_ratio_service.dart';
import 'package:poultrycare/services/cause_checklist_service.dart';

void main() {
  group('Addendum 8 Part A: Newcastle (Rani Khait) Treatment Protocols', () {
    test('All 3 tiers of Newcastle lead with no-cure statement in EN and UR', () {
      final ncdTreatments = mockTreatmentsData
          .where((t) => t.diseaseCode == 'ncd' || t.diseaseCode == 'newcastle')
          .toList();

      expect(ncdTreatments.length, 3);

      for (final trt in ncdTreatments) {
        expect(trt.medicinesEn.first,
            'There is no specific treatment for Newcastle disease: no medicine kills this virus.');
        expect(trt.medicinesUr.first,
            'رانی کھیت کا کوئی خاص علاج نہیں ہے: کوئی دوا اس وائرس کو ختم نہیں کرتی۔');
        expect(trt.vetRequired, isTrue);
        expect(trt.urgency, 'vet_now');

        // Confirm all other medicines are labelled as supportive care only or emergency vaccine
        for (int i = 1; i < trt.medicinesEn.length; i++) {
          final medEn = trt.medicinesEn[i].toLowerCase();
          final isSupportive = medEn.contains('supportive') ||
              medEn.contains('emergency') ||
              medEn.contains('critical');
          expect(isSupportive, isTrue,
              reason: 'Medication should be supportive care only: ${trt.medicinesEn[i]}');
        }
      }
    });

    test('Doxycycline + Colistin is completely removed from trt-ncd-02 and no antibiotics in NCD', () {
      final ncdModerate = mockTreatmentsData.firstWhere((t) => t.id == 'trt-ncd-02');

      for (final med in ncdModerate.medicinesEn) {
        expect(med.toLowerCase().contains('doxycycline'), isFalse);
        expect(med.toLowerCase().contains('colistin'), isFalse);
        expect(med.toLowerCase().contains('antibiotic'), isFalse);
      }
      for (final med in ncdModerate.medicinesUr) {
        expect(med.contains('ڈوکسی سائیکلین'), isFalse);
        expect(med.contains('کولسٹین'), isFalse);
      }
    });

    test('Emergency vaccination note is restricted to vet permission for healthy birds only', () {
      final ncdMild = mockTreatmentsData.firstWhere((t) => t.id == 'trt-ncd-01');
      final vaccineEn = ncdMild.medicinesEn.firstWhere((m) => m.toLowerCase().contains('lasota'));
      final vaccineUr = ncdMild.medicinesUr.firstWhere((m) => m.contains('لیسوٹا'));

      expect(vaccineEn.toLowerCase().contains('never for sick birds'), isTrue);
      expect(vaccineUr.contains('بیمار پرندوں کے لیے ہرگز نہیں'), isTrue);
    });
  });

  group('Addendum 8 Part B: CauseChecklistService Unit Tests', () {
    test('Healthy specimen produces empty cause checklist result', () {
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'healthy',
        severity: 'mild',
        clinicalRatios: const ClinicalSignRatios(
          bloodRatio: 0.01,
          abnormalRatio: 0.01,
          wateryRatio: 0.01,
          severityScore: 0.1,
          severity: 'Mild',
        ),
      );

      expect(result.shouldDisplay, isFalse);
      expect(result.hasSigns, isFalse);
      expect(result.hasChecklist, isFalse);
      expect(result.observedSigns, isEmpty);
      expect(result.checklistItems, isEmpty);
    });

    test('Coccidiosis with wet dropping triggers watery ratio sign', () {
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'coccidiosis',
        severity: 'moderate',
        clinicalRatios: const ClinicalSignRatios(
          bloodRatio: 0.10, // below 0.2239
          abnormalRatio: 0.01,
          wateryRatio: 0.25, // above 0.1676
          severityScore: 1.5,
          severity: 'Moderate',
        ),
        dateOverride: DateTime(2026, 11, 14), // November: non-monsoon
      );

      expect(result.shouldDisplay, isTrue);
      expect(result.observedSigns.length, 1);
      expect(
        result.observedSigns.first.textEn,
        'Droppings are very watery: check heat stress and water intake first.',
      );
      expect(
        result.observedSigns.first.textUr,
        'Droppings بہت گیلی ہیں: پہلے گرمی اور پانی کا استعمال چیک کرو۔',
      );
      // 6 static items for Coccidiosis
      expect(result.checklistItems.length, 6);
    });

    test('Coccidiosis in monsoon season (August) triggers monsoon line', () {
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'coccidiosis',
        severity: 'mild',
        clinicalRatios: const ClinicalSignRatios(
          bloodRatio: 0.05,
          abnormalRatio: 0.01,
          wateryRatio: 0.05,
          severityScore: 0.5,
          severity: 'Mild',
        ),
        dateOverride: DateTime(2026, 8, 15), // August: Monsoon!
      );

      expect(result.isMonsoonActive, isTrue);
      expect(result.observedSigns.any((s) => s.textEn.contains('Rainy season')), isTrue);
      expect(result.observedSigns.any((s) => s.textUr.contains('بارش کا موسم')), isTrue);
    });

    test('Coccidiosis in November does NOT trigger monsoon line', () {
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'coccidiosis',
        severity: 'mild',
        clinicalRatios: const ClinicalSignRatios(
          bloodRatio: 0.05,
          abnormalRatio: 0.01,
          wateryRatio: 0.05,
          severityScore: 0.5,
          severity: 'Mild',
        ),
        dateOverride: DateTime(2026, 11, 14), // November: non-monsoon
      );

      expect(result.isMonsoonActive, isFalse);
      expect(result.observedSigns.any((s) => s.textEn.contains('Rainy season')), isFalse);
    });

    test('Newcastle in monsoon (August) gets NO monsoon line', () {
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'newcastle',
        severity: 'severe',
        clinicalRatios: const ClinicalSignRatios(
          bloodRatio: 0.05,
          abnormalRatio: 0.01,
          wateryRatio: 0.05,
          severityScore: 0.5,
          severity: 'Mild',
        ),
        dateOverride: DateTime(2026, 8, 15), // August
      );

      expect(result.observedSigns.any((s) => s.textEn.contains('Rainy season')), isFalse);
      expect(result.checklistItems.first.textEn,
          'The biggest cause of this disease is missing vaccination: check your vaccination record.');
    });

    test('Repeat disease in same shed in last 30 days triggers recurrence sign', () {
      final now = DateTime(2026, 11, 14);
      final pastRecord = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-past-1',
          userId: 'usr-1',
          deviceId: 'dev-1',
          flockId: 'flock-shed-A',
          imagePath: 'assets/images/samples/coccidiosis.jpg',
          idempotencyKey: 'idem-1',
          createdAt: now.subtract(const Duration(days: 10)),
        ),
        prediction: PredictionModel(
          id: 'prd-past-1',
          scanId: 'scn-past-1',
          predictedClass: 'coccidiosis',
          severity: 'mild',
          createdAt: now.subtract(const Duration(days: 10)),
        ),
      );

      final result = CauseChecklistService.evaluate(
        diseaseCode: 'coccidiosis',
        severity: 'mild',
        flockId: 'flock-shed-A',
        currentScanId: 'scn-current',
        historicalRecords: [pastRecord],
        dateOverride: now,
      );

      expect(result.hasRepeatInShed, isTrue);
      expect(result.observedSigns.any((s) => s.textEn.contains('keeps coming back in this shed')), isTrue);
      expect(result.observedSigns.any((s) => s.textUr.contains('اس شیڈ میں یہ بیماری بار بار آ رہی ہے')), isTrue);
    });

    test('Severity rising across shed history strengthens the vet line', () {
      final now = DateTime(2026, 11, 14);
      final pastRecord = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-past-mild',
          userId: 'usr-1',
          deviceId: 'dev-1',
          flockId: 'flock-shed-B',
          imagePath: 'assets/images/samples/coccidiosis.jpg',
          idempotencyKey: 'idem-2',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        prediction: PredictionModel(
          id: 'prd-past-mild',
          scanId: 'scn-past-mild',
          predictedClass: 'coccidiosis',
          severity: 'mild',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      );

      // Current scan is Severe
      final result = CauseChecklistService.evaluate(
        diseaseCode: 'coccidiosis',
        severity: 'severe',
        flockId: 'flock-shed-B',
        currentScanId: 'scn-current',
        historicalRecords: [pastRecord],
        dateOverride: now,
      );

      expect(result.isSeverityRising, isTrue);
      expect(result.observedSigns.any((s) => s.textEn.contains('Severity is rising: see the vet immediately')), isTrue);
      expect(result.observedSigns.any((s) => s.textUr.contains('شدت بڑھ رہی ہے: فوراً ڈاکٹر کو دکھائیں')), isTrue);
    });
  });

  group('Addendum 8 Part B: DiagnosticResultScreen Widget Tests', () {
    testWidgets('DiagnosticResultScreen displays Kyun hua hoga section for Coccidiosis', (WidgetTester tester) async {
      final authRepo = AuthRepository();
      final flockRepo = FlockRepository();
      final diseaseRepo = DiseaseRepository();
      final diagRepo = DiagnosticRepository();
      final settingsCtrl = SettingsController();
      settingsCtrl.setLocale('en');

      final now = DateTime.now();
      final cocciRecord = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-widget-cocci',
          userId: 'usr-001',
          deviceId: 'dev-001',
          imagePath: 'assets/images/samples/coccidiosis.jpg',
          idempotencyKey: 'idem-widget-cocci',
          createdAt: now,
        ),
        prediction: PredictionModel(
          id: 'prd-widget-cocci',
          scanId: 'scn-widget-cocci',
          predictedClass: 'coccidiosis',
          severity: 'severe',
          urgency: 'vet_now',
          clinicalRatios: const ClinicalSignRatios(
            bloodRatio: 0.30, // above 0.2239
            abnormalRatio: 0.01,
            wateryRatio: 0.20, // above 0.1676
            severityScore: 2.8,
            severity: 'Severe',
          ),
          createdAt: now,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: authRepo),
            Provider<FlockRepository>.value(value: flockRepo),
            Provider<DiseaseRepository>.value(value: diseaseRepo),
            Provider<DiagnosticRepository>.value(value: diagRepo),
            ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
            ChangeNotifierProvider(create: (_) => FlockController(flockRepo)),
            ChangeNotifierProvider(create: (_) => ScannerController(diagRepo, diseaseRepo)),
            ChangeNotifierProvider(create: (_) => DashboardController(diagRepo, flockRepo)),
            ChangeNotifierProvider(create: (_) => HistoryController(diagRepo)),
            ChangeNotifierProvider<SettingsController>.value(value: settingsCtrl),
          ],
          child: MaterialApp(
            home: DiagnosticResultScreen(initialRecord: cocciRecord),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Why it may have happened: signs and checklist'), findsOneWidget);
      expect(find.text('Check These First (Field Checklist)'), findsOneWidget);
      expect(find.textContaining('Wet litter'), findsOneWidget);
    });

    testWidgets('DiagnosticResultScreen HIDES Kyun hua hoga section for Healthy specimen', (WidgetTester tester) async {
      final authRepo = AuthRepository();
      final flockRepo = FlockRepository();
      final diseaseRepo = DiseaseRepository();
      final diagRepo = DiagnosticRepository();
      final settingsCtrl = SettingsController();
      settingsCtrl.setLocale('en');

      final now = DateTime.now();
      final healthyRecord = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-widget-healthy',
          userId: 'usr-001',
          deviceId: 'dev-001',
          imagePath: 'assets/images/samples/healthy.png',
          idempotencyKey: 'idem-widget-healthy',
          createdAt: now,
        ),
        prediction: PredictionModel(
          id: 'prd-widget-healthy',
          scanId: 'scn-widget-healthy',
          predictedClass: 'healthy',
          severity: 'mild',
          urgency: 'monitor',
          createdAt: now,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: authRepo),
            Provider<FlockRepository>.value(value: flockRepo),
            Provider<DiseaseRepository>.value(value: diseaseRepo),
            Provider<DiagnosticRepository>.value(value: diagRepo),
            ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
            ChangeNotifierProvider(create: (_) => FlockController(flockRepo)),
            ChangeNotifierProvider(create: (_) => ScannerController(diagRepo, diseaseRepo)),
            ChangeNotifierProvider(create: (_) => DashboardController(diagRepo, flockRepo)),
            ChangeNotifierProvider(create: (_) => HistoryController(diagRepo)),
            ChangeNotifierProvider<SettingsController>.value(value: settingsCtrl),
          ],
          child: MaterialApp(
            home: DiagnosticResultScreen(initialRecord: healthyRecord),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Why it may have happened: signs and checklist'), findsNothing);
      expect(find.text('کیوں ہوا ہوگا: اشارے اور چیک لسٹ'), findsNothing);
      expect(find.text('No Medication Needed'), findsOneWidget);
    });

    testWidgets('Newcastle Result Screen leads with no-cure statement and supportive care', (WidgetTester tester) async {
      final authRepo = AuthRepository();
      final flockRepo = FlockRepository();
      final diseaseRepo = DiseaseRepository();
      final diagRepo = DiagnosticRepository();
      final settingsCtrl = SettingsController();
      settingsCtrl.setLocale('en');

      final now = DateTime.now();
      final ncdRecord = DiagnosticRecord(
        scan: ScanModel(
          id: 'scn-widget-ncd',
          userId: 'usr-001',
          deviceId: 'dev-001',
          imagePath: 'assets/images/samples/newcastle.jpg',
          idempotencyKey: 'idem-widget-ncd',
          createdAt: now,
        ),
        prediction: PredictionModel(
          id: 'prd-widget-ncd',
          scanId: 'scn-widget-ncd',
          predictedClass: 'newcastle',
          severity: 'severe',
          urgency: 'vet_now',
          createdAt: now,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: authRepo),
            Provider<FlockRepository>.value(value: flockRepo),
            Provider<DiseaseRepository>.value(value: diseaseRepo),
            Provider<DiagnosticRepository>.value(value: diagRepo),
            ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
            ChangeNotifierProvider(create: (_) => FlockController(flockRepo)),
            ChangeNotifierProvider(create: (_) => ScannerController(diagRepo, diseaseRepo)),
            ChangeNotifierProvider(create: (_) => DashboardController(diagRepo, flockRepo)),
            ChangeNotifierProvider(create: (_) => HistoryController(diagRepo)),
            ChangeNotifierProvider<SettingsController>.value(value: settingsCtrl),
          ],
          child: MaterialApp(
            home: DiagnosticResultScreen(initialRecord: ncdRecord),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Supportive Care Only (No Cure for Virus)'), findsOneWidget);
      expect(find.textContaining('There is no specific treatment for Newcastle disease'), findsWidgets);
      expect(find.text('VET NOW'), findsOneWidget);
    });
  });
}
