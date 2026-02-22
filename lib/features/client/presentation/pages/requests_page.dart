import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/client_bottom_nav.dart';
import '../../domain/repositories/request_repository.dart';
import '../widgets/unified_request_card.dart';

/// Lista unificada de solicitudes (servicio + tienda) con filtros – paridad Angular request-list.
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _requestRepository = RequestRepository(ApiClient());

  List<UnifiedRequestItem> _items = [];
  bool _isLoading = true;
  String _error = '';

  String _filterType = 'all';
  String _filterStatus = 'all';

  static const _typeFilters = [
    ('all', 'Todos', Icons.list_alt),
    ('service', 'Servicios', Icons.local_shipping),
    ('store', 'Tiendas', Icons.store),
  ];

  static const _statusFilters = [
    ('all', 'Todas'),
    ('pending', 'Pendientes'),
    ('rejected', 'Rechazadas'),
    ('accepted', 'Aceptadas'),
    ('in_progress', 'En Progreso'),
    ('completed', 'Completadas'),
    ('cancelled', 'Canceladas'),
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final list = await _requestRepository.getUnifiedRequests(
        type: _filterType,
        status: _filterStatus,
      );
      if (mounted) {
        setState(() {
          _items = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar solicitudes. Verifica tu conexión.';
          _isLoading = false;
        });
      }
    }
  }

  void _setType(String type) {
    setState(() => _filterType = type);
    _loadRequests();
  }

  void _setStatus(String status) {
    setState(() => _filterStatus = status);
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text('Total: ${_items.length}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/requests/new'),
        backgroundColor: const Color(0xFFf97316),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Solicitud'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                : _error.isNotEmpty
                    ? _buildError()
                    : _items.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _loadRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return UnifiedRequestCard(
                                  item: item,
                                  onTap: () {
                                    if (item.type == UnifiedRequestType.service) {
                                      context.push('/requests/${item.id}');
                                    } else {
                                      context.push('/cliente/store-order/${item.id}');
                                    }
                                  },
                                  onTrack: item.type == UnifiedRequestType.service
                                      ? () => context.push('/requests/${item.id}/tracking')
                                      : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _typeFilters.map((f) {
                final selected = _filterType == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(f.$3, size: 16, color: selected ? Colors.black87 : Colors.white70),
                        const SizedBox(width: 6),
                        Text(f.$2),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) => _setType(f.$1),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    side: BorderSide(color: selected ? Colors.white : Colors.white.withOpacity(0.2)),
                    labelStyle: TextStyle(color: selected ? Colors.black87 : Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text('Estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _statusFilters.map((f) {
              final selected = _filterStatus == f.$1;
              return ChoiceChip(
                label: Text(f.$2, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (_) => _setStatus(f.$1),
                selectedColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.08),
                side: BorderSide(color: selected ? Colors.white : Colors.white.withOpacity(0.2)),
                labelStyle: TextStyle(color: selected ? Colors.black87 : Colors.white.withOpacity(0.9)),
              );
            }).toList(),
          ),
        ],
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
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              _error,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadRequests,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)),
                  child: const Text('Reintentar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.go('/dashboard/cliente'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final statusLabel = _statusFilters.firstWhere((f) => f.$1 == _filterStatus, orElse: () => ('all', 'Todas')).$2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes con estado "$statusLabel"',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/requests/new'),
              icon: const Icon(Icons.add),
              label: const Text('Crear una nueva solicitud'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf97316),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
