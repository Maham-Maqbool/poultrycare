import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/onboarding_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/register_screen.dart';
import '../features/home/views/main_shell_screen.dart';
import '../features/scanner/views/scanner_screen.dart';
import '../features/scanner/views/diagnostic_result_screen.dart';
import '../features/flocks/views/flocks_list_screen.dart';
import '../features/history/views/scan_history_screen.dart';
import '../features/encyclopedia/views/disease_library_screen.dart';
import '../features/profile/views/settings_screen.dart';

/// AppRouter defines the declarative route generation for PoultryCare.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.mainShell:
        final tab = settings.arguments as int? ?? 0;
        return MaterialPageRoute(builder: (_) => MainShellScreen(initialTab: tab));

      case AppRoutes.scanner:
        return MaterialPageRoute(builder: (_) => const ScannerScreen());

      case AppRoutes.diagnosticResult:
        return MaterialPageRoute(builder: (_) => const DiagnosticResultScreen());

      case AppRoutes.flocks:
        return MaterialPageRoute(builder: (_) => const FlocksListScreen());

      case AppRoutes.history:
        return MaterialPageRoute(builder: (_) => const ScanHistoryScreen());

      case AppRoutes.encyclopedia:
        return MaterialPageRoute(builder: (_) => const DiseaseLibraryScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
