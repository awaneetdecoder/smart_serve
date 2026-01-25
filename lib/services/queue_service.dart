import '../core/constants/api_endpoints.dart';
import 'api_service.dart';

class QueueService {
  final ApiService _api = ApiService();

  // FIX 1: Unwrap the Generate Token Response
  Future<Map<String, dynamic>?> generateToken(String serviceId) async {
    try {
      final response = await _api.post(ApiEndpoints.generateToken, {
        'service_id': serviceId,
      });

      if (response != null && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Queue Service Error: $e");
      return null;
    }
  }

  // FIX 2: Unwrap the Status Response
  Future<Map<String, dynamic>?> getQueueStatus() async {
    try {
      final response = await _api.get(ApiEndpoints.queueStatus);

      if (response != null && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}