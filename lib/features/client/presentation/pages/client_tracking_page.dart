import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/request_repository.dart';

/// Lista de solicitudes activas para elegir cuál rastrear – paridad Angular.
/// Al tocar una solicitud se navega a /requests/:id/tracking.
class ClientTrackingPage extends StatefulWidget {
  const ClientTrackingPage({super.key});

  @override
  State<ClientTrackingPage> createState() => _ClientTrackingPageState();
}

class _ClientTrackingPageState extends State<ClientTrackingPage> {
  final _requestRepository = RequestRepository(ApiClient());

  List<ServiceRequest> _activeRequests = [];
  bool _loading = true;
  String? _error;

  static const _statusLabels = {
    'accepted': 'Aceptada',
    'in_progress': 'En progreso',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final inProgress = await _requestRepository.getMyRequests(status: 'in_progress', limit: 50);
      final accepted = await _requestRepository.getMyRequests(status: 'accepted', limit: 50);
      final ids = <String>{};
      final list = <ServiceRequest>[];
      for (final r in [...accepted, ...inProgress]) {
        if (ids.add(r.id)) list.add(r);
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) {
        setState(() {
          _activeRequests = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las solicitudes activas.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
          : _error != null
              ? _buildError()
              : _activeRequests.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFF06b6d4),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: _activeRequests.length,
                        itemBuilder: (context, index) {
                          final r = _activeRequests[index];
                          final statusLabel = _statusLabels[r.status] ?? r.status;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/requests/${r.id}/tracking'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF06b6d4).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(AppIcons.locationOn, color: Color(0xFF06b6d4), size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.serviceType,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r.destinationAddress,
                                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(statusLabel, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.errorOutline, size: 64, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.map, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No tienes solicitudes activas para rastrear',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando un prestador acepte tu solicitud, aparecerá aquí.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}),
              icon: const Icon(Icons.assignment),
              label: const Text('Ver mis solicitudes'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
            ),
          ],
        ),
      ),
    );
  }
}
