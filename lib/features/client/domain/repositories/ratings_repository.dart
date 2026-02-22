import '../../../../core/network/api_client.dart';

/// Model para calificación/reseña
class RatingModel {
  final int id;
  final int requestId;
  final int raterId;
  final int rateeId;
  final String raterRole;
  final int rating;
  final String? title;
  final String? comment;
  final String? photoUrl;
  final Map<String, int>? categories;
  final int helpfulCount;
  final int unhelpfulCount;
  final bool flagged;
  final bool anonymous;
  final DateTime createdAt;
  final String? raterName;
  final List<String>? photos;

  const RatingModel({
    required this.id,
    required this.requestId,
    required this.raterId,
    required this.rateeId,
    required this.raterRole,
    required this.rating,
    this.title,
    this.comment,
    this.photoUrl,
    this.categories,
    required this.helpfulCount,
    required this.unhelpfulCount,
    required this.flagged,
    required this.anonymous,
    required this.createdAt,
    this.raterName,
    this.photos,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as int,
      requestId: json['request_id'] as int,
      raterId: json['rater_id'] as int,
      rateeId: json['ratee_id'] as int,
      raterRole: json['rater_role'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      photoUrl: json['photo_url'] as String?,
      categories: (json['categories'] as Map?)?.cast<String, int>(),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      unhelpfulCount: json['unhelpful_count'] as int? ?? 0,
      flagged: json['flagged'] as bool? ?? false,
      anonymous: json['anonymous'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      raterName: json['rater_name'] as String?,
      photos: (json['photos'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'rater_id': raterId,
      'ratee_id': rateeId,
      'rater_role': raterRole,
      'rating': rating,
      'title': title,
      'comment': comment,
      'photo_url': photoUrl,
      'categories': categories,
      'helpful_count': helpfulCount,
      'unhelpful_count': unhelpfulCount,
      'flagged': flagged,
      'anonymous': anonymous,
      'photos': photos,
    };
  }
}

/// Model para estadísticas de rating
class RatingStatsModel {
  final double average;
  final int count;
  final Map<int, int> breakdown;

  const RatingStatsModel({
    required this.average,
    required this.count,
    required this.breakdown,
  });

  factory RatingStatsModel.fromJson(Map<String, dynamic> json) {
    return RatingStatsModel(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
      breakdown: (json['breakdown'] as Map?)?.cast<int, int>() ?? {},
    );
  }
}

/// Repository para gestionar calificaciones y reseñas
class RatingsRepository {
  final ApiClient _apiClient;

  RatingsRepository(this._apiClient);

  /// Enviar nueva calificación
  Future<RatingModel> submitRating({
    required int requestId,
    required int rateeId,
    required int rating,
    String? title,
    String? comment,
    Map<String, int>? categories,
    bool anonymous = false,
    List<String>? photos,
  }) async {
    try {
      final response = await _apiClient.post(
        '/ratings',
        data: {
          'request_id': requestId,
          'ratee_id': rateeId,
          'rating': rating,
          if (title != null) 'title': title,
          if (comment != null) 'comment': comment,
          if (categories != null) 'categories': categories,
          'anonymous': anonymous,
          if (photos != null) 'photos': photos,
        },
      );

      final data = response.data;
      final ratingData = data is Map ? (data['data'] ?? data) : data;
      return RatingModel.fromJson(Map<String, dynamic>.from(ratingData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener calificación para una solicitud específica
  Future<RatingModel?> getRatingForRequest(int requestId) async {
    try {
      final response = await _apiClient.get('/ratings/request/$requestId');
      final data = response.data;

      if (data is Map) {
        final ratingData = data['data'] ?? data;
        if (ratingData is Map && ratingData.isNotEmpty) {
          return RatingModel.fromJson(Map<String, dynamic>.from(ratingData));
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todas las calificaciones de un usuario
  Future<List<RatingModel>> getUserRatings(int userId, {String role = 'ratee'}) async {
    try {
      final response = await _apiClient.get(
        '/ratings/user/$userId',
        queryParameters: {'role': role},
      );

      final data = response.data;
      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['ratings'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => RatingModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener calificación promedio de un usuario
  Future<RatingStatsModel> getUserAverageRating(int userId) async {
    try {
      final response = await _apiClient.get('/ratings/user/$userId/average');
      final data = response.data;

      final statsData = data is Map ? (data['data'] ?? data) : data;
      return RatingStatsModel.fromJson(Map<String, dynamic>.from(statsData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles completos de una calificación
  Future<RatingModel> getRatingDetails(int ratingId) async {
    try {
      final response = await _apiClient.get('/ratings/$ratingId');
      final data = response.data;

      final ratingData = data is Map ? (data['data'] ?? data) : data;
      return RatingModel.fromJson(Map<String, dynamic>.from(ratingData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Responder a una reseña
  Future<void> respondToReview(int ratingId, String responseText) async {
    try {
      await _apiClient.post(
        '/ratings/$ratingId/respond',
        data: {'response_text': responseText},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Marcar reseña como útil/no útil
  Future<void> markReviewHelpfulness(int ratingId, bool helpful) async {
    try {
      await _apiClient.post(
        '/ratings/$ratingId/helpful',
        data: {'helpful': helpful},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reportar reseña inapropiada
  Future<void> flagReview(int ratingId, String reason) async {
    try {
      await _apiClient.post(
        '/ratings/$ratingId/flag',
        data: {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }
}
