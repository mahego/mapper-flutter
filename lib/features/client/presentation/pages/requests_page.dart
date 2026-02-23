import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_icons.dart';
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
  DateTime? _dateFrom;
  DateTime? _dateTo;

  static const _typeFilters = [
    ('all', 'Todos', AppIcons.listAlt),
    ('service', 'Servicios', AppIcons.localShipping),
    ('store', 'Tiendas', AppIcons.store),
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
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      if (mounted) {
        setState(() {
          _items = list;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading requests: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = 'Error al cargar solicitudes: $e';
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

  Future<void> _pickDateFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        _dateFrom = d;
        if (_dateTo != null && _dateTo!.isBefore(d)) _dateTo = null;
      });
      _loadRequests();
    }
  }

  Future<void> _pickDateTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? _dateFrom ?? DateTime.now(),
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() => _dateTo = d);
      _loadRequests();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/requests/new'),
        backgroundColor: const Color(0xFFf97316),
        icon: const Icon(AppIcons.add),
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
                        Flexible(
                          child: Text(
                            f.$2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
          const SizedBox(height: 12),
          Text('Rango de fechas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 6),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickDateFrom,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_dateFrom != null ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}' : 'Desde', style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pickDateTo,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_dateTo != null ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}' : 'Hasta', style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              if (_dateFrom != null || _dateTo != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearDateFilter,
                  icon: const Icon(Icons.clear, size: 20, color: Colors.white70),
                  tooltip: 'Quitar filtro de fechas',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.errorOutline, size: 64, color: Colors.red.withOpacity(0.7)),
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
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    final statusLabel = _statusFilters.firstWhere((f) => f.$1 == _filterStatus, orElse: () => ('all', 'Todas')).$2;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.inbox, size: 80, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay solicitudes con estado "$statusLabel"',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/requests/new'),
                    icon: const Icon(AppIcons.add),
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
          ),
        );
      },
    );
  }
}
