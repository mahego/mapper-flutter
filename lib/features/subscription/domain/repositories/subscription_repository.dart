import '../../../../core/network/api_client.dart';

/// Model para plan de suscripción
class SubscriptionPlanModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String billingCycle; // 'monthly', 'yearly'
  final List<String> features;
  final int maxServices;
  final int maxRequests;
  final bool includedTracking;
  final bool includedAnalytics;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
    required this.maxServices,
    required this.maxRequests,
    required this.includedTracking,
    required this.includedAnalytics,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      features: (json['features'] as List?)?.cast<String>() ?? [],
      maxServices: json['max_services'] as int? ?? 999,
      maxRequests: json['max_requests'] as int? ?? 999,
      includedTracking: json['included_tracking'] as bool? ?? true,
      includedAnalytics: json['included_analytics'] as bool? ?? true,
    );
  }
}

/// Model para suscripción activa del usuario
class ActiveSubscriptionModel {
  final int id;
  final int userId;
  final int planId;
  final String status; // 'active', 'cancelled', 'expired'
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final SubscriptionPlanModel? plan;

  const ActiveSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.paymentMethod,
    required this.createdAt,
    this.cancelledAt,
    this.plan,
  });

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'card',
      createdAt: DateTime.parse(json['created_at'] as String),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      plan: json['plan'] != null
          ? SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(json['plan'] as Map))
          : null,
    );
  }
}

/// Repository para gestionar suscripciones
class SubscriptionRepository {
  final ApiClient _apiClient;

  SubscriptionRepository(this._apiClient);

  /// Obtener suscripción actual del usuario
  Future<ActiveSubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get('/subscriptions/current');
      final data = response.data;

      if (data is Map) {
        final subData = data['data'] ?? data;
        if (subData is Map && subData.isNotEmpty) {
          return ActiveSubscriptionModel.fromJson(Map<String, dynamic>.from(subData));
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Listar todos los planes disponibles
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async {
    try {
      final response = await _apiClient.get('/subscriptions');
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['plans'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de un plan específico
  Future<SubscriptionPlanModel> getPlanDetails(int planId) async {
    try {
      final response = await _apiClient.get('/subscriptions/$planId');
      final data = response.data;

      final planData = data is Map ? (data['data'] ?? data) : data;
      return SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(planData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Crear/activar nueva suscripción
  Future<ActiveSubscriptionModel> createSubscription({
    required int planId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/subscriptions',
        data: {
          'plan_id': planId,
          'payment_method_id': paymentMethodId,
        },
      );

      final data = response.data;
      final subData = data is Map ? (data['data'] ?? data) : data;
      return ActiveSubscriptionModel.fromJson(Map<String, dynamic>.from(subData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Procesar pago de suscripción
  Future<Map<String, dynamic>> processSubscriptionPayment({
    required int subscriptionId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/subscriptions/payment',
        data: {
          'subscription_id': subscriptionId,
          'payment_method_id': paymentMethodId,
        },
      );

      return response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : {'success': true};
    } catch (e) {
      rethrow;
    }
  }

  /// Cancelar suscripción
  Future<void> cancelSubscription(int subscriptionId) async {
    try {
      await _apiClient.delete('/subscriptions/$subscriptionId');
    } catch (e) {
      rethrow;
    }
  }

  /// Renovar suscripción vencida
  Future<ActiveSubscriptionModel> renewSubscription({
    required int subscriptionId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/subscriptions/$subscriptionId/renew',
        data: {'payment_method_id': paymentMethodId},
      );

      final data = response.data;
      final subData = data is Map ? (data['data'] ?? data) : data;
      return ActiveSubscriptionModel.fromJson(Map<String, dynamic>.from(subData as Map));
    } catch (e) {
      rethrow;
    }
  }
}
