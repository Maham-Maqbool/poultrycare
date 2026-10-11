import 'package:flutter/material.dart';

/// SettingsController manages theme mode, localization (en/ur),
/// and temporary storage hygiene.
class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _locale = 'en';
  bool _imageRetentionConsent = false;
  int _cacheSizeKb = 4280;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get locale => _locale;
  bool get isUrdu => _locale == 'ur';
  bool get imageRetentionConsent => _imageRetentionConsent;
  int get cacheSizeKb => _cacheSizeKb;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(String lang) {
    _locale = lang;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale == 'en' ? 'ur' : 'en';
    notifyListeners();
  }

  void toggleConsent(bool value) {
    _imageRetentionConsent = value;
    notifyListeners();
  }

  Future<void> clearCache() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cacheSizeKb = 0;
    notifyListeners();
  }
}
