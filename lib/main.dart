import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/flock_repository.dart';
import 'data/repositories/disease_repository.dart';
import 'data/repositories/diagnostic_repository.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/flocks/controllers/flock_controller.dart';
import 'features/scanner/controllers/scanner_controller.dart';
import 'features/home/controllers/dashboard_controller.dart';
import 'features/history/controllers/history_controller.dart';
import 'features/profile/controllers/settings_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Repositories
  final authRepository = AuthRepository();
  final flockRepository = FlockRepository();
  final diseaseRepository = DiseaseRepository();
  final diagnosticRepository = DiagnosticRepository();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>.value(value: authRepository),
        Provider<FlockRepository>.value(value: flockRepository),
        Provider<DiseaseRepository>.value(value: diseaseRepository),
        Provider<DiagnosticRepository>.value(value: diagnosticRepository),

        // Controllers
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FlockController(flockRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ScannerController(diagnosticRepository, diseaseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardController(diagnosticRepository, flockRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(diagnosticRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(),
        ),
      ],
      child: const PoultryCareApp(),
    ),
  );
}
