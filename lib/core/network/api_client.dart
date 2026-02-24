import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

/// Opción para no enviar Authorization (ej. GET sesión de pago QR es público).
const _skipAuth = Options(extra: {'skip_auth': true});

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

  /// Callback when 401 is received (e.g. redirect to login). Set from main.
  static void Function()? onUnauthorized;

  /// Callback to try refresh token; return new access token or null. Set from main.
  static Future<String?> Function()? onTryRefreshToken;

  static bool _isRefreshing = false;

  static Future<void> _clearAuthAndNotify() async {
    await StorageService().removeToken();
    await StorageService().removeRefreshToken();
    onUnauthorized?.call();
  }

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
        final skipAuth = options.extra['skip_auth'] == true;
        if (!skipAuth) {
          final token = await StorageService().getTokenAsync();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d('🔐 Token añadido: ${token.substring(0, 20)}...');
          } else {
            _logger.w('⚠️ No hay token de autenticación disponible');
          }
        }
        _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;
        final path = e.requestOptions.path;

        if (statusCode == 401) {
          final isRefreshRequest = path.contains('refresh');
          if (isRefreshRequest) {
            _logger.w('⚠️ Refresh falló (401) => cerrando sesión');
            await _clearAuthAndNotify();
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: UnauthorizedException('Tu sesión ha expirado. Inicia sesión nuevamente.'),
              message: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
            ));
          }

          if (_isRefreshing) {
            _logger.w('⚠️ 401 durante refresh => cerrando sesión');
            await _clearAuthAndNotify();
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: UnauthorizedException('Tu sesión ha expirado. Inicia sesión nuevamente.'),
              message: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
            ));
          }

          _isRefreshing = true;
          try {
            final newToken = await onTryRefreshToken?.call();
            if (newToken != null && newToken.isNotEmpty) {
              _logger.i('✅ Token refrescado; reintentando request');
              updateToken(newToken);
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          } catch (_) {
            _logger.w('⚠️ Error al refrescar token');
          } finally {
            _isRefreshing = false;
          }

          _logger.w('⚠️ UNAUTHORIZED[401] => PATH: $path (sin refresh posible)');
          await _clearAuthAndNotify();
          return handler.reject(DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: UnauthorizedException('Tu sesión ha expirado. Inicia sesión nuevamente.'),
            message: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
          ));
        }
        _logger.e('⛔ ERROR[$statusCode] => PATH: $path', error: e.error, stackTrace: e.stackTrace);
        return handler.next(e);
      },
    ));

    // Retry GET on connection/timeout errors (idempotentes)
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) async {
        final isGet = e.requestOptions.method == 'GET';
        final retryCount = (e.requestOptions.extra['retry_count'] as int?) ?? 0;
        const maxRetries = 2;
        final isRetryable = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;
        if (isGet && isRetryable && retryCount < maxRetries) {
          e.requestOptions.extra['retry_count'] = retryCount + 1;
          await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
          try {
            final response = await _dio.fetch(e.requestOptions);
            return handler.resolve(response);
          } catch (_) {
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, bool skipAuth = false}) async {
    return _dio.get(path, queryParameters: queryParameters, options: skipAuth ? _skipAuth : null);
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
