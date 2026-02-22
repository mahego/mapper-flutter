import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/network/api_client.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
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
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  Future<void> _markNotificationsAsRead() async {
    if (_unreadNotificationsCount > 0) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      try {
        await _notificationService.markAllAsRead();
      } catch (e) {
        print('Error marking notifications as read: $e');
      }
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
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    expandedHeight: 100,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.all(20),
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
                            Text(
                              'Panel Prestador',
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
                                    onPressed: () => context.go('/auth/login'),
                                    icon: const Icon(Icons.logout, color: Colors.white70),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFf97316).withOpacity(0.3),
                                width: 1.5,
                              ),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estado Actual',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Fuera de servicio',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: false,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFFf97316),
                                  inactiveThumbColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: LiquidGlassCard(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '\$0',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFf97316),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ganancia Hoy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LiquidGlassCard(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '0',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF22d3ee),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Solicitudes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions
                          const Text(
                            'Acciones Rápidas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _ActionCard(
                                icon: Icons.assignment,
                                label: 'Ver Solicitudes',
                                onTap: () {},
                              ),
                              _ActionCard(
                                icon: Icons.calendar_today,
                                label: 'Mis Horarios',
                                onTap: () {},
                              ),
                              _ActionCard(
                                icon: Icons.paid,
                                label: 'Ganancias',
                                onTap: () {},
                              ),
                              _ActionCard(
                                icon: Icons.card_membership,
                                label: 'Suscripción',
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Recent Requests
                          const Text(
                            'Solicitudes Recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          LiquidGlassCard(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox,
                                      size: 48,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Sin solicitudes activas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Subscription Info
                          LiquidGlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.card_membership,
                                        color: const Color(0xFFf97316).withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Mi Suscripción',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color: Color(0xFFf97316),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Plan: Sin Suscripción',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Renovación: No aplica',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: width < 768 ? 80 : 32),
                        ],
                      ),
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
                    'Panel Prestador',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _drawerLink('Solicitudes', Icons.assignment_outlined, () {
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Refrescar', Icons.refresh, () {
                        _loadNotificationCount();
                        setState(() => _drawerOpen = false);
                      }),
                      Divider(color: Colors.white12, height: 24, indent: 16, endIndent: 16),
                      _drawerLink('Cerrar sesión', Icons.logout, () {
                        context.go('/auth/login');
                      }, color: const Color(0xFFf97316)),
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

  Widget _drawerLink(String label, IconData icon, VoidCallback onTap, {Color color = Colors.white}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color.withOpacity(0.8)),
        title: Text(label, style: TextStyle(color: color)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFf97316).withOpacity(0.3),
                    const Color(0xFF22d3ee).withOpacity(0.2),
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
