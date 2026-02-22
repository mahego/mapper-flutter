// Helper function to safely convert to double
double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

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
      serviceType: json['serviceTypeName'] ?? json['serviceType'] ?? json['service_type'] ?? json['service_type_name'] ?? '',
      status: json['status'] ?? 'pending',
      originAddress: json['originAddress'] ?? json['origin_address'] ?? json['pickup_location'] ?? '',
      destinationAddress: json['destAddress'] ?? json['destinationAddress'] ?? json['destination_address'] ?? json['delivery_location'] ?? '',
      originLat: _toDoubleOrNull(json['originLat'] ?? json['origin_lat'] ?? json['pickup_latitude']),
      originLng: _toDoubleOrNull(json['originLng'] ?? json['origin_lng'] ?? json['pickup_longitude']),
      destinationLat: _toDoubleOrNull(json['destLat'] ?? json['destinationLat'] ?? json['destination_lat'] ?? json['delivery_latitude']),
      destinationLng: _toDoubleOrNull(json['destLng'] ?? json['destinationLng'] ?? json['destination_lng'] ?? json['delivery_longitude']),
      estimatedCost: _toDoubleOrNull(json['estimatedCost'] ?? json['estimated_cost']),
      finalCost: _toDoubleOrNull(json['finalPrice'] ?? json['finalCost'] ?? json['final_cost'] ?? json['final_price']),
      pickupTime: json['pickupTime'] ?? json['pickup_time'] ?? json['startedAt'] ?? json['started_at'],
      deliveryTime: json['deliveryTime'] ?? json['delivery_time'] ?? json['completedAt'] ?? json['completed_at'],
      notes: json['notes'] ?? json['description'],
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
