import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poultrycare/app.dart';
import 'package:poultrycare/core/widgets/app_image_view.dart';
import 'package:poultrycare/data/repositories/auth_repository.dart';
import 'package:poultrycare/data/repositories/flock_repository.dart';
import 'package:poultrycare/data/repositories/disease_repository.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/features/auth/controllers/auth_controller.dart';
import 'package:poultrycare/features/flocks/controllers/flock_controller.dart';
import 'package:poultrycare/features/scanner/controllers/scanner_controller.dart';
import 'package:poultrycare/features/home/controllers/dashboard_controller.dart';
import 'package:poultrycare/features/home/views/home_dashboard_screen.dart';
import 'package:poultrycare/features/home/views/main_shell_screen.dart';
import 'package:poultrycare/features/history/controllers/history_controller.dart';
import 'package:poultrycare/features/profile/controllers/settings_controller.dart';
import 'package:poultrycare/data/models/diagnostic_record.dart';
import 'package:poultrycare/data/models/scan_model.dart';
import 'package:poultrycare/data/models/prediction_model.dart';
import 'package:poultrycare/features/scanner/views/diagnostic_result_screen.dart';

void main() {
  testWidgets('PoultryCare app launches and renders branding', (WidgetTester tester) async {
    final authRepo = AuthRepository();
    final flockRepo = FlockRepository();
    final diseaseRepo = DiseaseRepository();
    final diagnosticRepo = DiagnosticRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepo),
          Provider<FlockRepository>.value(value: flockRepo),
          Provider<DiseaseRepository>.value(value: diseaseRepo),
          Provider<DiagnosticRepository>.value(value: diagnosticRepo),
          ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
          ChangeNotifierProvider(create: (_) => FlockController(flockRepo)),
          ChangeNotifierProvider(create: (_) => ScannerController(diagnosticRepo, diseaseRepo)),
          ChangeNotifierProvider(create: (_) => DashboardController(diagnosticRepo, flockRepo)),
          ChangeNotifierProvider(create: (_) => HistoryController(diagnosticRepo)),
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
        child: const PoultryCareApp(),
      ),
    );

    expect(find.text('PoultryCare Pro'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('MainShellScreen renders HomeDashboardScreen with cards and quick actions', (WidgetTester tester) async {
    final authRepo = AuthRepository();
    final flockRepo = FlockRepository();
    final diseaseRepo = DiseaseRepository();
    final diagnosticRepo = DiagnosticRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepo),
          Provider<FlockRepository>.value(value: flockRepo),
          Provider<DiseaseRepository>.value(value: diseaseRepo),
          Provider<DiagnosticRepository>.value(value: diagnosticRepo),
          ChangeNotifierProvider(create: (_) => AuthController(authRepo)),
          ChangeNotifierProvider(create: (_) => FlockController(flockRepo)),
          ChangeNotifierProvider(create: (_) => ScannerController(diagnosticRepo, diseaseRepo)),
          ChangeNotifierProvider(create: (_) => DashboardController(diagnosticRepo, flockRepo)),
          ChangeNotifierProvider(create: (_) => HistoryController(diagnosticRepo)),
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
        child: const MaterialApp(
          home: MainShellScreen(initialTab: 0),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
    expect(find.text('PoultryCare Pro'), findsWidgets);
    expect(find.byIcon(Icons.egg_alt_rounded), findsOneWidget);
  });

  testWidgets('AppImageView renders graceful specimen placeholder when empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppImageView(imagePath: null, width: 80, height: 80),
        ),
      ),
    );

    expect(find.text('Poultry Specimen'), findsOneWidget);
    expect(find.byIcon(Icons.biotech_rounded), findsOneWidget);
  });

  testWidgets('AppImageView safely handles double.infinity width without Infinity toInt error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppImageView(
            imagePath: 'assets/images/sample_coccidiosis.jpg',
            width: double.infinity,
            height: 220,
          ),
        ),
      ),
    );

    expect(find.byType(AppImageView), findsOneWidget);
  });

  test('ScannerController manages specimen selection and triage synthesis', () async {
    final diseaseRepo = DiseaseRepository();
    final diagnosticRepo = DiagnosticRepository();
    final controller = ScannerController(diagnosticRepo, diseaseRepo);

    // Quality checks start at notChecked, isImageValid is false
    expect(controller.isImageValid, isFalse);
    expect(controller.lightingPassed, isFalse);
    expect(controller.sharpnessPassed, isFalse);
    controller.selectSampleImage('assets/images/samples/coccidiosis.jpg', targetDisease: 'coccidiosis');
    expect(controller.selectedImagePath, 'assets/images/samples/coccidiosis.jpg');
    expect(controller.forcedDisease, isNull); // Major 2: Model classifies demo samples organically

    controller.setFlockSignals(
      lethargy: 'Over 10% of birds',
      intakeDrop: 'Severely dropped',
      suddenMortality: 'Multiple birds died',
    );
    expect(controller.suddenMortality, 'Multiple birds died');
  });

  test('DiagnosticRepository executes diagnosis with triage escalation', () async {
    final diagnosticRepo = DiagnosticRepository();
    final record = await diagnosticRepo.runDiagnosis(
      imagePath: 'assets/images/sample.jpg',
      flockSignals: {
        'lethargy': 'Over 10% of birds',
        'intakeDrop': 'Normal',
        'suddenMortality': 'Multiple birds died',
      },
      forcedDisease: 'coccidiosis',
    );

    expect(record.prediction.predictedClass, 'coccidiosis');
    expect(record.prediction.severity, 'severe');
    expect(record.prediction.urgency, 'vet_now');
    expect(record.prediction.probabilities.isNotEmpty, isTrue);
  });

  test('DiagnosticRepository preserves Healthy specimen severity as mild and urgency as monitor', () async {
    final diagnosticRepo = DiagnosticRepository();
    final record = await diagnosticRepo.runDiagnosis(
      imagePath: 'assets/images/samples/healthy.png',
      flockSignals: {
        'lethargy': 'Under 10% of birds',
        'intakeDrop': 'Reduced slightly',
        'suddenMortality': '1 to 2 birds died',
      },
      forcedDisease: 'healthy',
    );

    expect(record.prediction.predictedClass, 'healthy');
    expect(record.prediction.severity, 'mild');
    expect(record.prediction.urgency, 'monitor');
  });

  testWidgets('DiagnosticResultScreen displays MILD and MONITOR for Healthy specimen', (WidgetTester tester) async {
    final authRepo = AuthRepository();
    final flockRepo = FlockRepository();
    final diseaseRepo = DiseaseRepository();
    final diagRepo = DiagnosticRepository();
    final settingsCtrl = SettingsController();
    settingsCtrl.setLocale('en');

    final now = DateTime.now();
    final healthyRecord = DiagnosticRecord(
      scan: ScanModel(
        id: 'scn-test-healthy',
        userId: 'usr-001',
        deviceId: 'dev-001',
        imagePath: 'assets/images/samples/healthy.png',
        idempotencyKey: 'idem-test-healthy',
        createdAt: now,
      ),
      prediction: PredictionModel(
        id: 'prd-test-healthy',
        scanId: 'scn-test-healthy',
        modelVersionId: 'PC-VisionAI-v2.4',
        predictedClass: 'healthy',
        probabilities: {'healthy': 0.98},
        calibratedConfidence: 0.98,
        certainty: 'high',
        conformalSet: ['healthy'],
        abstained: false,
        severity: 'mild',
        urgency: 'monitor',
        triageRules: const [],
        flockSignals: const {},
        decodeMs: 10,
        preprocessMs: 10,
        inferenceMs: 20,
        totalMs: 40,
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

    expect(find.text('MILD'), findsOneWidget);
    expect(find.text('MONITOR'), findsOneWidget);
    expect(find.text('TREAT TODAY'), findsNothing);
  });

  testWidgets('DiagnosticResultScreen displays SEVERE and VET NOW for Severe Coccidiosis', (WidgetTester tester) async {
    final authRepo = AuthRepository();
    final flockRepo = FlockRepository();
    final diseaseRepo = DiseaseRepository();
    final diagRepo = DiagnosticRepository();
    final settingsCtrl = SettingsController();
    settingsCtrl.setLocale('en');

    final now = DateTime.now();
    final cocciRecord = DiagnosticRecord(
      scan: ScanModel(
        id: 'scn-test-cocci',
        userId: 'usr-001',
        deviceId: 'dev-001',
        imagePath: 'assets/images/samples/coccidiosis.jpg',
        idempotencyKey: 'idem-test-cocci',
        createdAt: now,
      ),
      prediction: PredictionModel(
        id: 'prd-test-cocci',
        scanId: 'scn-test-cocci',
        modelVersionId: 'PC-VisionAI-v2.4',
        predictedClass: 'coccidiosis',
        probabilities: {'coccidiosis': 0.98},
        calibratedConfidence: 0.98,
        certainty: 'high',
        conformalSet: ['coccidiosis'],
        abstained: false,
        severity: 'severe',
        urgency: 'vet_now',
        triageRules: const [],
        flockSignals: const {},
        decodeMs: 10,
        preprocessMs: 10,
        inferenceMs: 20,
        totalMs: 40,
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

    expect(find.text('SEVERE'), findsWidgets);
    expect(find.text('VET NOW'), findsOneWidget);
    expect(find.text('TREAT TODAY'), findsNothing);
  });
}
