import '../models/user_model.dart';
import '../mock/mock_users_data.dart';
import '../../services/session_service.dart';

/// AuthRepository manages user session state, persistent credentials,
/// and guest access for commercial poultry farmers.
class AuthRepository {
  final SessionService _sessionService = SessionService.instance;
  UserModel _currentUser = mockUsersData[0];

  UserModel get currentUser => _currentUser;
  bool get isAuthenticated => !_currentUser.isGuest;

  /// Restores session state from persistent storage on app startup.
  Future<bool> restoreSession() async {
    final isLoggedIn = await _sessionService.isLoggedIn();
    final isGuest = await _sessionService.isGuest();
    final name = await _sessionService.getUserName();
    final id = await _sessionService.getUserId();
    final locale = await _sessionService.getLocale();

    if (isLoggedIn) {
      _currentUser = UserModel(
        id: id,
        displayName: name,
        email: isGuest ? null : 'farmer@poultrycare.farm',
        phone: null,
        role: 'farmer',
        locale: locale,
        consentToRetainImages: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      return true;
    }
    return false;
  }

  static const Map<String, String> _credentials = {
    'farmer@poultrycare.farm': 'password123',
    'vet.support@poultrycare.farm': 'vet123',
    '03001234567': 'password123',
  };

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final trimmedId = identifier.trim().toLowerCase();

    // Find matching registered user
    final match = mockUsersData.where(
      (u) => (u.email?.toLowerCase() == trimmedId || u.phone == trimmedId) && !u.isGuest,
    );

    if (match.isEmpty) {
      throw Exception('Account not found. Please register or continue as guest.');
    }

    final user = match.first;
    final expectedPassword = _credentials[user.email] ?? _credentials[user.phone] ?? 'password123';
    if (password != expectedPassword) {
      throw Exception('Incorrect password. Please try again.');
    }

    _currentUser = user;

    // Persist login state
    await _sessionService.saveUserSession(
      id: _currentUser.id,
      name: _currentUser.displayName,
      email: _currentUser.email,
      phone: _currentUser.phone,
    );

    return _currentUser;
  }

  Future<UserModel> continueAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = UserModel(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Farmer',
      email: null,
      phone: null,
      role: 'farmer',
      locale: 'ur',
      consentToRetainImages: false,
      createdAt: DateTime.now(),
    );

    // Persist guest session
    await _sessionService.saveGuestSession(
      id: _currentUser.id,
      name: _currentUser.displayName,
    );

    return _currentUser;
  }

  Future<UserModel> register({
    required String name,
    required String identifier,
    required String password,
    required bool consent,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final isEmail = identifier.contains('@');
    final newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      displayName: name,
      email: isEmail ? identifier : null,
      phone: isEmail ? null : identifier,
      role: 'farmer',
      locale: 'ur',
      consentToRetainImages: consent,
      createdAt: DateTime.now(),
    );
    _currentUser = newUser;

    // Persist new user session
    await _sessionService.saveUserSession(
      id: _currentUser.id,
      name: _currentUser.displayName,
      email: _currentUser.email,
      phone: _currentUser.phone,
    );

    return _currentUser;
  }

  Future<void> updateConsent(bool consent) async {
    _currentUser = _currentUser.copyWith(consentToRetainImages: consent);
  }

  Future<void> updateLocale(String locale) async {
    _currentUser = _currentUser.copyWith(locale: locale);
    await _sessionService.saveLocale(locale);
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    _currentUser = mockUsersData[2]; // Return to guest
  }
}
