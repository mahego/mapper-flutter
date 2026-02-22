class User {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;
  final bool? needsCompleteProfile;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.profileImage,
    required this.createdAt,
    this.needsCompleteProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['id'] == null) {
      throw Exception('User ID is required but was null. Full user data: $json');
    }
    if (json['email'] == null || json['email'] == '') {
      throw Exception('User email is required but was null or empty. Full user data: $json');
    }
    if (json['name'] == null || json['name'] == '') {
      throw Exception('User name is required but was null or empty. Full user data: $json');
    }
    if (json['role'] == null || json['role'] == '') {
      throw Exception('User role is required but was null or empty. Full user data: $json');
    }

    return User(
      id: int.parse(json['id'].toString()),
      email: json['email'].toString(),
      name: json['name'].toString(),
      role: json['role'].toString(),
      phone: json['phone']?.toString(),
      // Backend sends 'avatar' but we use 'profileImage'
      profileImage: (json['profileImage'] ?? json['avatar'])?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      needsCompleteProfile: json['needsCompleteProfile'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'profileImage': profileImage,
      'needsCompleteProfile': needsCompleteProfile,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    bool? needsCompleteProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      needsCompleteProfile: needsCompleteProfile ?? this.needsCompleteProfile,
    );
  }
}
