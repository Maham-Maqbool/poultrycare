import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poultrycare/core/widgets/custom_button.dart';
import 'package:poultrycare/data/models/user_model.dart';
import 'package:poultrycare/data/repositories/auth_repository.dart';
import 'package:poultrycare/data/repositories/diagnostic_repository.dart';
import 'package:poultrycare/data/repositories/flock_repository.dart';
import 'package:poultrycare/features/auth/controllers/auth_controller.dart';
import 'package:poultrycare/features/auth/views/register_screen.dart';
import 'package:poultrycare/features/home/controllers/dashboard_controller.dart';
import 'package:poultrycare/features/profile/controllers/settings_controller.dart';
import 'package:poultrycare/features/profile/views/profile_screen.dart';
import 'package:poultrycare/routes/app_routes.dart';
import 'package:poultrycare/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Fix 1: No fabricated email on restoreSession and profile screen', () {
    test('Registered user restores own real email and never @poultrycare.farm', () async {
      final authRepo = AuthRepository();

      // Register new user with their real email
      await authRepo.register(
        name: 'Tariq Poultry',
        identifier: 'tariq@gmail.com',
        password: 'password123',
      );

      expect(authRepo.currentUser.displayName, 'Tariq Poultry');
      expect(authRepo.currentUser.email, 'tariq@gmail.com');

      // Create a fresh repository instance and restore session
      final freshRepo = AuthRepository();
      final restored = await freshRepo.restoreSession();

      expect(restored, isTrue);
      expect(freshRepo.currentUser.displayName, 'Tariq Poultry');
      expect(freshRepo.currentUser.email, 'tariq@gmail.com');
      expect(freshRepo.currentUser.email, isNot(contains('@poultrycare.farm')));
    });

    test('Registered phone user restores phone and null email (never invented email)', () async {
      final authRepo = AuthRepository();

      await authRepo.register(
        name: 'Ali Farm',
        identifier: '03001234567',
        password: 'password123',
      );

      final freshRepo = AuthRepository();
      final restored = await freshRepo.restoreSession();

      expect(restored, isTrue);
      expect(freshRepo.currentUser.displayName, 'Ali Farm');
      expect(freshRepo.currentUser.phone, '03001234567');
      expect(freshRepo.currentUser.email, isNull);
    });

    test('Demo account restores demo email farmer@poultrycare.farm', () async {
      final authRepo = AuthRepository();

      await authRepo.login(
        identifier: 'farmer@poultrycare.farm',
        password: 'password123',
      );

      final freshRepo = AuthRepository();
      final restored = await freshRepo.restoreSession();

      expect(restored, isTrue);
      expect(freshRepo.currentUser.id, 'usr-001');
      expect(freshRepo.currentUser.email, 'farmer@poultrycare.farm');
    });

    testWidgets('ProfileScreen strips any " in <email>" suffix from name line and shows real email underneath', (tester) async {
      final authRepo = AuthRepository();

      // Simulate a user who has a suffix in display name
      final testUser = UserModel(
        id: 'usr-test-123',
        displayName: 'Tariq Poultry in tariq@poultrycare.farm',
        email: 'tariq@gmail.com',
        role: 'farmer',
        locale: 'en',
        createdAt: DateTime.now(),
      );

      final authController = AuthController(authRepo);
      // Log in as testUser through repo internal state by saving session and restoring
      await SessionService.instance.saveUserSession(
        id: testUser.id,
        name: testUser.displayName,
        email: testUser.email,
      );
      await SessionService.instance.saveRegisteredUser(
        id: testUser.id,
        name: testUser.displayName!,
        identifier: testUser.email!,
        password: 'pass',
        consent: true,
        email: testUser.email,
      );
      await authRepo.restoreSession();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<DashboardController>(
              create: (_) => DashboardController(DiagnosticRepository(), FlockRepository()),
            ),
            ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Display name line must show ONLY "Tariq Poultry" without " in ..."
      expect(find.text('Tariq Poultry'), findsOneWidget);
      expect(find.text('Tariq Poultry in tariq@poultrycare.farm'), findsNothing);

      // Real email underneath
      expect(find.text('tariq@gmail.com'), findsOneWidget);

      // No fabricated address text anywhere on the screen
      expect(find.textContaining('tariq@poultrycare.farm'), findsNothing);
    });
  });

  group('Fix 2: Remove image consent from registration', () {
    testWidgets('RegisterScreen has no consent card or checkbox and registers normally', (tester) async {
      final authRepo = AuthRepository();
      final authController = AuthController(authRepo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: authController),
            ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
          ],
          child: MaterialApp(
            home: const RegisterScreen(),
            routes: {
              AppRoutes.mainShell: (_) => const Scaffold(body: Text('MainShell')),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no consent card or consent text exists on screen
      expect(find.text('Consent for Image Improvement'), findsNothing);
      expect(find.text('تصویری تشخیص کی بہتری کی اجازت'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);

      // Form fields exist
      expect(find.byType(TextField), findsNWidgets(3)); // name, identifier, password

      // Fill form and register
      await tester.enterText(find.byType(TextField).at(0), 'Bilal Broilers');
      await tester.enterText(find.byType(TextField).at(1), 'bilal@gmail.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123');

      // Tap register button
      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      expect(authRepo.currentUser.displayName, 'Bilal Broilers');
      expect(authRepo.currentUser.email, 'bilal@gmail.com');
      expect(authRepo.currentUser.consentToRetainImages, isTrue);
    });
  });
}
