import 'user.dart';

class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['token'] == null || json['token'] == '') {
      throw Exception('Token is required but was null or empty. Full response: $json');
    }
    if (json['user'] == null) {
      throw Exception('User data is required but was null. Full response: $json');
    }

    return AuthResponse(
      token: json['token'].toString(),
      refreshToken: json['refreshToken']?.toString(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
