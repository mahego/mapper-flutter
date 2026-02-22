import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (phone != null) 'phone': phone,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error en registro: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Logout siempre debe completarse, incluso si el servidor falla
      // Silently ignore logout errors
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return response.data['token'] as String;
    } catch (e) {
      throw Exception('Error al refrescar token: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.me);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Error al solicitar recuperación: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Error al restablecer contraseña: $e');
    }
  }
}
