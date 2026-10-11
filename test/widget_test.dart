import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poultrycare/app.dart';
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

    expect(find.text('PoultryCare'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
