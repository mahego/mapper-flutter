import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Model para vehículo del prestador
class VehicleModel {
  final int id;
  final int providerId;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String vehicleType; // 'auto', 'camioneta', 'moto', 'bicicleta'
  final int capacity; // En kilogramos
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModel({
    required this.id,
    required this.providerId,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.vehicleType,
    required this.capacity,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      providerId: json['provider_id'] ?? json['userId'] as int,
      licensePlate: json['license_plate'] ?? json['licensePlate'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String? ?? '',
      vehicleType: json['vehicle_type'] ?? json['vehicleType'] as String,
      capacity: json['capacity'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'license_plate': licensePlate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'active': active,
    };
  }
}

/// Repository para gestionar vehículos del prestador
class VehiclesRepository {
  final ApiClient _apiClient;

  VehiclesRepository(this._apiClient);

  /// Obtener todos los vehículos del prestador
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.vehicles);
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['vehicles'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => VehicleModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de un vehículo
  Future<VehicleModel> getVehicleDetail(int vehicleId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.vehicles}/$vehicleId');
      final data = response.data;

      final vehicleData = data is Map ? (data['data'] ?? data) : data;
      return VehicleModel.fromJson(Map<String, dynamic>.from(vehicleData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo vehículo
  Future<VehicleModel> createVehicle({
    required String licensePlate,
    required String brand,
    required String model,
    required int year,
    required String vehicleType,
    String? color,
    int? capacity,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.vehicles,
        data: {
          'license_plate': licensePlate,
          'brand': brand,
          'model': model,
          'year': year,
          'vehicle_type': vehicleType,
          if (color != null) 'color': color,
          if (capacity != null) 'capacity': capacity,
        },
      );

      final data = response.data;
      final vehicleData = data is Map ? (data['data'] ?? data) : data;
      return VehicleModel.fromJson(Map<String, dynamic>.from(vehicleData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar vehículo existente
  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    String? licensePlate,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? vehicleType,
    int? capacity,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (licensePlate != null) data['license_plate'] = licensePlate;
      if (brand != null) data['brand'] = brand;
      if (model != null) data['model'] = model;
      if (year != null) data['year'] = year;
      if (color != null) data['color'] = color;
      if (vehicleType != null) data['vehicle_type'] = vehicleType;
      if (capacity != null) data['capacity'] = capacity;

      final response = await _apiClient.put(
        '${ApiEndpoints.vehicles}/$vehicleId',
        data: data,
      );

      final responseData = response.data;
      final vehicleData = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
      return VehicleModel.fromJson(Map<String, dynamic>.from(vehicleData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar estado del vehículo (activo/inactivo)
  Future<VehicleModel> updateVehicleStatus({
    required int vehicleId,
    required bool active,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.vehicles}/$vehicleId/status',
        data: {'active': active},
      );

      final data = response.data;
      final vehicleData = data is Map ? (data['data'] ?? data) : data;
      return VehicleModel.fromJson(Map<String, dynamic>.from(vehicleData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar vehículo
  Future<void> deleteVehicle(int vehicleId) async {
    try {
      await _apiClient.delete('${ApiEndpoints.vehicles}/$vehicleId');
    } catch (e) {
      rethrow;
    }
  }
}
