import '../core/constants/api_endpoints.dart';
import '../models/token_model.dart';
import 'api_service.dart';

class QueueService {
  final ApiService _api = ApiService();

  // ✅ CORRECT — named parameters userId and tokenType, returns TokenModel?
  Future<TokenModel?> joinQueue({
    required int userId,
    required String tokenType,
  }) async {
    try {
      final response = await _api.post(ApiEndpoints.joinQueue, {
        'user':      {'id': userId},
        'tokenType': tokenType,
      });

      if (response == null || response.data == null) return null;

      final data = response.data;

      if (data is Map && data.containsKey('error')) {
        print('Join queue error: ${data['error']}');
        return null;
      }

      return TokenModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('joinQueue exception: $e');
      return null;
    }
  }

  Future<List<TokenModel>> getUserTokens(int userId) async {
    try {
      final response = await _api.get('${ApiEndpoints.userQueue}/$userId');
      if (response == null || response.data == null) return [];
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((item) => TokenModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getUserTokens exception: $e');
      return [];
    }
  }

  Future<List<TokenModel>> getAllTokens() async {
    try {
      final response = await _api.get(ApiEndpoints.allQueue);
      if (response == null || response.data == null) return [];
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((item) => TokenModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getAllTokens exception: $e');
      return [];
    }
  }

  Future<TokenModel?> updateTokenStatus(int tokenId, String status) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.queueStatus}/$tokenId/status',
        queryParameters: {'status': status},
      );
      if (response == null || response.data == null) return null;
      return TokenModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('updateTokenStatus exception: $e');
      return null;
    }
  }

  Future<int> getWaitTime(int userId) async {
    try {
      final response = await _api.get('${ApiEndpoints.userQueue}/$userId/wait-time');
      if (response == null || response.data == null) return -1;
      final data = response.data as Map<String, dynamic>;
      return data['waitMinutes'] as int? ?? -1;
    } catch (e) {
      return -1;
    }
  }

  Future<bool> cancelToken(int tokenId) async {
    try {
      final response = await _api.delete('${ApiEndpoints.queueStatus}/$tokenId');
      if (response == null) return false;
      return response.statusCode == 200;
    } catch (e) {
      print('cancelToken exception: $e');
      return false;
    }
  }
}