import 'dart:io';
import 'package:dio/dio.dart';

/// Centralized error handling for API calls and user feedback
/// Provides consistent error messages across the entire app
class ErrorHandler {
  // Prevent instantiation
  ErrorHandler._();

  /// Parse any error into a user-friendly message
  /// Common for catch blocks: `ErrorHandler.getErrorMessage(error)`
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    }
    
    if (error is String) {
      return error; // Direct string error message
    }
    
    if (error is Exception) {
      return error.toString();
    }
    
    return 'Error desconocido. Por favor intenta nuevamente.';
  }

  /// Parse DioException into user-friendly message
  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Conexión agotada. Verifica tu conexión de internet.';
      
      case DioExceptionType.sendTimeout:
        return 'Envío lento. Tu conexión es muy lenta.';
      
      case DioExceptionType.receiveTimeout:
        return 'Recepción lenta. El servidor no responde rápidamente.';
      
      case DioExceptionType.badCertificate:
        return 'Error de certificado. Por favor contacta soporte.';
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(
          error.response?.statusCode ?? 500,
          error.response?.data,
        );
      
      case DioExceptionType.cancel:
        return 'Solicitud cancelada por el usuario.';
      
      case DioExceptionType.connectionError:
        return 'No hay conexión de internet. Verifica tu red.';
      
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No hay conexión de internet disponible.';
        }
        return 'Error desconocido. Por favor intenta nuevamente.';
    }
  }

  /// Parse HTTP response errors by status code
  static String _handleBadResponse(int statusCode, dynamic data) {
    // Try to extract message from backend response
    String? backendMessage;
    if (data is Map<String, dynamic>) {
      backendMessage = data['message'] ?? data['error'] ?? data['msg'];
    }

    switch (statusCode) {
      case 400:
        return backendMessage ?? 'Solicitud inválida. Verifica los datos enviados.';
      
      case 401:
        return 'Sesión expirada. Por favor inicia sesión nuevamente.';
      
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      
      case 404:
        return 'El recurso no existe o fue eliminado.';
      
      case 409:
        return 'Conflicto: este elemento ya existe o hay un cambio en progreso.';
      
      case 429:
        return 'Demasiadas solicitudes. Intenta más tarde.';
      
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Error del servidor. Por favor intenta más tarde.';
      
      default:
        return backendMessage ?? 'Error $statusCode: Por favor intenta nuevamente.';
    }
  }

  /// Get an error title for display (short version)
  static String getErrorTitle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.connectionError:
          return 'Sin conexión';
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Conexión lenta';
        case DioExceptionType.badResponse:
          return 'Error ${error.response?.statusCode}';
        default:
          return 'Error';
      }
    }
    return 'Error';
  }

  /// Check if error is network-related (retry-able)
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
    }
    return false;
  }

  /// Check if error is authentication-related (should redirect to login)
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 ||
          error.response?.statusCode == 403;
    }
    return false;
  }

  /// Check if error is server-related (500+)
  static bool isServerError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;
      return statusCode >= 500;
    }
    return false;
  }

  /// Check if error is validation-related (400)
  static bool isValidationError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 400;
    }
    return false;
  }

  /// Extract validation errors from 400 response
  /// Returns map of field -> error message
  static Map<String, String> extractValidationErrors(dynamic error) {
    final errors = <String, String>{};
    
    if (error is DioException && error.response?.statusCode == 400) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        // Support different backend formats
        if (data['errors'] is Map) {
          data['errors'].forEach((key, value) {
            errors[key] = value is List ? value.first : value.toString();
          });
        } else if (data['field'] != null && data['message'] != null) {
          errors[data['field']] = data['message'];
        }
      }
    }
    
    return errors;
  }
}

// For convenience
extension DioExceptionExt on DioException {
  String get userMessage => ErrorHandler.getErrorMessage(this);
  String get title => ErrorHandler.getErrorTitle(this);
  bool get isNetworkError => ErrorHandler.isNetworkError(this);
  bool get isAuthError => ErrorHandler.isAuthError(this);
}
