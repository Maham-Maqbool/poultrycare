import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poultrycare/features/profile/controllers/settings_controller.dart';
import 'package:poultrycare/features/profile/views/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen renders all sections without throwing errors', (tester) async {
    final settingsCtrl = SettingsController();

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsController>.value(
        value: settingsCtrl,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Appearance & Language'), findsNothing); // default is Urdu
    expect(find.text('ظاہری شکل اور زبان'), findsOneWidget);
    expect(find.text('اپنے ویٹ کا نمبر (My Vet Number)'), findsOneWidget);
    expect(find.text('پرائیویسی اور اسٹوریج صفائی'), findsOneWidget);
    expect(find.text('کسٹمر سپورٹ اور ویٹرنری فیلڈ سروس'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SettingsScreen renders in English without errors', (tester) async {
    final settingsCtrl = SettingsController();
    settingsCtrl.setLocale('en');

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsController>.value(
        value: settingsCtrl,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Appearance & Language'), findsOneWidget);
    expect(find.text('My Veterinarian Contact'), findsOneWidget);
    expect(find.text('Privacy & Storage Hygiene'), findsOneWidget);
    expect(find.text('PoultryCare Support & Field Service'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SettingsScreen handles raw unnormalized locale ur_PK gracefully', (tester) async {
    final settingsCtrl = SettingsController();
    settingsCtrl.setLocale('ur_PK');

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsController>.value(
        value: settingsCtrl,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ظاہری شکل اور زبان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
