import '../entities/auth_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  });
  Future<void> logout();
  Future<String> refreshToken(String refreshToken);
  Future<User> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
}
