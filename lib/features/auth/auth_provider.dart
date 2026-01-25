import 'package:flutter/material.dart';

enum AuthStatus { unauthenticated, authenticated, admin }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _userToken;
  
  AuthStatus get status => _status;
  String? get userToken => _userToken;

  Future<bool> login(String email, String password) async {
    // 1. Input Validation (Basic)
    if (email.isEmpty || password.isEmpty) return false;

    try {
      // TODO: Replace with actual API call to Spring Boot
      // final response = await api.post('/auth/login', {'email': email, 'password': password});
      
      // MOCK LOGIC FOR DEMO
      await Future.delayed(const Duration(seconds: 1)); // Simulate network
      
      if (email.contains("admin")) {
        _status = AuthStatus.admin;
      } else {
        _status = AuthStatus.authenticated;
      }
      
      _userToken = "mock_jwt_token_12345";
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _userToken = null;
    notifyListeners();
  }
}