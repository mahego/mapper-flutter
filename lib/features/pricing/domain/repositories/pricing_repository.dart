import '../../../../core/network/api_client.dart';

/// Model para estimación de precio
class PricingEstimateModel {
  final double basePrice;
  final double distanceKm;
  final double pricePerKm;
  final double distanceCost;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final Map<String, double>? breakdown;

  const PricingEstimateModel({
    required this.basePrice,
    required this.distanceKm,
    required this.pricePerKm,
    required this.distanceCost,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.breakdown,
  });

  factory PricingEstimateModel.fromJson(Map<String, dynamic> json) {
    return PricingEstimateModel(
      basePrice: (json['base_price'] ?? json['basePrice'] as num).toDouble(),
      distanceKm: (json['distance_km'] ?? json['distanceKm'] as num).toDouble(),
      pricePerKm: (json['price_per_km'] ?? json['pricePerKm'] as num).toDouble(),
      distanceCost: (json['distance_cost'] ?? json['distanceCost'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num? ?? 0).toDouble(),
      discount: (json['discount'] as num? ?? 0).toDouble(),
      total: (json['total'] as num).toDouble(),
      breakdown: (json['breakdown'] as Map?)?.cast<String, double>(),
    );
  }
}

/// Model para configuración de precios
class PricingConfigModel {
  final double basePrice;
  final double pricePerKm;
  final double surgeMultiplier;
  final double minPrice;
  final double maxPrice;
  final double taxRate;
  final Map<String, double>? categoryPrices;

  const PricingConfigModel({
    required this.basePrice,
    required this.pricePerKm,
    required this.surgeMultiplier,
    required this.minPrice,
    required this.maxPrice,
    required this.taxRate,
    this.categoryPrices,
  });

  factory PricingConfigModel.fromJson(Map<String, dynamic> json) {
    return PricingConfigModel(
      basePrice: (json['base_price'] ?? json['basePrice'] as num).toDouble(),
      pricePerKm: (json['price_per_km'] ?? json['pricePerKm'] as num).toDouble(),
      surgeMultiplier: (json['surge_multiplier'] ?? json['surgeMultiplier'] as num? ?? 1.0).toDouble(),
      minPrice: (json['min_price'] ?? json['minPrice'] as num? ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? json['maxPrice'] as num? ?? 9999).toDouble(),
      taxRate: (json['tax_rate'] ?? json['taxRate'] as num? ?? 0.16).toDouble(),
      categoryPrices: (json['category_prices'] ?? json['categoryPrices'] as Map?)?.cast<String, double>(),
    );
  }
}

/// Repository para gestionar cálculo de precios
class PricingRepository {
  final ApiClient _apiClient;

  PricingRepository(this._apiClient);

  /// Calcular precio estimado para un servicio
  Future<PricingEstimateModel> calculatePrice({
    required int serviceId,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'service_id': serviceId,
        'origin': {
          'lat': originLat,
          'lng': originLng,
        },
        'destination': {
          'lat': destLat,
          'lng': destLng,
        },
        if (additionalData != null) ...additionalData,
      };

      final response = await _apiClient.post(
        '/pricing/calculate',
        data: data,
      );

      final responseData = response.data;
      final priceData = responseData is Map ? (responseData['data'] ?? responseData) : responseData;
      return PricingEstimateModel.fromJson(Map<String, dynamic>.from(priceData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Calcular distancia entre dos puntos
  Future<Map<String, dynamic>> calculateDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final response = await _apiClient.post(
        '/pricing/calculate-distance',
        data: {
          'origin': {
            'lat': originLat,
            'lng': originLng,
          },
          'destination': {
            'lat': destLat,
            'lng': destLng,
          },
        },
      );

      final data = response.data;
      return data is Map
          ? Map<String, dynamic>.from(data)
          : {'distance_km': 0, 'duration_minutes': 0};
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener configuración de precios para un servicio
  Future<PricingConfigModel> getServicePricing(int serviceId) async {
    try {
      final response = await _apiClient.get('/pricing/calculator/$serviceId');
      final data = response.data;

      final configData = data is Map ? (data['data'] ?? data) : data;
      return PricingConfigModel.fromJson(Map<String, dynamic>.from(configData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener tasas de precios generales
  Future<PricingConfigModel> getPricingRates() async {
    try {
      final response = await _apiClient.get('/pricing/rates');
      final data = response.data;

      final configData = data is Map ? (data['data'] ?? data) : data;
      return PricingConfigModel.fromJson(Map<String, dynamic>.from(configData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener configuración de precios general
  Future<PricingConfigModel> getPricingConfig() async {
    try {
      final response = await _apiClient.get('/pricing/config');
      final data = response.data;

      final configData = data is Map ? (data['data'] ?? data) : data;
      return PricingConfigModel.fromJson(Map<String, dynamic>.from(configData as Map));
    } catch (e) {
      rethrow;
    }
  }
}
