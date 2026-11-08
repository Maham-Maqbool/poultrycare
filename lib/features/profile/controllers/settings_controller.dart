import 'package:flutter/material.dart';
import '../../../services/session_service.dart';

/// SettingsController manages theme mode, persistent localization (en/ur),
/// and temporary storage hygiene for commercial poultry farmers.
class SettingsController extends ChangeNotifier {
  final SessionService _sessionService = SessionService.instance;
  ThemeMode _themeMode = ThemeMode.light;
  String _locale = 'ur'; // Default to Urdu for rural farmer accessibility
  bool _imageRetentionConsent = true;
  int _cacheSizeKb = 4280;

  SettingsController() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get locale => _locale;
  bool get isUrdu => _locale == 'ur';
  bool get imageRetentionConsent => _imageRetentionConsent;
  int get cacheSizeKb => _cacheSizeKb;

  Future<void> _loadPreferences() async {
    final savedLocale = await _sessionService.getLocale();
    final savedDark = await _sessionService.isDarkMode();
    _locale = savedLocale;
    _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _sessionService.saveDarkMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _sessionService.saveDarkMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  void setLocale(String lang) {
    _locale = lang;
    _sessionService.saveLocale(lang);
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale == 'en' ? 'ur' : 'en';
    _sessionService.saveLocale(_locale);
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
