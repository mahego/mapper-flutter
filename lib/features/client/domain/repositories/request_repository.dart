import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../entities/service_request.dart';

/// Categoría de servicio (GET /services/service-categories)
class ServiceCategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final bool requiresOrigin;
  final double basePrice;
  final double pricePerKm;
  final List<ServiceTypeModel> services;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.requiresOrigin = true,
    this.basePrice = 150,
    this.pricePerKm = 12,
    required this.services,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'] as List<dynamic>? ?? [];
    return ServiceCategoryModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? json['label'] ?? '') as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      requiresOrigin: json['requires_origin'] ?? json['requiresPickup'] ?? true,
      basePrice: (json['base_price'] ?? json['basePrice'] ?? 150).toDouble(),
      pricePerKm: (json['price_per_km'] ?? json['pricePerKm'] ?? 12).toDouble(),
      services: servicesList.map((e) => ServiceTypeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }
}

/// Tipo de servicio dentro de una categoría
class ServiceTypeModel {
  final int id;
  final String name;
  final String? icon;
  final double basePrice;
  final double pricePerKm;
  final bool requiresOrigin;

  const ServiceTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.basePrice = 150,
    this.pricePerKm = 12,
    this.requiresOrigin = true,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? json['title'] ?? '') as String,
      icon: json['icon'] as String?,
      basePrice: (json['base_price'] ?? json['basePrice'] ?? 150).toDouble(),
      pricePerKm: (json['price_per_km'] ?? json['pricePerKm'] ?? 12).toDouble(),
      requiresOrigin: json['requires_origin'] ?? json['requiresPickup'] ?? true,
    );
  }
}

/// Dirección guardada (GET /addresses)
class SavedAddressModel {
  final int id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  const SavedAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: (json['id'] ?? 0) as int,
      label: (json['label'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      latitude: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
    );
  }
}

/// Tienda (GET /stores con clientLat, clientLng)
class StoreModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? distance;
  final bool active;
  final String? imageUrl;
  final String? description;

  const StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.lat = 0,
    this.lng = 0,
    this.distance,
    this.active = true,
    this.imageUrl,
    this.description,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      lat: (json['lat'] ?? json['latitude'] ?? 0).toDouble(),
      lng: (json['lng'] ?? json['longitude'] ?? 0).toDouble(),
      distance: json['distance']?.toDouble(),
      active: json['active'] ?? true,
      imageUrl: json['imageUrl'] ?? json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// Resumen de tienda para "Volver a pedir" (desde GET /store-orders)
class RecentStoreModel {
  final String id;
  final String name;

  const RecentStoreModel({required this.id, required this.name});
}

/// Item unificado para lista: solicitud de servicio O pedido de tienda (paridad Angular request-list)
enum UnifiedRequestType { service, store }

class UnifiedRequestItem {
  final String id;
  final UnifiedRequestType type;
  final String status;
  final double amount;
  final String createdAt;
  final String location;
  final String? providerName;
  final String? storeName;
  final String? serviceTypeName;
  final String? serviceCategory;

  const UnifiedRequestItem({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.location,
    this.providerName,
    this.storeName,
    this.serviceTypeName,
    this.serviceCategory,
  });
}

