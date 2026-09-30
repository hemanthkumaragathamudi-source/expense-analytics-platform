import 'package:flutter/material.dart';
import 'auth_repository.dart';
import 'models/user.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticated,
  loading,
}

class AuthState extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthState({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthentication() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasToken = await _authRepository.hasToken();
      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _user = await _authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(username, password);
      _user = await _authRepository.getCurrentUser();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(username, email, password);
      // Auto-login after successful registration
      return await login(username, password);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
