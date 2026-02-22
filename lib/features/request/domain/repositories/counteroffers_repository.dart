import '../../../../core/network/api_client.dart';

/// Model para contrapropuesta de precio
class CounterOfferModel {
  final int id;
  final int requestId;
  final int senderId;
  final int receiverId;
  final String senderRole; // 'cliente' or 'prestador'
  final double proposedPrice;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? reason;
  final String? notes;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  const CounterOfferModel({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.senderRole,
    required this.proposedPrice,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
  });

  factory CounterOfferModel.fromJson(Map<String, dynamic> json) {
    return CounterOfferModel(
      id: json['id'] as int,
      requestId: json['request_id'] ?? json['requestId'] as int,
      senderId: json['sender_id'] ?? json['senderId'] as int,
      receiverId: json['receiver_id'] ?? json['receiverId'] as int,
      senderRole: json['sender_role'] ?? json['senderRole'] as String,
      proposedPrice: (json['proposed_price'] ?? json['proposedPrice'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_role': senderRole,
      'proposed_price': proposedPrice,
      'status': status,
      'reason': reason,
      'notes': notes,
    };
  }
}

/// Repository para gestionar contrapropuestas
class CounteroffersRepository {
  final ApiClient _apiClient;

  CounteroffersRepository(this._apiClient);

  /// Crear nueva contrapropuesta
  Future<CounterOfferModel> createCounterOffer({
    required int requestId,
    required double proposedPrice,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/counteroffers',
        data: {
          'request_id': requestId,
          'proposed_price': proposedPrice,
          if (notes != null) 'notes': notes,
        },
      );

      final data = response.data;
      final offerData = data is Map ? (data['data'] ?? data) : data;
      return CounterOfferModel.fromJson(Map<String, dynamic>.from(offerData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener contrapropuestas para una solicitud
  Future<List<CounterOfferModel>> getCounterOffersForRequest(int requestId) async {
    try {
      final response = await _apiClient.get('/counteroffers?request_id=$requestId');
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['counter_offers'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => CounterOfferModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una contrapropuesta
  Future<CounterOfferModel> getCounterOfferDetail(int offerId) async {
    try {
      final response = await _apiClient.get('/counteroffers/$offerId');
      final data = response.data;

      final offerData = data is Map ? (data['data'] ?? data) : data;
      return CounterOfferModel.fromJson(Map<String, dynamic>.from(offerData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Aceptar contrapropuesta
  Future<CounterOfferModel> acceptCounterOffer(int offerId) async {
    try {
      final response = await _apiClient.post(
        '/counteroffers/$offerId/accept',
        data: {},
      );

      final data = response.data;
      final offerData = data is Map ? (data['data'] ?? data) : data;
      return CounterOfferModel.fromJson(Map<String, dynamic>.from(offerData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Rechazar contrapropuesta
  Future<CounterOfferModel> rejectCounterOffer(String offerId, {String? reason}) async {
    try {
      final response = await _apiClient.post(
        '/counteroffers/$offerId/reject',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      final data = response.data;
      final offerData = data is Map ? (data['data'] ?? data) : data;
      return CounterOfferModel.fromJson(Map<String, dynamic>.from(offerData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Listar historial de contrapropuestas
  Future<List<CounterOfferModel>> getCounterOfferHistory({
    int? requestId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (requestId != null) 'request_id': requestId,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get('/counteroffers', queryParameters: params);
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['counter_offers'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => CounterOfferModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener resumen de contrapropuestas para una solicitud
  Future<Map<String, dynamic>> getCounterOfferSummary(int requestId) async {
    try {
      final response = await _apiClient.get('/counteroffers/$requestId/summary');
      final data = response.data;

      return data is Map
          ? Map<String, dynamic>.from(data)
          : {'pending': 0, 'accepted': 0, 'rejected': 0};
    } catch (e) {
      rethrow;
    }
  }
}
