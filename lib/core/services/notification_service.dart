import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Modelo de notificación desde la API
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notificación',
      message: json['message'] as String? ?? json['body'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      type: json['type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'type': type,
        'metadata': metadata,
      };
}

/// Servicio de notificaciones
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtener todas las notificaciones del usuario
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.client.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'] ?? data ?? [];
        return items
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Obtener cantidad de notificaciones sin leer
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.client.get(
        '/notifications/unread/count',
      );

      if (response.statusCode == 200) {
        return response.data['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Marcar una notificación como leída
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.client.patch(
        '/notifications/$notificationId/read',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.client.patch(
        '/notifications/read-all',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Obtener notificaciones sin leer
  Future<List<NotificationModel>> getUnreadNotifications({
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.client.get(
        '/notifications/unread',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'] ?? data ?? [];
        return items
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching unread notifications: $e');
      return [];
    }
  }

  /// Eliminar una notificación
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.client.delete(
        '/notifications/$notificationId',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Registrar FCM token en el servidor
  Future<bool> registerFcmToken(String token) async {
    try {
      final response = await _apiClient.client.post(
        '/notifications/fcm-token',
        data: {'token': token},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error registering FCM token: $e');
      return false;
    }
  }
}
