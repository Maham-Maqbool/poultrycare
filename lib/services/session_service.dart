import 'dart:convert';
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
  static const String keyRegisteredUsers = 'session_registered_users_json';

  static final SessionService instance = SessionService._internal();
  SessionService._internal();
  factory SessionService() => instance;

  String? _inMemoryUserId;

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
    _inMemoryUserId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setBool(keyIsGuest, false);
    await prefs.setString(keyUserId, id);
    await prefs.setString(keyUserName, name ?? 'Poultry Farmer');
    if (email != null && email.isNotEmpty) {
      await prefs.setString(keyUserEmail, email);
    } else {
      await prefs.remove(keyUserEmail);
    }
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString(keyUserPhone, phone);
    } else {
      await prefs.remove(keyUserPhone);
    }
  }

  /// Persists guest session.
  Future<void> saveGuestSession({required String id, String? name}) async {
    _inMemoryUserId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setBool(keyIsGuest, true);
    await prefs.setString(keyUserId, id);
    await prefs.setString(keyUserName, name ?? 'Guest Farmer');
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserPhone);
  }

  /// Retrieves cached user name.
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? 'Poultry Farmer';
  }

  /// Retrieves cached user email, if any.
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(keyUserEmail);
    return (email != null && email.isNotEmpty) ? email : null;
  }

  /// Retrieves cached user phone, if any.
  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(keyUserPhone);
    return (phone != null && phone.isNotEmpty) ? phone : null;
  }

  /// Retrieves cached user ID.
  Future<String> getUserId() async {
    if (_inMemoryUserId != null && _inMemoryUserId!.isNotEmpty) {
      return _inMemoryUserId!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(keyUserId);
      if (id != null && id.isNotEmpty) {
        _inMemoryUserId = id;
        return id;
      }
      final isGuest = prefs.getBool(keyIsGuest) ?? false;
      if (isGuest) return 'guest';
    } catch (_) {}
    return 'usr-001';
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

  /// Retrieves all persisted registered users.
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyRegisteredUsers);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Saves or updates a registered user in persistent storage.
  Future<void> saveRegisteredUser({
    required String id,
    required String name,
    required String identifier,
    required String password,
    required bool consent,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getRegisteredUsers();
    final cleanIdentifier = identifier.trim().toLowerCase();

    // Check if user already exists by identifier, email, phone, or id
    users.removeWhere((u) {
      final uEmail = (u['email'] as String?)?.toLowerCase();
      final uPhone = (u['phone'] as String?)?.toLowerCase();
      final uIdent = (u['identifier'] as String?)?.toLowerCase();
      return uEmail == cleanIdentifier ||
          uPhone == cleanIdentifier ||
          uIdent == cleanIdentifier ||
          u['id'] == id;
    });

    users.add({
      'id': id,
      'name': name,
      'identifier': identifier,
      'email': email,
      'phone': phone,
      'password': password,
      'consent': consent,
      'created_at': DateTime.now().toIso8601String(),
    });

    await prefs.setString(keyRegisteredUsers, jsonEncode(users));
  }

  /// Clears session upon logout. Does NOT delete registered accounts.
  Future<void> clearSession() async {
    _inMemoryUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyIsGuest);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserPhone);
  }
}
