import '../core/constants/api_endpoints.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  // FIX: Change return type to nullable Map (Map<String, dynamic>?) 
  // so we can return 'null' if the login fails.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _api.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

      // Check if response is valid and has data
      if (response != null && response.data != null) {
        // UNWRAP: Return only the data, not the whole Response object
        return response.data as Map<String, dynamic>; 
      }
      
      return null; // Login failed or network error
    } catch (e) {
      print("Login Logic Error: $e");
      return null;
    }
  }
}