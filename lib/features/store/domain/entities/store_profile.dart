class StoreProfile {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? description;
  final String? logo;
  final bool isActive;
  final DateTime createdAt;

  StoreProfile({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.description,
    this.logo,
    required this.isActive,
    required this.createdAt,
  });

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      logo: json['logo'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
      'logo': logo,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
