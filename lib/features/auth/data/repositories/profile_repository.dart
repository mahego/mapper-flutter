import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Model para perfil de usuario
class UserProfile {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? estado;
  final String? ciudad;
  final String? colonia;
  final String? codigoPostal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.estado,
    this.ciudad,
    this.colonia,
    this.codigoPostal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      estado: json['estado'] as String?,
      ciudad: json['ciudad'] as String?,
      colonia: json['colonia'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'estado': estado,
      'ciudad': ciudad,
      'colonia': colonia,
      'codigo_postal': codigoPostal,
    };
  }
}

/// Repository para gestionar perfil de usuario
class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Obtener perfil actual del usuario autenticado
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      final data = response.data;
      
      if (data is Map) {
        final profileData = data['data'] ?? data;
        if (profileData is Map) {
          return UserProfile.fromJson(Map<String, dynamic>.from(profileData));
        }
      }
      throw Exception('Invalid profile response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar perfil del usuario
  Future<UserProfile> updateProfile({
    String? name,
    String? phone,
    String? estado,
    String? ciudad,
    String? colonia,
    String? codigoPostal,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (estado != null) data['estado'] = estado;
      if (ciudad != null) data['ciudad'] = ciudad;
      if (colonia != null) data['colonia'] = colonia;
      if (codigoPostal != null) data['codigo_postal'] = codigoPostal;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _apiClient.put(
        ApiEndpoints.profile,
        data: data,
      );

      final responseData = response.data;
      if (responseData is Map) {
        final profileData = responseData['data'] ?? responseData;
        if (profileData is Map) {
          return UserProfile.fromJson(Map<String, dynamic>.from(profileData));
        }
      }
      throw Exception('Invalid profile update response');
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Solicitar restablecimiento de contraseña
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restablecer contraseña con token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
