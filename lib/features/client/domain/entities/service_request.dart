class ServiceRequest {
  final String id;
  final String clientId;
  final String? providerId;
  final String? providerName;
  final String serviceType;
  final String status;
  final String originAddress;
  final String destinationAddress;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final double? estimatedCost;
  final double? finalCost;
  final String? pickupTime;
  final String? deliveryTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceRequest({
    required this.id,
    required this.clientId,
    this.providerId,
    this.providerName,
    required this.serviceType,
    required this.status,
    required this.originAddress,
    required this.destinationAddress,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.estimatedCost,
    this.finalCost,
    this.pickupTime,
    this.deliveryTime,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? json['client_id']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? json['provider_id']?.toString(),
      providerName: json['providerName'] ?? json['provider_name'],
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      status: json['status'] ?? 'pending',
      originAddress: json['originAddress'] ?? json['origin_address'] ?? '',
      destinationAddress: json['destinationAddress'] ?? json['destination_address'] ?? '',
      originLat: json['originLat']?.toDouble() ?? json['origin_lat']?.toDouble(),
      originLng: json['originLng']?.toDouble() ?? json['origin_lng']?.toDouble(),
      destinationLat: json['destinationLat']?.toDouble() ?? json['destination_lat']?.toDouble(),
      destinationLng: json['destinationLng']?.toDouble() ?? json['destination_lng']?.toDouble(),
      estimatedCost: json['estimatedCost']?.toDouble() ?? json['estimated_cost']?.toDouble(),
      finalCost: json['finalCost']?.toDouble() ?? json['final_cost']?.toDouble(),
      pickupTime: json['pickupTime'] ?? json['pickup_time'],
      deliveryTime: json['deliveryTime'] ?? json['delivery_time'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'providerId': providerId,
      'providerName': providerName,
      'serviceType': serviceType,
      'status': status,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLat': originLat,
      'originLng': originLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'pickupTime': pickupTime,
      'deliveryTime': deliveryTime,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'negotiating':
        return 'Negociando';
      case 'assigned':
        return 'Asignado';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
