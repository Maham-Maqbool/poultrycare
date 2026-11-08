import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

/// AuthController manages current authentication state and session changes.
class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  bool _isLoading = false;
  String? _errorMessage;

  AuthController(this._repo);

  UserModel get user => _repo.currentUser;
  bool get isAuthenticated => _repo.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.login(identifier: identifier, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _repo.continueAsGuest();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String identifier,
    required String password,
    required bool consent,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.register(
        name: name,
        identifier: identifier,
        password: password,
        consent: consent,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateConsent(bool consent) async {
    await _repo.updateConsent(consent);
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    notifyListeners();
  }
}
