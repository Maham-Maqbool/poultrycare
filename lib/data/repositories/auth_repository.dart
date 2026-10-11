import '../models/user_model.dart';
import '../mock/mock_users_data.dart';

/// AuthRepository manages user session state, guest access,
/// and image retention consent in memory.
class AuthRepository {
  UserModel _currentUser = mockUsersData[0]; // Maham Maqbool by default

  UserModel get currentUser => _currentUser;
  bool get isAuthenticated => !_currentUser.isGuest;

  Future<UserModel> login({required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final match = mockUsersData.firstWhere(
      (u) => (u.email == identifier || u.phone == identifier) && !u.isGuest,
      orElse: () => UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        displayName: identifier.contains('@') ? identifier.split('@')[0] : 'Farmer $identifier',
        email: identifier.contains('@') ? identifier : null,
        phone: identifier.contains('@') ? null : identifier,
        role: 'farmer',
        locale: 'en',
        consentToRetainImages: false,
        createdAt: DateTime.now(),
      ),
    );
    _currentUser = match;
    return _currentUser;
  }

  Future<UserModel> continueAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = UserModel(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Farmer',
      email: null,
      phone: null,
      role: 'farmer',
      locale: 'en',
      consentToRetainImages: false,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<UserModel> register({
    required String name,
    required String identifier,
    required String password,
    required bool consent,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final isEmail = identifier.contains('@');
    final newUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      displayName: name,
      email: isEmail ? identifier : null,
      phone: isEmail ? null : identifier,
      role: 'farmer',
      locale: 'en',
      consentToRetainImages: consent,
      createdAt: DateTime.now(),
    );
    _currentUser = newUser;
    return _currentUser;
  }

  Future<void> updateConsent(bool consent) async {
    _currentUser = _currentUser.copyWith(consentToRetainImages: consent);
  }

  Future<void> updateLocale(String locale) async {
    _currentUser = _currentUser.copyWith(locale: locale);
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = mockUsersData[2]; // Return to guest
  }
}
