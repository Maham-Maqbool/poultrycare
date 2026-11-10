import 'package:shared_preferences/shared_preferences.dart';

/// SessionService manages persistent user session tokens, login states,
/// chosen UI locale, and onboarding completion flags.
class SessionService {
  static const String keyIsLoggedIn = 'session_is_logged_in';
  static const String keyIsGuest = 'session_is_guest';
  static const String keyUserId = 'session_user_id';
  static const String keyUserName = 'session_user_name';
  static const String keyUserEmail = 'session_user_email';
  static const String keyUserPhone = 'session_user_phone';
  static const String keyLocale = 'session_locale';
  static const String keyDarkMode = 'session_dark_mode';
  static const String keyOnboardingCompleted = 'session_onboarding_completed';
  static const String keyVetPhone = 'session_vet_phone';

  static final SessionService instance = SessionService._internal();
  SessionService._internal();
  factory SessionService() => instance;

  /// Returns true if the user has an active authenticated session.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  /// Returns true if user entered as a guest.
  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsGuest) ?? false;
  }

  /// Returns true if the user has already viewed the onboarding carousel.
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyOnboardingCompleted) ?? false;
  }

  /// Marks onboarding carousel as finished.
  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyOnboardingCompleted, true);
  }

  /// Persists authenticated user credentials and session flag.
  Future<void> saveUserSession({
    required String id,
    String? name,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setBool(keyIsGuest, false);
    await prefs.setString(keyUserId, id);
    await prefs.setString(keyUserName, name ?? 'Poultry Farmer');
    if (email != null) await prefs.setString(keyUserEmail, email);
    if (phone != null) await prefs.setString(keyUserPhone, phone);
  }

  /// Persists guest session.
  Future<void> saveGuestSession({required String id, String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setBool(keyIsGuest, true);
    await prefs.setString(keyUserId, id);
    await prefs.setString(keyUserName, name ?? 'Guest Farmer');
  }

  /// Retrieves cached user name.
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? 'Poultry Farmer';
  }

  /// Retrieves cached user ID.
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? 'usr-001';
  }

  /// Retrieves persisted locale ('ur' or 'en'). Defaults to 'ur' for farmers.
  Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLocale) ?? 'ur';
  }

  /// Persists chosen locale.
  Future<void> saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLocale, locale);
  }

  /// Retrieves dark mode setting.
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDarkMode) ?? false;
  }

  /// Persists dark mode setting.
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDarkMode, isDark);
  }

  /// Retrieves saved veterinarian phone number.
  Future<String?> getVetPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyVetPhone);
  }

  /// Persists veterinarian phone number.
  Future<void> saveVetPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyVetPhone, phone.trim());
  }

  /// Clears session upon logout.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyIsGuest);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserPhone);
  }
}
