class StoreProduct {
  final int id;
  final int storeId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;

  StoreProduct({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.category,
    this.imageUrl,
    this.barcode,
    required this.isActive,
    required this.createdAt,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      barcode: json['barcode'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'barcode': barcode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
