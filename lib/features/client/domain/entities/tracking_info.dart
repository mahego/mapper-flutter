class TrackingInfo {
  final String requestId;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? providerName;
  final String? providerPhone;
  final String? vehiclePlate;
  final String? estimatedArrival;
  final double? distanceRemaining;

  const TrackingInfo({
    required this.requestId,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.destinationLat,
    this.destinationLng,
    this.providerName,
    this.providerPhone,
    this.vehiclePlate,
    this.estimatedArrival,
    this.distanceRemaining,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      requestId: json['requestId']?.toString() ?? json['request_id']?.toString() ?? '',
      status: json['status'] ?? 'unknown',
      currentLat: json['currentLat']?.toDouble() ?? json['current_lat']?.toDouble(),
      currentLng: json['currentLng']?.toDouble() ?? json['current_lng']?.toDouble(),
      destinationLat: json['destinationLat']?.toDouble() ?? json['destination_lat']?.toDouble(),
      destinationLng: json['destinationLng']?.toDouble() ?? json['destination_lng']?.toDouble(),
      providerName: json['providerName'] ?? json['provider_name'],
      providerPhone: json['providerPhone'] ?? json['provider_phone'],
      vehiclePlate: json['vehiclePlate'] ?? json['vehicle_plate'],
      estimatedArrival: json['estimatedArrival'] ?? json['estimated_arrival'],
      distanceRemaining: json['distanceRemaining']?.toDouble() ?? json['distance_remaining']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'vehiclePlate': vehiclePlate,
      'estimatedArrival': estimatedArrival,
      'distanceRemaining': distanceRemaining,
    };
  }
}
