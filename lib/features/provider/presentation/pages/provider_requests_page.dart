import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/request_repository.dart';
import '../../domain/entities/express_request.dart';
import '../widgets/request_card.dart';

class ProviderRequestsPage extends StatefulWidget {
  const ProviderRequestsPage({super.key});

  @override
  State<ProviderRequestsPage> createState() => _ProviderRequestsPageState();
}

class _ProviderRequestsPageState extends State<ProviderRequestsPage>
    with SingleTickerProviderStateMixin {
  final _requestRepo = RequestRepository();
  late TabController _tabController;

  List<ExpressRequest> availableRequests = [];
  List<dynamic> myRequests = [];
  bool isLoadingAvailable = true;
  bool isLoadingMy = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableRequests(),
      _loadMyRequests(),
    ]);
  }

  Future<void> _loadAvailableRequests() async {
    try {
      final requests = await _requestRepo.getExpressRequests();
      if (mounted) {
        setState(() {
          availableRequests = requests.where((r) => r.isPending).toList();
          isLoadingAvailable = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading available requests: $e');
      if (mounted) {
        setState(() {
          isLoadingAvailable = false;
        });
      }
    }
  }

  Future<void> _loadMyRequests() async {
    try {
      final requests = await _requestRepo.getMyRequests(
        role: 'provider',
        status: 'active',
      );
      if (mounted) {
        setState(() {
          myRequests = requests;
          isLoadingMy = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading my requests: $e');
      if (mounted) {
        setState(() {
          isLoadingMy = false;
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
        _loadData();
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
    return TropicalScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade600,
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Solicitudes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Administra tus servicios',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(text: 'Disponibles'),
                  Tab(text: 'Mis Solicitudes'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab: Available Requests
            RefreshIndicator(
              onRefresh: _loadAvailableRequests,
              child: _buildAvailableRequestsList(),
            ),
            // Tab: My Requests
            RefreshIndicator(
              onRefresh: _loadMyRequests,
              child: _buildMyRequestsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRequestsList() {
    if (isLoadingAvailable) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (availableRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay solicitudes disponibles',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Nuevas solicitudes aparecerán aquí cuando estés en línea',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: availableRequests.length,
      itemBuilder: (context, index) {
        final request = availableRequests[index];
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
              SnackBar(content: Text('Ver detalle ${request.id}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMyRequestsList() {
    if (isLoadingMy) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (myRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes solicitudes activas',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Acepta solicitudes para empezar a trabajar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: myRequests.length,
      itemBuilder: (context, index) {
        final request = myRequests[index];
        return _buildMyRequestCard(request);
      },
    );
  }

  Widget _buildMyRequestCard(dynamic request) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request['status']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(request['status']),
                  style: TextStyle(
                    color: _getStatusColor(request['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                currencyFormat.format(request['final_price'] ?? request['proposed_price'] ?? 0),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request['service_name'] ?? 'Servicio',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request['origin_address'] ?? request['pickup_location'] ?? 'Origen',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request['destination_address'] ?? request['delivery_location'] ?? 'Destino',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to tracking or detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ver seguimiento #${request['id']}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('VER SEGUIMIENTO'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'assigned':
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'assigned':
        return 'Asignado';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status ?? 'Pendiente';
    }
  }
}
