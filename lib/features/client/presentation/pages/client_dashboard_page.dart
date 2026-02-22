import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/request_repository.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final _requestRepository = RequestRepository(ApiClient());
  final _storage = StorageService();
  late final _notificationService = NotificationService(apiClient: ApiClient());

  String _userName = 'Cliente';
  double _userLat = 0;
  double _userLng = 0;

  List<StoreModel> _stores = [];
  List<RecentStoreModel> _recentOrderStores = [];
  bool _loadingStores = false;
  bool _loadingRecent = false;
  String _searchQuery = '';
  static const int _initialStoresCount = 8;
  bool _showAllStores = false;
  bool _drawerOpen = false;
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _userName = _storage.getUserName() ?? 'Cliente';
    _getLocationAndLoad();
    _loadRecentOrderStores();
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
      // Keep the default value if API fails
    }
  }

  Future<void> _getLocationAndLoad() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
        });
        _loadStores();
      }
    } catch (_) {
      if (mounted) _loadStores();
    }
  }

  Future<void> _loadStores() async {
    setState(() => _loadingStores = true);
    try {
      final list = await _requestRepository.getStores(lat: _userLat, lng: _userLng);
      if (mounted) setState(() {
        _stores = list;
        _loadingStores = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStores = false);
    }
  }

  Future<void> _loadRecentOrderStores() async {
    setState(() => _loadingRecent = true);
    try {
      final list = await _requestRepository.getRecentOrderStores();
      if (mounted) setState(() {
        _recentOrderStores = list;
        _loadingRecent = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRecent = false);
    }
  }

  List<StoreModel> get _filteredStores {
    if (_searchQuery.trim().isEmpty) return _stores;
    final q = _searchQuery.toLowerCase();
    return _stores.where((s) =>
      s.name.toLowerCase().contains(q) ||
      s.address.toLowerCase().contains(q) ||
      (s.description?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  List<StoreModel> get _displayedStores {
    final list = _filteredStores;
    if (_showAllStores || list.length <= _initialStoresCount) return list;
    return list.take(_initialStoresCount).toList();
  }

  bool get _hasMoreStores => !_showAllStores && _filteredStores.length > _initialStoresCount;
  bool get _hasStoresToShow => !_loadingStores && _filteredStores.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          LiquidGlassBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header simple
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, $_userName',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Gestiona tus servicios',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() => _showNotifications = !_showNotifications);
                                        if (_showNotifications) {
                                          _markNotificationsAsRead();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 26,
                                      ),
                                    ),
                                    if (_unreadNotificationsCount > 0)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFf97316),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$_unreadNotificationsCount',
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
                                IconButton(
                                  onPressed: () => setState(() => _drawerOpen = !_drawerOpen),
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    expandedHeight: 80,
                  ),

                  // Contenido principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (_loadingStores)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'Cargando tiendas...',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                              ),
                            ),
                          if (!_loadingStores && _filteredStores.isEmpty) _buildNoStoresCta(),
                          if (_hasStoresToShow && _recentOrderStores.isNotEmpty) _buildVolverAPedir(),
                          if (_hasStoresToShow) _buildTiendasDisponibles(),
                          const SizedBox(height: 80), // Espacio para bottom nav en mobile
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer lateral
          _buildDrawer(),

          // Panel de notificaciones
          if (_showNotifications)
            Positioned(
              top: 100,
              right: 16,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside
                child: NotificationsPanel(
                  notificationService: _notificationService,
                  unreadCount: _unreadNotificationsCount,
                  onNotificationTap: () {
                    // Mark as read when user views notification
                    _markNotificationsAsRead();
                    setState(() => _showNotifications = false);
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Ocultar en desktop (width >= 768)
    if (MediaQuery.of(context).size.width >= 768) {
      return const SizedBox.shrink();
    }

    return LiquidGlassBottomNav(
      items: const [
        BottomNavItem(
          label: 'Inicio',
          icon: Icons.home_outlined,
          route: '/dashboard/cliente',
        ),
        BottomNavItem(
          label: 'Solicitudes',
          icon: Icons.assignment_outlined,
          route: '/requests',
        ),
        BottomNavItem(
          label: 'Tracking',
          icon: Icons.location_on_outlined,
          route: '/cliente/tracking',
        ),
        BottomNavItem(
          label: 'Perfil',
          icon: Icons.person_outline,
          route: '/profile',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        final routes = [
          '/dashboard/cliente',
          '/requests',
          '/cliente/tracking',
          '/profile',
        ];
        context.go(routes[index]);
      },
      mobileOnly: true,
    );
  }

  Widget _buildDrawer() {
    return Stack(
      children: [
        if (_drawerOpen)
          GestureDetector(
            onTap: () => setState(() => _drawerOpen = false),
            child: AnimatedOpacity(
              opacity: _drawerOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
          ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: _drawerOpen ? Offset.zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: SafeArea(
              left: false,
              child: Container(
                width: 280,
                color: Colors.white.withOpacity(0.05),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menú',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Hola, $_userName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      _drawerLink(
                        icon: Icons.add_circle_outline,
                        label: 'Nueva solicitud',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.push('/requests/new');
                        },
                      ),
                      _drawerLink(
                        icon: Icons.assignment,
                        label: 'Mis solicitudes',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.push('/requests');
                        },
                      ),
                      _drawerLink(
                        icon: Icons.location_on_outlined,
                        label: 'Tracking',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.push('/cliente/tracking');
                        },
                      ),
                      _drawerLink(
                        icon: Icons.gavel,
                        label: 'Subastas',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.push('/auctions');
                        },
                      ),
                      _drawerLink(
                        icon: Icons.person_outline,
                        label: 'Mi Perfil',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.push('/profile');
                        },
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      const SizedBox(height: 12),
                      _drawerLink(
                        icon: Icons.refresh,
                        label: 'Refrescar',
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          _loadStores();
                          _loadRecentOrderStores();
                        },
                      ),
                      _drawerLink(
                        icon: Icons.logout,
                        label: 'Cerrar sesión',
                        isLogout: true,
                        onTap: () {
                          setState(() => _drawerOpen = false);
                          context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _drawerLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red.shade400 : Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isLogout ? Colors.red.shade400 : Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markNotificationsAsRead() async {
    if (_unreadNotificationsCount > 0) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      // Call API to mark all as read
      try {
        await _notificationService.markAllAsRead();
      } catch (e) {
        print('Error marking notifications as read: $e');
      }
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _ActionCard(
              icon: Icons.add_circle_outline,
              label: 'Nueva solicitud',
              onTap: () => context.push('/requests/new'),
            ),
            _ActionCard(
              icon: Icons.assignment,
              label: 'Mis solicitudes',
              onTap: () => context.push('/requests'),
            ),
            _ActionCard(
              icon: Icons.map,
              label: 'Tracking',
              onTap: () => context.push('/cliente/tracking'),
            ),
            _ActionCard(
              icon: Icons.person,
              label: 'Mi Perfil',
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoStoresCta() {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'No hay tiendas disponibles en tu área en este momento.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/requests/new'),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Crear nueva solicitud'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolverAPedir() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.import_export, color: Colors.amber.shade400, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Volver a pedir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  'Tiendas anteriores',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentOrderStores.map((s) {
            return GestureDetector(
              onTap: () => context.push('/cliente/catalog/${s.id}'),
              child: LiquidGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right, size: 14, color: Colors.white.withOpacity(0.6)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTiendasDisponibles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.store_outlined, color: Colors.cyan.shade400, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiendas disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Text(
                  'Explora las más cercanas',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar tiendas...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Por cercanía. Las más cercanas primero.',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _displayedStores.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final store = _displayedStores[index];
            return LiquidGlassCard(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => context.push('/cliente/catalog/${store.id}'),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.store, color: Colors.white.withOpacity(0.6), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  store.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (store.distance != null)
                                Text(
                                  '${store.distance!.toStringAsFixed(1)} km',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            store.address,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf97316), Color(0xFF06b6d4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Catálogo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_hasMoreStores || (_showAllStores && _filteredStores.length > _initialStoresCount))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _showAllStores = !_showAllStores),
                child: Text(
                  _showAllStores ? 'Ver menos' : 'Ver más (${_filteredStores.length - _initialStoresCount} más)',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDatosCuenta() {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: const Color(0xFF06b6d4).withOpacity(0.8)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Datos de Cuenta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const Icon(Icons.edit, size: 18, color: Color(0xFFf97316)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
