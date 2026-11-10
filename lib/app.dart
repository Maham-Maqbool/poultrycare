import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_router.dart';
import 'features/profile/controllers/settings_controller.dart';

/// PoultryCareApp is the root MaterialApp widget for PoultryCare.
class PoultryCareApp extends StatelessWidget {
  const PoultryCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      title: 'PoultryCare',
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.locale),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ur', 'PK'),
        Locale('en'),
        Locale('ur'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
