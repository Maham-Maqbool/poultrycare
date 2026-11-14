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
  String? _vetPhone;

  SettingsController() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get locale => _locale;
  bool get isUrdu => _locale == 'ur';
  bool get imageRetentionConsent => _imageRetentionConsent;
  int get cacheSizeKb => _cacheSizeKb;
  String? get vetPhone => _vetPhone;

  Future<void> _loadPreferences() async {
    final savedLocale = await _sessionService.getLocale();
    final savedDark = await _sessionService.isDarkMode();
    final savedVetPhone = await _sessionService.getVetPhone();
    _locale = savedLocale.startsWith('ur') ? 'ur' : 'en';
    _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
    _vetPhone = savedVetPhone;
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
    _locale = lang.startsWith('ur') ? 'ur' : 'en';
    _sessionService.saveLocale(_locale);
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

  Future<bool> saveVetPhone(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      _vetPhone = null;
      await _sessionService.saveVetPhone('');
      notifyListeners();
      return true;
    }

    // Clean formatting characters
    String digits = trimmed.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (digits.startsWith('92') && digits.length >= 12) {
      digits = '0${digits.substring(2)}';
    }

    // Validate 10 to 11 digits
    if (!RegExp(r'^\d{10,11}$').hasMatch(digits)) {
      return false;
    }

    _vetPhone = trimmed;
    await _sessionService.saveVetPhone(_vetPhone!);
    notifyListeners();
    return true;
  }
}
