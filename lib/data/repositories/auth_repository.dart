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
    final storedEmail = await _sessionService.getUserEmail();
    final storedPhone = await _sessionService.getUserPhone();

    if (isLoggedIn) {
      if (isGuest || id == 'guest') {
        _currentUser = UserModel(
          id: 'guest',
          displayName: name,
          email: null,
          phone: null,
          role: 'farmer',
          locale: locale,
          consentToRetainImages: false,
          createdAt: DateTime.now(),
        );
        return true;
      }

      // Check registered users in local store
      final registered = await _sessionService.getRegisteredUsers();
      final match = registered.where((u) => u['id'] == id);
      if (match.isNotEmpty) {
        final u = match.first;
        _currentUser = UserModel(
          id: id,
          displayName: u['name'] as String? ?? name,
          email: u['email'] as String? ?? storedEmail,
          phone: u['phone'] as String? ?? storedPhone,
          role: 'farmer',
          locale: locale,
          consentToRetainImages: u['consent'] as bool? ?? true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        return true;
      }

      // Check existing demo accounts (e.g. usr-001 demo farmer)
      final demoMatch = mockUsersData.where((u) => u.id == id && !u.isGuest);
      if (demoMatch.isNotEmpty) {
        _currentUser = demoMatch.first.copyWith(locale: locale);
        return true;
      }

      // Restored registered session carries the account's OWN stored email or phone.
      // If none is stored, show none; never invent one.
      _currentUser = UserModel(
        id: id,
        displayName: name,
        email: storedEmail,
        phone: storedPhone,
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

    // 1. Check registered users first
    final registered = await _sessionService.getRegisteredUsers();
    final regMatch = registered.where((u) {
      final email = (u['email'] as String?)?.toLowerCase();
      final phone = (u['phone'] as String?)?.toLowerCase();
      final ident = (u['identifier'] as String?)?.toLowerCase();
      return email == trimmedId || phone == trimmedId || ident == trimmedId;
    });

    if (regMatch.isNotEmpty) {
      final userMap = regMatch.first;
      final expectedPassword = userMap['password'] as String? ?? '';
      if (password != expectedPassword) {
        throw Exception('Incorrect password. Please try again.');
      }

      final user = UserModel(
        id: userMap['id'] as String,
        displayName: userMap['name'] as String? ?? 'Poultry Farmer',
        email: userMap['email'] as String?,
        phone: userMap['phone'] as String?,
        role: 'farmer',
        locale: 'ur',
        consentToRetainImages: userMap['consent'] as bool? ?? true,
        createdAt: DateTime.now(),
      );

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

    // 2. Check existing demo accounts
    final demoMatch = mockUsersData.where(
      (u) => (u.email?.toLowerCase() == trimmedId || u.phone == trimmedId) && !u.isGuest,
    );

    if (demoMatch.isEmpty) {
      throw Exception('Account not found. Please register or continue as guest.');
    }

    final user = demoMatch.first;
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
      id: 'guest',
      displayName: 'Guest Farmer',
      email: null,
      phone: null,
      role: 'farmer',
      locale: 'ur',
      consentToRetainImages: false,
      createdAt: DateTime.now(),
    );

    // Persist guest session with fixed id 'guest'
    await _sessionService.saveGuestSession(
      id: 'guest',
      name: 'Guest Farmer',
    );

    return _currentUser;
  }

  Future<UserModel> register({
    required String name,
    required String identifier,
    required String password,
    bool consent = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final isEmail = identifier.contains('@');
    final userId = 'usr-${DateTime.now().millisecondsSinceEpoch}';
    final newUser = UserModel(
      id: userId,
      displayName: name,
      email: isEmail ? identifier : null,
      phone: isEmail ? null : identifier,
      role: 'farmer',
      locale: 'ur',
      consentToRetainImages: consent,
      createdAt: DateTime.now(),
    );

    // 1. Persist registered user into local store
    await _sessionService.saveRegisteredUser(
      id: userId,
      name: name,
      identifier: identifier,
      password: password,
      consent: consent,
      email: isEmail ? identifier : null,
      phone: isEmail ? null : identifier,
    );

    // 2. Persist active user session
    await _sessionService.saveUserSession(
      id: newUser.id,
      name: newUser.displayName,
      email: newUser.email,
      phone: newUser.phone,
    );

    _currentUser = newUser;
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
    _currentUser = UserModel(
      id: 'guest',
      displayName: 'Guest Farmer',
      email: null,
      phone: null,
      role: 'farmer',
      locale: 'ur',
      consentToRetainImages: false,
      createdAt: DateTime.now(),
    );
  }
}
