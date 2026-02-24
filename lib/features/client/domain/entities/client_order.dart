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

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return ClientOrder(
      id: _toInt(json['id']),
      storeId: _toInt(json['storeId'] ?? json['store_id']),
      storeName: json['storeName']?.toString() ?? json['store_name']?.toString(),
      clientId: json['clientId'] != null || json['client_id'] != null
          ? _toInt(json['clientId'] ?? json['client_id'])
          : null,
      total: _toDouble(json['total']),
      deliveryFee: json['deliveryFee'] != null || json['delivery_fee'] != null
          ? _toDouble(json['deliveryFee'] ?? json['delivery_fee'])
          : null,
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      items: itemsList.map((item) => ClientOrderItem.fromJson(item)).toList(),
      deliveryAddress: json['deliveryAddress']?.toString() ?? json['delivery_address']?.toString(),
      deliveryLat: json['deliveryLat'] != null || json['delivery_lat'] != null
          ? _toDouble(json['deliveryLat'] ?? json['delivery_lat'])
          : null,
      deliveryLng: json['deliveryLng'] != null || json['delivery_lng'] != null
          ? _toDouble(json['deliveryLng'] ?? json['delivery_lng'])
          : null,
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null || json['completed_at'] != null
          ? DateTime.tryParse((json['completedAt'] ?? json['completed_at']).toString())
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
      productName: (json['productName'] ?? json['product_name'] ?? '').toString(),
      quantity: ClientOrder._toInt(json['quantity']),
      price: ClientOrder._toDouble(json['price']),
      subtotal: ClientOrder._toDouble(json['subtotal']),
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
