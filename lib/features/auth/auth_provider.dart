import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart ';
import '../../models/user_model.dart';


class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool       get isLoggedIn   => _currentUser != null;
  bool       get isAdmin      => _currentUser?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    // Show loading spinner in UI
    _setLoading(true);
    _errorMessage = null; // Clear any previous error

    try {
      // Call AuthService which calls the real backend
      final user = await _authService.login(email, password);

      if (user == null) {
        // Login failed — set error message for UI to display
        _errorMessage = 'Invalid email or password. Please try again.';
        _setLoading(false);
        return false;
      }

      // Login successful! Store user in memory
      _currentUser = user;

      // Also save to device storage — user stays logged in after app restart
      await _saveUserToPrefs(user);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Connection failed. Is your server running?';
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // register()
  // WHAT: Creates a new user account, then auto-logs them in.
  //
  // WHY auto-login after register?
  //   Better UX — users don't want to register AND THEN login separately.
  //   After successful registration, treat them as logged in immediately.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String role = 'STUDENT',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.register(
        fullName: fullName,
        email:    email,
        password: password,
        role:     role,
      );

      if (user == null) {
        _errorMessage = 'Registration failed. Email may already be in use.';
        _setLoading(false);
        return false;
      }

      // Auto-login: store the newly registered user
      _currentUser = user;
      await _saveUserToPrefs(user);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Connection failed. Is your server running?';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have a saved userId
    final userId = prefs.getInt('userId');
    if (userId == null) return false; // No saved session

    // Rebuild the UserModel from saved data
    _currentUser = UserModel(
      id:       prefs.getInt('userId') ?? 0,
      email:    prefs.getString('userEmail')    ?? '',
      fullName: prefs.getString('userFullName') ?? '',
      role:     prefs.getString('userRole')     ?? 'STUDENT',
      jwtToken: prefs.getString('jwtToken') ?? '',
    );

    notifyListeners(); // Tell all widgets "a user is now logged in"
    return true;
  }
  Future<void> logout() async {
    // Clear from memory
    _currentUser = null;
    _errorMessage = null;

    // Clear from device storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userFullName');
    await prefs.remove('userRole');

    notifyListeners(); // Tell all widgets "no one is logged in now"
  }
  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId',       user.id);
    await prefs.setString('userEmail',    user.email);
    await prefs.setString('userFullName', user.fullName);
    await prefs.setString('userRole',     user.role);
  }

  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}