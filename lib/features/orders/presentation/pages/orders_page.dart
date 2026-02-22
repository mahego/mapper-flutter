import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/network/api_client.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final _notificationService = NotificationService(apiClient: ApiClient());

  bool _drawerOpen = false;
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadNotificationsCount = count);
      }
    } catch (_) {
      setState(() => _unreadNotificationsCount = 0);
    }
  }

  Future<void> _markNotificationsAsRead() async {
    if (_unreadNotificationsCount > 0) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      try {
        await _notificationService.markAllAsRead();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          LiquidGlassBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
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
                        const Text(
                          'Mis Órdenes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() => _showNotifications = !_showNotifications);
                                    if (_unreadNotificationsCount > 0) {
                                      _markNotificationsAsRead();
                                    }
                                  },
                                  icon: const Icon(Icons.notifications, color: Colors.white),
                                ),
                                if (_unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFf97316),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _unreadNotificationsCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (width < 768)
                              IconButton(
                                onPressed: () {
                                  setState(() => _drawerOpen = !_drawerOpen);
                                },
                                icon: const Icon(Icons.menu, color: Colors.white),
                              )
                            else
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final status = index % 3 == 0
                            ? 'Entregada'
                            : index % 3 == 1
                                ? 'En Tránsito'
                                : 'Pendiente';
                        final statusColor = index % 3 == 0
                            ? Colors.green
                            : index % 3 == 1
                                ? Colors.orange
                                : Colors.grey;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Orden #${1000 + index}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat.yMMMd().format(
                                        DateTime.now().subtract(Duration(days: index)),
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '123 Main Street, City',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${(25.99 + index * 5).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFf97316),
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Ver Detalles',
                                        style: TextStyle(color: Color(0xFF22d3ee)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer
          if (width < 768) _buildDrawer(),
          // Notifications panel
          if (_showNotifications)
            Positioned(
              top: 100,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                child: NotificationsPanel(
                  notificationService: _notificationService,
                  unreadCount: _unreadNotificationsCount,
                  onNotificationTap: () {
                    _markNotificationsAsRead();
                    setState(() => _showNotifications = false);
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: width < 768 ? _buildBottomNav() : null,
    );
  }

  Widget _buildDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _drawerOpen ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Stack(
        children: [
          if (_drawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Órdenes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _drawerLink('Dashboard', Icons.dashboard_outlined, () {
                        context.go('/dashboard/cliente');
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Refrescar', Icons.refresh, () {
                        _loadNotificationCount();
                        setState(() => _drawerOpen = false);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLink(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.8)),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildBottomNav() {
    return LiquidGlassBottomNav(
      items: const [
        BottomNavItem(label: 'Inicio', icon: Icons.home_outlined, route: '/dashboard/cliente'),
        BottomNavItem(label: 'Solicitudes', icon: Icons.assignment_outlined, route: '/solicitudes'),
        BottomNavItem(label: 'Tracking', icon: Icons.location_on_outlined, route: '/tracking'),
        BottomNavItem(label: 'Perfil', icon: Icons.person_outline, route: '/perfil'),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard/cliente');
            break;
          case 1:
            context.go('/solicitudes');
            break;
          case 2:
            context.go('/tracking');
            break;
          case 3:
            context.go('/perfil');
            break;
        }
      },
    );
  }
}
