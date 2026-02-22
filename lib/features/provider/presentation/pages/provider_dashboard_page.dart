import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/provider_repository.dart';
import '../../domain/repositories/request_repository.dart';
import '../../domain/repositories/shift_repository.dart';
import '../../domain/entities/provider_stats.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/express_request.dart';
import '../../domain/entities/shift.dart';
import '../widgets/stat_card.dart';
import '../widgets/request_card.dart';
import '../widgets/subscription_status_card.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  final _providerRepo = ProviderRepository();
  final _requestRepo = RequestRepository();
  final _shiftRepo = ShiftRepository();

  bool isOnline = false;
  bool isTogglingOnline = false;
  
  ProviderStats? stats;
  Earnings? earnings;
  Subscription? subscription;
  List<ExpressRequest> expressRequests = [];
  Shift? activeShiftToday;

  bool isLoadingStats = true;
  bool isLoadingEarnings = true;
  bool isLoadingSubscription = true;
  bool isLoadingRequests = true;
  bool isLoadingShift = true;

  String expandedSection = 'requests'; // 'requests' or 'stats'

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadOnlineStatus(),
      _loadStats(),
      _loadEarnings(),
      _loadSubscription(),
      _loadExpressRequests(),
      _loadActiveShift(),
    ]);
  }

  Future<void> _loadOnlineStatus() async {
    try {
      final status = await _providerRepo.getOnlineStatus();
      if (mounted) {
        setState(() {
          isOnline = status;
        });
      }
    } catch (e) {
      debugPrint('Error loading online status: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final data = await _providerRepo.getStats();
      if (mounted) {
        setState(() {
          stats = data;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadEarnings() async {
    try {
      final data = await _providerRepo.getEarnings(period: 'month');
      if (mounted) {
        setState(() {
          earnings = data;
          isLoadingEarnings = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading earnings: $e');
      if (mounted) {
        setState(() {
          isLoadingEarnings = false;
        });
      }
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final data = await _providerRepo.getCurrentSubscription();
      if (mounted) {
        setState(() {
          subscription = data;
          isLoadingSubscription = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading subscription: $e');
      if (mounted) {
        setState(() {
          isLoadingSubscription = false;
        });
      }
    }
  }

  Future<void> _loadExpressRequests() async {
    try {
      final data = await _requestRepo.getExpressRequests();
      if (mounted) {
        setState(() {
          expressRequests = data;
          isLoadingRequests = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading requests: $e');
      if (mounted) {
        setState(() {
          isLoadingRequests = false;
        });
      }
    }
  }

  Future<void> _loadActiveShift() async {
    try {
      final shift = await _shiftRepo.getActiveShiftToday();
      if (mounted) {
        setState(() {
          activeShiftToday = shift;
          isLoadingShift = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active shift: $e');
      if (mounted) {
        setState(() {
          isLoadingShift = false;
        });
      }
    }
  }

  Future<void> _toggleOnlineStatus() async {
    if (isTogglingOnline) return;

    setState(() {
      isTogglingOnline = true;
    });

    try {
      final newStatus = !isOnline;
      await _providerRepo.setOnlineStatus(newStatus);
      if (mounted) {
        setState(() {
          isOnline = newStatus;
        });
      }
    } catch (e) {
      debugPrint('Error toggling online status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar estado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isTogglingOnline = false;
        });
      }
    }
  }

  Future<void> _acceptRequest(ExpressRequest request) async {
    try {
      await _requestRepo.acceptRequest(request.id.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud aceptada'),
            backgroundColor: Colors.green,
          ),
        );
        _loadExpressRequests();
      }
    } catch (e) {
      debugPrint('Error accepting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aceptar solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return TropicalScaffold(
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: CustomScrollView(
          slivers: [
            // Header / Status
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isOnline ? Colors.greenAccent : Colors.redAccent).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? 'En Línea' : 'Desconectado',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              actions: [
                if (isTogglingOnline)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Switch(
                    value: isOnline,
                    onChanged: (val) => _toggleOnlineStatus(),
                    activeColor: Colors.greenAccent,
                    activeTrackColor: Colors.green.withOpacity(0.4),
                    inactiveThumbColor: Colors.redAccent,
                    inactiveTrackColor: Colors.red.withOpacity(0.4),
                  ),
                const SizedBox(width: 16),
              ],
            ),

            // Subscription Status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: SubscriptionStatusCard(
                  subscription: subscription,
                  isLoading: isLoadingSubscription,
                  onManageSubscription: () {
                    context.push('/provider/subscriptions');
                  },
                ),
              ),
            ),

            // Active Shift Today
            if (!isLoadingShift && activeShiftToday != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary600, AppTheme.primary500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary500.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.store, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Turno activo hoy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activeShiftToday!.storeName ?? 'Tienda #${activeShiftToday!.storeId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estado: ${activeShiftToday!.isInProgress ? "En progreso" : "Asignado"}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to POS when implemented
                              context.push('/provider/bolsa-trabajo');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary600,
                            ),
                            child: const Text('IR AL PUNTO DE VENTA'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Stats Cards Section Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => expandedSection = 'requests'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: expandedSection == 'requests'
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: expandedSection == 'requests'
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                        child: const Text('Solicitudes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => expandedSection = 'stats'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: expandedSection == 'stats'
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: expandedSection == 'stats'
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                        child: const Text('Estadísticas'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Cards (when stats section is expanded)
            if (expandedSection == 'stats')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Ganancias del mes',
                              value: isLoadingEarnings
                                  ? '...'
                                  : currencyFormat.format(earnings?.summary.netAmount ?? 0),
                              icon: Icons.attach_money,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Servicios',
                              value: isLoadingStats
                                  ? '...'
                                  : '${stats?.completedRequests ?? 0}',
                              icon: Icons.check_circle,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Pendientes',
                              value: isLoadingStats
                                  ? '...'
                                  : '${stats?.pendingRequests ?? 0}',
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              label: 'Promedio/servicio',
                              value: isLoadingEarnings
                                  ? '...'
                                  : currencyFormat.format(earnings?.summary.avgPerRequest ?? 0),
                              icon: Icons.trending_up,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Requests Section Title
            if (expandedSection == 'requests')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solicitudes Disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isLoadingRequests)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),

            // Requests List or Empty State
            if (expandedSection == 'requests')
              if (!isOnline)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.cloud_off, size: 60, color: Colors.white24),
                          SizedBox(height: 16),
                          Text(
                            'Conéctate para recibir solicitudes',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (isLoadingRequests)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (expressRequests.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 60, color: Colors.white24),
                          SizedBox(height: 16),
                          Text(
                            'No hay solicitudes disponibles',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final request = expressRequests[index];
                      return RequestCard(
                        request: request,
                        onAccept: () => _acceptRequest(request),
                        onReject: () {
                          // TODO: Implement reject
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rechazar solicitud')),
                          );
                        },
                        onTap: () {
                          // TODO: Navigate to request detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ver detalle de ${request.id}')),
                          );
                        },
                      );
                    },
                    childCount: expressRequests.length,
                  ),
                ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
