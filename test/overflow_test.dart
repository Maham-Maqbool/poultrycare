import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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
import 'package:poultrycare/features/home/views/main_shell_screen.dart';
import 'package:poultrycare/features/home/views/home_dashboard_screen.dart';
import 'package:poultrycare/features/scanner/views/scanner_screen.dart';
import 'package:poultrycare/features/scanner/views/diagnostic_result_screen.dart';
import 'package:poultrycare/features/flocks/views/flocks_list_screen.dart';
import 'package:poultrycare/features/history/views/scan_history_screen.dart';
import 'package:poultrycare/features/profile/views/settings_screen.dart';

Widget createTestApp(Widget child, {bool isUrdu = false, Size size = const Size(360, 640)}) {
  final authRepo = AuthRepository();
  final flockRepo = FlockRepository();
  final diseaseRepo = DiseaseRepository();
  final diagRepo = DiagnosticRepository();

  final settingsCtrl = SettingsController();
  if (isUrdu) {
    settingsCtrl.setLocale('ur');
  }

  return MultiProvider(
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
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test MainShellScreen for overflow in English (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const MainShellScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test MainShellScreen for overflow in Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const MainShellScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test HomeDashboardScreen for overflow in English (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const HomeDashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test HomeDashboardScreen for overflow in Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const HomeDashboardScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test ScannerScreen for overflow in English (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const ScannerScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test ScannerScreen for overflow in Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const ScannerScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test DiagnosticResultScreen for overflow in English (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const DiagnosticResultScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test DiagnosticResultScreen for overflow in Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const DiagnosticResultScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test FlocksListScreen for overflow in English and Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const FlocksListScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test ScanHistoryScreen for overflow in English and Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const ScanHistoryScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test SettingsScreen for overflow in English and Urdu (360x640)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestApp(const SettingsScreen(), isUrdu: true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
