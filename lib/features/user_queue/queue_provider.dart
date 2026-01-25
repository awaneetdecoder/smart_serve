import 'package:flutter/material.dart';
import '../../models/token_model.dart';

class QueueProvider with ChangeNotifier {
  TokenModel? _activeToken;
  bool _isLoading = false;

  TokenModel? get activeToken => _activeToken;
  bool get isLoading => _isLoading;

  // Simulate API Call to Generate Token
  Future<bool> generateToken(String serviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // SIMULATING NETWORK DELAY
      await Future.delayed(const Duration(seconds: 2));

      // Mock Response from Backend
      _activeToken = TokenModel(
        id: "123",
        tokenNumber: "A-106",
        serviceName: "General Consultation",
        status: "WAITING",
        peopleAhead: 3,
        estimatedWaitMinutes: 12,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false; // Failed
    }
  }
}