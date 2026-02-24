import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../domain/repositories/request_repository.dart';
import '../widgets/unified_request_card.dart';

/// Lista unificada de solicitudes (servicio + tienda) con filtros – diseño homologado con la web.
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
  bool _filtersExpanded = false;

  static const _typeFilters = [
    ('all', 'Todos', Icons.list_alt_rounded),
    ('service', 'Servicios', Icons.local_shipping_outlined),
    ('store', 'Tiendas', Icons.store_outlined),
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar solicitudes. Revisa tu conexión.';
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

  String get _filterSummary {
    final typeLabel = _typeFilters.firstWhere((f) => f.$1 == _filterType, orElse: () => _typeFilters.first).$2;
    final statusLabel = _statusFilters.firstWhere((f) => f.$1 == _filterStatus, orElse: () => _statusFilters.first).$2;
    String dateLabel = 'Fechas';
    if (_dateFrom != null && _dateTo != null) {
      dateLabel = '${_dateFrom!.day}/${_dateFrom!.month}–${_dateTo!.day}/${_dateTo!.month}';
    } else if (_dateFrom != null) {
      dateLabel = 'Desde ${_dateFrom!.day}/${_dateFrom!.month}';
    } else if (_dateTo != null) {
      dateLabel = 'Hasta ${_dateTo!.day}/${_dateTo!.month}';
    }
    return '$typeLabel · $statusLabel · $dateLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 20),
                      if (_isLoading) _buildLoading(),
                      if (!_isLoading && _error.isNotEmpty) _buildError(),
                      if (!_isLoading && _error.isEmpty && _items.isEmpty) _buildEmpty(),
                      if (!_isLoading && _error.isEmpty && _items.isNotEmpty) _buildList(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Mis Solicitudes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Filtra, revisa y sigue el estado de tus pedidos',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/requests/new'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf97316), Color(0xFF06b6d4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Nueva Solicitud',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _filterSummary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 24,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_filtersExpanded) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filterSectionLabel('Tipo'),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _typeFilters.map((f) {
                        final selected = _filterType == f.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(f.$3, size: 14, color: selected ? Colors.black87 : Colors.white70),
                                const SizedBox(width: 4),
                                Text(f.$2, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            selected: selected,
                            onSelected: (bool? value) {
                              if (value == true) _setType(f.$1);
                            },
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            side: BorderSide(
                              color: selected ? Colors.white : Colors.white.withOpacity(0.2),
                            ),
                            labelStyle: TextStyle(color: selected ? Colors.black87 : Colors.white),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _filterSectionLabel('Estado'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _statusFilters.map((f) {
                      final selected = _filterStatus == f.$1;
                      return ChoiceChip(
                        label: Text(f.$2, style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        onSelected: (bool? value) {
                          if (value == true) _setStatus(f.$1);
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        side: BorderSide(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
                        ),
                        labelStyle: TextStyle(
                          color: selected ? Colors.black87 : Colors.white.withOpacity(0.9),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  _filterSectionLabel('Fechas'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _dateChip('Desde', _dateFrom, _pickDateFrom),
                      const SizedBox(width: 6),
                      _dateChip('Hasta', _dateTo, _pickDateTo),
                      if (_dateFrom != null || _dateTo != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: _clearDateFilter,
                          icon: Icon(Icons.clear, size: 18, color: Colors.white.withOpacity(0.7)),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(32, 32),
                          ),
                          tooltip: 'Quitar fechas',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _dateChip(String label, DateTime? value, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                value != null ? '${value.day}/${value.month}' : label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(value != null ? 0.95 : 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        _skeletonCard(),
        const SizedBox(height: 16),
        _skeletonCard(),
      ],
    );
  }

  Widget _skeletonCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(height: 28, width: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 8),
              Container(height: 28, width: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8))),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 14, width: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Container(height: 14, width: 260, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error,
            style: TextStyle(color: Colors.red.shade200, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _loadRequests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06b6d4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Reintentar'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.go('/dashboard/cliente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final statusLabel = _statusFilters.firstWhere(
      (f) => f.$1 == _filterStatus,
      orElse: () => ('all', 'Todas'),
    ).$2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            'No hay solicitudes con estado "$statusLabel"',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/requests/new'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf97316), Color(0xFF06b6d4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Crear una nueva solicitud',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: const Color(0xFF06b6d4),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
    );
  }
}
