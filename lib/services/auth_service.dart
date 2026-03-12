import 'dart:convert';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _api.post(ApiEndpoints.login, {
        'email':    email,
        'password': password,
      });

      if (response == null) return null;
      if (response.data == null) return null;

      Map<String, dynamic> data;
      if (response.data is Map) {
        data = Map<String, dynamic>.from(response.data);
      } else {
        data = json.decode(response.data.toString());
      }

      if (data.containsKey('error')) return null;

      return UserModel.fromJson(data);

    } catch (e) {
      print('❌ Login exception: $e');
      return null;
    }
  }

  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    String role = 'STUDENT',
  }) async {
    try {
      final response = await _api.post(ApiEndpoints.register, {
        'fullName': fullName,
        'email':    email,
        'password': password,
        'role':     role,
      });

      if (response == null || response.data == null) return null;

      Map<String, dynamic> data;
      if (response.data is Map) {
        data = Map<String, dynamic>.from(response.data);
      } else {
        data = json.decode(response.data.toString());
      }

      if (data.containsKey('error')) return null;

      return UserModel.fromJson(data);

    } catch (e) {
      print('❌ Register exception: $e');
      return null;
    }
  }
}