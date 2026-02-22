import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/notification_service.dart';

/// Panel de notificaciones con diseño Liquid Glass
class NotificationsPanel extends StatefulWidget {
  final NotificationService? notificationService;
  final int unreadCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onClose;

  const NotificationsPanel({
    super.key,
    this.notificationService,
    this.unreadCount = 0,
    this.onNotificationTap,
    this.onClose,
  });

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  late List<NotificationModel> _notifications;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notifications = [];
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.notificationService == null) {
      _notifications = _getMockNotifications();
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    try {
      final notifications = await widget.notificationService!.getNotifications(limit: 10);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _notifications = _getMockNotifications();
          _isLoading = false;
        });
      }
    }
  }

  // Mock notifications para fallback
  List<NotificationModel> _getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Nueva solicitud',
        message: 'Tu solicitud #1234 ha sido aceptada',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: 'request',
      ),
      NotificationModel(
        id: '2',
        title: 'En camino',
        message: 'Tu entrega está en camino. Tiempo estimado: 15 min',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        type: 'delivery',
      ),
      NotificationModel(
        id: '3',
        title: 'Entrega completada',
        message: 'Tu pedido ha sido entregado exitosamente',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'system',
      ),
    ];
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'request':
        return const Color(0xFFf97316); // Orange
      case 'delivery':
        return const Color(0xFF10b981); // Green
      case 'system':
        return const Color(0xFF06b6d4); // Cyan
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'request':
        return Icons.assignment;
      case 'delivery':
        return Icons.local_shipping;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width - 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.unreadCount > 0)
                          Text(
                            '${widget.unreadCount} sin leer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf97316).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_notifications.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFf97316),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications list
              Flexible(
                child: _notifications.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 48,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sin notificaciones',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.white.withOpacity(0.05),
                          height: 1,
                          indent: 12,
                          endIndent: 12,
                        ),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationItem(notification);
                        },
                      ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.8),
                    ),
                    child: const Text(
                      'Ver todas las notificaciones',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onNotificationTap,
        splashColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  typeIcon,
                  size: 18,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: notification.isRead
                                  ? TextDecoration.none
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFf97316),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