class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository(this._apiClient);

  /// Categorías con servicios (paridad Angular getServiceCategoriesOrganizational)
  Future<List<ServiceCategoryModel>> getServiceCategories() async {
    final response = await _apiClient.get(ApiEndpoints.serviceCategories);
    final data = response.data;
    final raw = data is Map ? (data['data'] ?? data) : data;
    final list = raw is Map ? (raw['categories'] ?? raw) : (raw is List ? raw : []);
    if (list is! List) return [];
    return list.map((e) => ServiceCategoryModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// Direcciones guardadas (GET /addresses)
  Future<List<SavedAddressModel>> getSavedAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.addresses);
      final data = response.data;
      final list = data is Map ? (data['addresses'] ?? data['data']?['addresses'] ?? []) : (data is List ? data : []);
      if (list is! List) return [];
      return list.map((e) => SavedAddressModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Guardar dirección (POST /addresses)
  Future<void> saveAddress({required String label, required String address, required double latitude, required double longitude}) async {
    await _apiClient.post(ApiEndpoints.addresses, data: {
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  /// Crear solicitud express (POST /requests/express) – paridad Angular
  Future<Map<String, dynamic>> createExpressRequest({
    required int categoryId,
    required String deliveryLocation,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required double offeredPrice,
    int? serviceTypeId,
    String? serviceTypeName,
    String? pickupLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    String? description,
    String urgency = 'normal',
  }) async {
    final payload = <String, dynamic>{
      'category_id': categoryId,
      'delivery_location': deliveryLocation,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'offered_price': offeredPrice,
      'urgency': urgency,
    };
    if (serviceTypeId != null) payload['service_type_id'] = serviceTypeId;
    if (serviceTypeName != null) payload['service_type_name'] = serviceTypeName;
    if (pickupLocation != null) payload['pickup_location'] = pickupLocation;
    if (pickupLatitude != null) payload['pickup_latitude'] = pickupLatitude;
    if (pickupLongitude != null) payload['pickup_longitude'] = pickupLongitude;
    if (description != null && description.isNotEmpty) payload['description'] = description;

    final response = await _apiClient.post(ApiEndpoints.expressRequest, data: payload);
    final d = response.data;
    return d is Map ? Map<String, dynamic>.from(d) : {'success': true};
  }

  /// Get all requests for the current client (paridad Angular: role=client, page, limit)
  Future<List<ServiceRequest>> getMyRequests({int page = 1, int limit = 10, String? status}) async {
    final queryParams = <String, dynamic>{'role': 'client', 'page': page, 'limit': limit};
    if (status != null && status != 'all') queryParams['status'] = status;
    final response = await _apiClient.get(
      ApiEndpoints.clientRequests,
      queryParameters: queryParams,
    );
    final responseData = response.data;
    print('📦 API Response: $responseData');
    print('📦 Response type: ${responseData.runtimeType}');
    
    if (responseData is! Map) return [];
    final data = responseData['data'] ?? responseData;
    print('📦 Data extracted: $data');
    
    List<dynamic> items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final raw = data['items'] ?? data['requests'];
      items = raw is List ? raw : [];
    }
    print('📦 Items found: ${items.length}');
    if (items.isEmpty) return [];
    
    try {
      return items.map((item) {
        print('📦 Parsing item: $item');
        return ServiceRequest.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
    } catch (e, stackTrace) {
      print('❌ Error parsing ServiceRequest: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get a specific request by ID
  Future<ServiceRequest> getRequestById(String requestId) async {
    final response = await _apiClient.get(ApiEndpoints.requestDetail(requestId));
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }

  /// Create a new service request
  Future<ServiceRequest> createRequest(Map<String, dynamic> requestData) async {
    final response = await _apiClient.post(
      ApiEndpoints.createRequest,
      data: requestData,
    );
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }

  /// Update an existing request
  Future<ServiceRequest> updateRequest(String requestId, Map<String, dynamic> updates) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateRequest(requestId),
      data: updates,
    );
    final responseData = response.data;
    final data = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
    return ServiceRequest.fromJson(data);
  }

  /// Tiendas disponibles (GET /stores?clientLat=&clientLng=&active=true) – paridad Angular
  Future<List<StoreModel>> getStores({double lat = 0, double lng = 0, bool activeOnly = true}) async {
    try {
      final queryParams = <String, dynamic>{'active': 'true'};
      if (lat != 0 || lng != 0) {
        queryParams['clientLat'] = lat;
        queryParams['clientLng'] = lng;
      }
      final response = await _apiClient.get(ApiEndpoints.stores, queryParameters: queryParams);
      final data = response.data;
      final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
      if (list is! List) return [];
      final stores = list.map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      stores.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
      return stores;
    } catch (_) {
      return [];
    }
  }

  /// Lista unificada: solicitudes de servicio + pedidos de tienda (paridad Angular request-list)
  Future<List<UnifiedRequestItem>> getUnifiedRequests({
    String type = 'all',
    String status = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    print('🔍 getUnifiedRequests - type: $type, status: $status');
    final List<UnifiedRequestItem> result = [];
    
    if (type != 'store') {
      try {
        print('🔍 Fetching service requests...');
        final requests = await getMyRequests(page: page, limit: limit, status: status == 'all' ? null : status);
        print('🔍 Service requests fetched: ${requests.length}');
        for (final r in requests) {
          result.add(UnifiedRequestItem(
            id: r.id,
            type: UnifiedRequestType.service,
            status: r.status,
            amount: r.estimatedCost ?? r.finalCost ?? 0,
            createdAt: r.createdAt.toIso8601String(),
            location: r.originAddress,
            providerName: r.providerName,
            serviceTypeName: r.serviceType,
            serviceCategory: null,
          ));
        }
      } catch (e, stackTrace) {
        print('❌ Error fetching service requests: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    }
    if (type != 'service') {
      try {
        final response = await _apiClient.get(
          ApiEndpoints.storeOrders,
          queryParameters: status == 'all' ? null : {'status': status},
        );
        final data = response.data;
        final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
        if (list is List) {
          for (final o in list) {
            final map = Map<String, dynamic>.from(o as Map);
            result.add(UnifiedRequestItem(
              id: (map['id'] ?? '').toString(),
              type: UnifiedRequestType.store,
              status: (map['status'] ?? 'pending') as String,
              amount: (map['total'] ?? map['totalCents'] ?? 0) is int
                  ? (map['total'] as int? ?? map['totalCents'] as int? ?? 0) / 100.0
                  : (map['total'] ?? 0).toDouble(),
              createdAt: map['createdAt'] ?? map['created_at'] ?? DateTime.now().toIso8601String(),
              location: (map['deliveryAddress'] ?? map['delivery_address'] ?? '') as String,
              storeName: (map['storeName'] ?? map['store_name']) as String?,
              providerName: (map['providerName'] ?? map['provider_name']) as String?,
            ));
          }
        }
      } catch (_) {}
    }
    result.sort((a, b) => (b.createdAt).compareTo(a.createdAt));
    print('🔍 Total unified requests: ${result.length}');
    return result;
  }

  /// Pedidos del cliente para "Volver a pedir" (GET /store-orders) – paridad Angular
  Future<List<RecentStoreModel>> getRecentOrderStores({String? status}) async {
    try {
      final queryParams = status != null ? <String, dynamic>{'status': status} : null;
      final response = await _apiClient.get(ApiEndpoints.storeOrders, queryParameters: queryParams);
      final data = response.data;
      final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
      if (list is! List) return [];
      final seen = <String>{};
      final result = <RecentStoreModel>[];
      for (final o in list) {
        final map = Map<String, dynamic>.from(o as Map);
        final id = (map['storeId'] ?? map['store_id'] ?? '').toString();
        if (id.isEmpty || seen.contains(id)) continue;
        seen.add(id);
        result.add(RecentStoreModel(
          id: id,
          name: (map['storeName'] ?? map['store_name'] ?? 'Tienda') as String,
        ));
        if (result.length >= 6) break;
      }
      return result;
    } catch (_) {
      return [];
    }
  }
}
