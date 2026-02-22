class ClientOrder {
  final int id;
  final int storeId;
  final String? storeName;
  final int? clientId;
  final double total;
  final double? deliveryFee;
  final String status;
  final String? paymentMethod;
  final List<ClientOrderItem> items;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  ClientOrder({
    required this.id,
    required this.storeId,
    this.storeName,
    this.clientId,
    required this.total,
    this.deliveryFee,
    required this.status,
    this.paymentMethod,
    required this.items,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return ClientOrder(
      id: json['id'] ?? 0,
      storeId: json['storeId'] ?? json['store_id'] ?? 0,
      storeName: json['storeName'] ?? json['store_name'],
      clientId: json['clientId'] ?? json['client_id'],
      total: (json['total'] ?? 0).toDouble(),
      deliveryFee: json['deliveryFee'] != null || json['delivery_fee'] != null
          ? (json['deliveryFee'] ?? json['delivery_fee']).toDouble()
          : null,
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      items: itemsList.map((item) => ClientOrderItem.fromJson(item)).toList(),
      deliveryAddress: json['deliveryAddress'] ?? json['delivery_address'],
      deliveryLat: json['deliveryLat'] != null || json['delivery_lat'] != null
          ? (json['deliveryLat'] ?? json['delivery_lat']).toDouble()
          : null,
      deliveryLng: json['deliveryLng'] != null || json['delivery_lng'] != null
          ? (json['deliveryLng'] ?? json['delivery_lng']).toDouble()
          : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null || json['completed_at'] != null
          ? DateTime.parse(json['completedAt'] ?? json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'clientId': clientId,
      'total': total,
      'deliveryFee': deliveryFee,
      'status': status,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'deliveryLat': deliveryLat,
      'deliveryLng': deliveryLng,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  double get grandTotal => total + (deliveryFee ?? 0);
}

class ClientOrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  ClientOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory ClientOrderItem.fromJson(Map<String, dynamic> json) {
    return ClientOrderItem(
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      productName: json['productName'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}
