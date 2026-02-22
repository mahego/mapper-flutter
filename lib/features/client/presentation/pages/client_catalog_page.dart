import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Catálogo de una tienda para el cliente (ruta /cliente/catalog/:storeId).
/// Carga productos de GET /stores/:storeId/products.
class ClientCatalogPage extends StatefulWidget {
  final String storeId;

  const ClientCatalogPage({super.key, required this.storeId});

  @override
  State<ClientCatalogPage> createState() => _ClientCatalogPageState();
}

class _ClientCatalogPageState extends State<ClientCatalogPage> {
  final _apiClient = ApiClient();
  late final _notificationService = NotificationService(apiClient: ApiClient());
  
  List<dynamic> _products = [];
  String _storeName = 'Tienda';
  bool _loading = true;
  String? _error;
  
  bool _drawerOpen = false;
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final productsRes = await _apiClient.get(ApiEndpoints.storeProductsList(widget.storeId));
      final data = productsRes.data;
      final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
      if (mounted) {
        setState(() {
          _products = list is List ? list : [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el catálogo.';
          _loading = false;
        });
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
                        Expanded(
                          child: Text(
                            'Catálogo',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                        : _error != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                      const SizedBox(height: 16),
                                      TextButton(onPressed: _load, child: const Text('Reintentar')),
                                    ],
                                  ),
                                ),
                              )
                            : _products.isEmpty
                                ? Center(
                                    child: Text(
                                      'Esta tienda no tiene productos publicados.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    itemCount: _products.length,
                                    itemBuilder: (context, i) {
                                      final p = _products[i] as Map<String, dynamic>;
                                      final name = p['name'] ?? p['title'] ?? 'Producto';
                                      final price = p['price'] ?? p['unitPrice'] ?? 0;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        color: Colors.white.withOpacity(0.08),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                        ),
                                        child: ListTile(
                                          title: Text(name, style: const TextStyle(color: Colors.white)),
                                          subtitle: Text(
                                            '\$${price.toStringAsFixed(2)}',
                                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
                    'Catálogo',
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
                        _load();
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
