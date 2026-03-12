import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';

class ApiService {
 late final Dio _dio;
 ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),

      headers: {
        'Content-Type': 'application/json',
      },
    ));
     _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('   Body: ${options.data}');
          }
          handler.next(options); // continue the request
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode} from ${response.realUri}');
          print('   Data: ${response.data}');
          handler.next(response); // continue processing
        },
        onError: (DioException error, handler) {
          print('❌ ERROR: ${error.type} - ${error.message}');
          if (error.response != null) {
            print('   Status: ${error.response?.statusCode}');
            print('   Body: ${error.response?.data}');
          }
          handler.next(error); // continue error handling
        },
      ),
    );


  }
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future <Response?> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } on DioException catch (e) {
      ;
      return null;
    } catch (e) {
      print('❌Unexpected error: $e');
      return null;
    }
  }
  Future<Response?> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }catch (e) {
      print('❌Unexpected error in the get request: $e');
      return null;
    }
  }
  Future<Response?> put(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    } catch (e) {
      print('❌ Unexpected error in PUT: $e');
      return null;
    }
  }
  Future<Response?> delete(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }catch (e) {
      print('❌Unexpected error in the delete request: $e');
      return null;
    }
  }
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('❌ Connection timeout: ${e.message}');
        break;
      case DioExceptionType.sendTimeout:
        print('❌ Send timeout: ${e.message}');
        break;
      case DioExceptionType.receiveTimeout:
        print('❌ Receive timeout: ${e.message}');
        break;
      case DioExceptionType.badResponse:
        print('❌ Bad response: ${e.response?.statusCode} - ${e.response?.data}');
        break;
      case DioExceptionType.cancel:
        print('❌ Request cancelled: ${e.message}');
        break;
      case DioExceptionType.unknown:
      default:
        print('❌ Unknown error: ${e.message}');
    }
  }
  
}