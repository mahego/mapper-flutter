class ExpressRequest {
  final int id;
  final int? serviceId;
  final String? serviceName;
  final String? categoryName;
  final String? categoryIcon;
  final String? storeName;
  final String originAddress;
  final String destAddress;
  final double proposedPrice;
  final String urgency;
  final String status;
  final String distanceKm;
  final DateTime createdAt;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final double? finalPrice;
  final double? estimatedCost;

  const ExpressRequest({
    required this.id,
    this.serviceId,
    this.serviceName,
    this.categoryName,
    this.categoryIcon,
    this.storeName,
    required this.originAddress,
    required this.destAddress,
    required this.proposedPrice,
    required this.urgency,
    required this.status,
    required this.distanceKm,
    required this.createdAt,
    this.notes,
    this.metadata,
    this.finalPrice,
    this.estimatedCost,
  });

  bool get isUrgent => urgency == 'urgent' || urgency == 'high';
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isCompleted => status == 'completed';

  factory ExpressRequest.fromJson(Map<String, dynamic> json) {
    final serviceId = json['serviceId'] ?? json['service_type_id'] ?? json['categoryId'] ?? json['category_id'];
    
    Map<String, dynamic>? meta;
    if (json['metadata'] != null) {
      if (json['metadata'] is String) {
        // Parse JSON string
        try {
          meta = {};
        } catch (e) {
          meta = {};
        }
      } else {
        meta = json['metadata'] as Map<String, dynamic>?;
      }
    }

    return ExpressRequest(
      id: json['id'] ?? 0,
      serviceId: serviceId != null ? int.tryParse(serviceId.toString()) : null,
      serviceName: json['serviceName'] ?? json['service_name'] ?? json['type_name'],
      categoryName: json['categoryName'] ?? json['category_name'],
      categoryIcon: json['categoryIcon'] ?? json['category_icon'],
      storeName: json['storeName'] ?? json['store_name'] ?? meta?['storeName'] ?? meta?['store_name'],
      originAddress: json['originAddress'] ?? json['pickup_location'] ?? json['pickupLocation'] ?? '',
      destAddress: json['destAddress'] ?? json['delivery_location'] ?? json['deliveryLocation'] ?? '',
      proposedPrice: (json['proposedPrice'] ?? json['proposed_cost'] ?? json['estimatedCost'] ?? json['estimated_cost'] ?? 0).toDouble(),
      urgency: json['urgency'] ?? 'normal',
      status: json['status'] ?? 'pending',
      distanceKm: (json['distanceKm'] ?? json['distance'] ?? '0').toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'] ?? json['requestNotes'] ?? json['request_notes'] ?? json['description'],
      metadata: meta,
      finalPrice: json['finalPrice'] != null ? (json['finalPrice']).toDouble() : null,
      estimatedCost: json['estimatedCost'] != null ? (json['estimatedCost']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'storeName': storeName,
      'originAddress': originAddress,
      'destAddress': destAddress,
      'proposedPrice': proposedPrice,
      'urgency': urgency,
      'status': status,
      'distanceKm': distanceKm,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
      'finalPrice': finalPrice,
      'estimatedCost': estimatedCost,
    };
  }
}
