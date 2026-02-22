class StoreOrder {
  final int id;
  final int storeId;
  final int? clientId;
  final String clientName;
  final double total;
  final String status;
  final String? paymentMethod;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? completedAt;

  StoreOrder({
    required this.id,
    required this.storeId,
    this.clientId,
    required this.clientName,
    required this.total,
    required this.status,
    this.paymentMethod,
    required this.items,
    required this.createdAt,
    this.completedAt,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return StoreOrder(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      clientId: json['client_id'],
      clientName: json['client_name'] ?? 'Cliente',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'client_id': clientId,
      'client_name': clientName,
      'total': total,
      'status': status,
      'payment_method': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}
