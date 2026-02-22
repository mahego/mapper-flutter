import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

// Custom exception for unauthorized errors
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => message;
}

class ApiClient {
  final Dio _dio;
  final Logger _logger;

  ApiClient({Dio? dio, Logger? logger}) 
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )),
        _logger = logger ?? Logger() {
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Auth Token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          _logger.d('🔐 Token añadido: ${token.substring(0, 20)}...');
        } else {
          _logger.w('⚠️ No hay token de autenticación disponible');
        }
        
        _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final statusCode = e.response?.statusCode;
        final path = e.requestOptions.path;
        
        // Handle 401 Unauthorized
        if (statusCode == 401) {
          _logger.w('⚠️ UNAUTHORIZED[401] => PATH: $path (auth required)');
          final message = 'Unauthorized: ${e.message}';
          return handler.reject(DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: UnauthorizedException(message),
            message: message,
          ));
        } else {
          _logger.e('⛔ ERROR[$statusCode] => PATH: $path', error: e.error, stackTrace: e.stackTrace);
        }
        
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // Update authorization token dynamically
  void updateToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      _logger.i('✅ Token actualizado');
    } else {
      _dio.options.headers.remove('Authorization');
      _logger.i('🗑️  Token removido');
    }
  }
}
