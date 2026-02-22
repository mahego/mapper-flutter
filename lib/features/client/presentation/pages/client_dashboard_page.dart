import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    _userName = _storage.getUserName() ?? 'Cliente';
    _getLocationAndLoad();
    _loadRecentOrderStores();
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
      body: LiquidGlassBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Panel de cliente',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hola, $_userName',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Gestiona tus solicitudes, tiendas y seguimiento',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _loadStores();
                                _loadRecentOrderStores();
                              },
                              icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.8), size: 22),
                              tooltip: 'Refrescar',
                            ),
                            IconButton(
                              onPressed: () => context.go('/login'),
                              icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.8), size: 22),
                              tooltip: 'Cerrar sesión',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      if (_loadingStores)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text('Cargando tiendas...', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          ),
                        ),
                      if (!_loadingStores && _filteredStores.isEmpty) _buildNoStoresCta(),
                      if (_hasStoresToShow && _recentOrderStores.isNotEmpty) _buildVolverAPedir(),
                      if (_hasStoresToShow) _buildTiendasDisponibles(),
                      const SizedBox(height: 24),
                      _buildDatosCuenta(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              icon: Icons.clipboard_list,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'No hay tiendas disponibles en tu área en este momento.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.replay, color: Colors.amber.shade400, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Volver a pedir',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tiendas donde ya pediste',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentOrderStores.map((s) {
            return ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.name),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.6)),
                ],
              ),
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
              labelStyle: const TextStyle(color: Colors.white),
              onPressed: () => context.push('/cliente/catalog/${s.id}'),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTiendasDisponibles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.store_outlined, color: Colors.cyan.shade400, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Tiendas disponibles',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Explora las tiendas cercanas y haz tu compra',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar tiendas...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ordenadas por cercanía. Las más cercanas primero.',
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _displayedStores.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final store = _displayedStores[index];
            return LiquidGlassCard(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => context.push('/cliente/catalog/${store.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.store, color: Colors.white.withOpacity(0.6)),
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
                                  store.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (store.distance != null)
                                Text(
                                  '${store.distance!.toStringAsFixed(1)} km',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.address,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf97316), Color(0xFF06b6d4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Ver Catálogo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_hasMoreStores || (_showAllStores && _filteredStores.length > _initialStoresCount))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton(
                onPressed: () => setState(() => _showAllStores = !_showAllStores),
                child: Text(
                  _showAllStores ? 'Ver menos' : 'Ver más (${_filteredStores.length - _initialStoresCount} más)',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
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
            Icon(Icons.info_outline, color: const Color(0xFF06b6d4).withOpacity(0.8)),
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
