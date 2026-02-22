import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/client_bottom_nav.dart';
import '../../domain/entities/client_stats.dart';
import '../../domain/repositories/client_repository.dart';
import '../widgets/client_stat_card.dart';
import '../widgets/quick_action_card.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final _clientRepository = ClientRepository(ApiClient());
  ClientStats? _stats;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final stats = await _clientRepository.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar estadísticas: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      appBar: AppBar(
        title: const Text('Panel de Cliente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '¡Hola! 👋',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestiona tus solicitudes, tiendas y seguimiento',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Loading State
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                    ),
                  ),
                ),

              // Error State
              if (_error.isNotEmpty && !_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadStats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06b6d4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Stats Cards
              if (_stats != null && !_isLoading) ...[
                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    ClientStatCard(
                      title: 'Total Solicitudes',
                      value: _stats!.totalRequests.toString(),
                      icon: Icons.receipt_long,
                      color: const Color(0xFF06b6d4),
                    ),
                    ClientStatCard(
                      title: 'Activas',
                      value: _stats!.activeRequests.toString(),
                      icon: Icons.autorenew,
                      color: const Color(0xFFf97316),
                    ),
                    ClientStatCard(
                      title: 'Completadas',
                      value: _stats!.completedRequests.toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF10b981),
                    ),
                    ClientStatCard(
                      title: 'Pendientes',
                      value: _stats!.pendingRequests.toString(),
                      icon: Icons.pending,
                      color: const Color(0xFFf59e0b),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Actions (Hidden on mobile as they're in bottom nav)
                MediaQuery.of(context).size.width >= 768
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              QuickActionCard(
                                title: 'Nueva Solicitud',
                                description: 'Crea y revisa solicitudes de servicio',
                                icon: Icons.add_circle,
                                iconColor: const Color(0xFFf97316),
                                onTap: () => context.push('/requests/new'),
                              ),
                              QuickActionCard(
                                title: 'Mis Solicitudes',
                                description: 'Estatus en tiempo real',
                                icon: Icons.list_alt,
                                iconColor: const Color(0xFF06b6d4),
                                onTap: () => context.go('/requests'),
                              ),
                              QuickActionCard(
                                title: 'Tracking en Vivo',
                                description: 'Ubica tu servicio activo',
                                icon: Icons.location_on,
                                iconColor: const Color(0xFF10b981),
                                onTap: () => context.go('/cliente/tracking'),
                              ),
                              QuickActionCard(
                                title: 'Subastas',
                                description: 'Puja, gana o crea subastas',
                                icon: Icons.gavel,
                                iconColor: const Color(0xFFf59e0b),
                                onTap: () => context.go('/auctions'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
