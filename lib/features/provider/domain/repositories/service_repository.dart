import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Model para servicio de prestador
class ServiceModel {
  final int id;
  final int providerId;
  final int categoryId;
  final String title;
  final String description;
  final double? minPrice;
  final double? maxPrice;
  final double? pricePerKm;
  final int? coverageRadius;
  final String status;
  final List<int> serviceTypeIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.minPrice,
    this.maxPrice,
    this.pricePerKm,
    this.coverageRadius,
    required this.status,
    required this.serviceTypeIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      providerId: json['provider_id'] ?? json['userId'] as int,
      categoryId: json['category_id'] ?? json['categoryId'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      minPrice: (json['min_price'] ?? json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] ?? json['maxPrice'] as num?)?.toDouble(),
      pricePerKm: (json['price_per_km'] ?? json['pricePerKm'] as num?)?.toDouble(),
      coverageRadius: json['coverage_radius'] ?? json['coverageRadius'] as int?,
      status: json['status'] as String? ?? 'active',
      serviceTypeIds: (json['service_type_ids'] as List?)?.cast<int>() ?? [],
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
      'category_id': categoryId,
      'title': title,
      'description': description,
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_per_km': pricePerKm,
      'coverage_radius': coverageRadius,
      'status': status,
      'service_type_ids': serviceTypeIds,
    };
  }
}

/// Repository para gestionar servicios del prestador
class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository(this._apiClient);

  /// Obtener mis servicios (prestador autenticado)
  Future<List<ServiceModel>> getMyServices() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myServices);
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['services'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de un servicio específico
  Future<ServiceModel> getServiceDetail(int serviceId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.services}/$serviceId');
      final data = response.data;

      final serviceData = data is Map ? (data['data'] ?? data) : data;
      return ServiceModel.fromJson(Map<String, dynamic>.from(serviceData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo servicio
  Future<ServiceModel> createService({
    required int categoryId,
    required String title,
    required String description,
    required List<int> serviceTypeIds,
    double? minPrice,
    double? maxPrice,
    double? pricePerKm,
    int? coverageRadius,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.services,
        data: {
          'category_id': categoryId,
          'title': title,
          'description': description,
          'service_type_ids': serviceTypeIds,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (pricePerKm != null) 'price_per_km': pricePerKm,
          if (coverageRadius != null) 'coverage_radius': coverageRadius,
        },
      );

      final data = response.data;
      final serviceData = data is Map ? (data['data'] ?? data) : data;
      return ServiceModel.fromJson(Map<String, dynamic>.from(serviceData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar servicio existente
  Future<ServiceModel> updateService({
    required int serviceId,
    String? title,
    String? description,
    List<int>? serviceTypeIds,
    double? minPrice,
    double? maxPrice,
    double? pricePerKm,
    int? coverageRadius,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (serviceTypeIds != null) data['service_type_ids'] = serviceTypeIds;
      if (minPrice != null) data['min_price'] = minPrice;
      if (maxPrice != null) data['max_price'] = maxPrice;
      if (pricePerKm != null) data['price_per_km'] = pricePerKm;
      if (coverageRadius != null) data['coverage_radius'] = coverageRadius;

      final response = await _apiClient.put(
        '${ApiEndpoints.services}/$serviceId',
        data: data,
      );

      final responseData = response.data;
      final serviceData = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
      return ServiceModel.fromJson(Map<String, dynamic>.from(serviceData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar estado del servicio (activo/pausado)
  Future<ServiceModel> updateServiceStatus({
    required int serviceId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.services}/$serviceId/status',
        data: {'status': status},
      );

      final data = response.data;
      final serviceData = data is Map ? (data['data'] ?? data) : data;
      return ServiceModel.fromJson(Map<String, dynamic>.from(serviceData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar servicio
  Future<void> deleteService(int serviceId) async {
    try {
      await _apiClient.delete('${ApiEndpoints.services}/$serviceId');
    } catch (e) {
      rethrow;
    }
  }
}
