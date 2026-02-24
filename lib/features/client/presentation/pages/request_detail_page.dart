import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_modal.dart';
import '../../../../core/widgets/liquid_glass_snackbar.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/request_repository.dart';

/// Detalle de una solicitud – diseño homologado con la web (request-detail).
class RequestDetailPage extends StatefulWidget {
  final String requestId;

  const RequestDetailPage({super.key, required this.requestId});

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final _requestRepository = RequestRepository(ApiClient());
  final _apiClient = ApiClient();

  ServiceRequest? _request;
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;
  bool _offersLoading = false;
  String? _error;

  static const _accent = Color(0xFF06b6d4);
  static const _surfaceLight = Color(0xFF1e293b);

  static final _statusColors = <String, Color>{
    'pending': const Color(0xFFeab308),
    'rejected': const Color(0xFFef4444),
    'accepted': const Color(0xFF22c55e),
    'in_progress': const Color(0xFF3b82f6),
    'completed': const Color(0xFF10b981),
    'cancelled': const Color(0xFF6b7280),
  };

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final request = await _requestRepository.getRequestById(widget.requestId);
      if (mounted) {
        setState(() {
          _request = request;
          _isLoading = false;
        });
        _loadOffers();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar la solicitud';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOffers() async {
    setState(() => _offersLoading = true);
    try {
      final response = await _apiClient.get(ApiEndpoints.requestOffers(widget.requestId));
      final data = response.data;
      final list = data is Map ? (data['data']?['offers'] ?? data['data'] ?? data) : data;
      if (list is List && mounted) {
        setState(() {
          _offers = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _offersLoading = false;
        });
      } else if (mounted) {
        setState(() => _offersLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() {
        _offers = [];
        _offersLoading = false;
      });
    }
  }

  Future<void> _acceptCounterOffer(String offerId) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.acceptCounterOffer(widget.requestId),
        data: {'counterofferId': offerId},
      );
      if (mounted) {
        LiquidGlassSnackBar.showSuccess(context, 'Contraoferta aceptada');
        _loadDetail();
      }
    } catch (e) {
      if (mounted) LiquidGlassSnackBar.showError(context, 'Error al aceptar');
    }
  }

  Future<void> _cancelRequest() async {
    final confirm = await LiquidGlassModalShow.confirm(
      context,
      title: 'Cancelar solicitud',
      message: '¿Estás seguro de que deseas cancelar esta solicitud?',
      confirmLabel: 'Sí, cancelar',
      cancelLabel: 'No',
    );
    if (confirm != true) return;
    try {
      await _apiClient.post(
        ApiEndpoints.cancelRequest(widget.requestId),
        data: {'reason': 'Cancelada por el usuario'},
      );
      if (mounted) {
        LiquidGlassSnackBar.showSuccess(context, 'Solicitud cancelada');
        _loadDetail();
      }
    } catch (_) {
      if (mounted) LiquidGlassSnackBar.showError(context, 'No se pudo cancelar');
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '—';
    DateTime? d = value is DateTime ? value : DateTime.tryParse(value.toString());
    if (d == null && value is! DateTime) return value.toString();
    if (d == null) return '—';
    try {
      return DateFormat('d MMM yyyy, HH:mm', 'es').format(d);
    } catch (_) {
      return DateFormat('d MMM yyyy, HH:mm').format(d);
    }
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
                child: _isLoading
                    ? _buildLoading()
                    : _error != null
                        ? _buildError()
                        : _request == null
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStatusCard(),
                                    const SizedBox(height: 16),
                                    _buildLocationCard(),
                                    const SizedBox(height: 16),
                                    _buildCostDurationCard(),
                                    if (_request!.providerName != null) ...[
                                      const SizedBox(height: 16),
                                      _buildProviderCard(),
                                    ],
                                    if (_request!.notes != null && _request!.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      _buildNotesCard(),
                                    ],
                                    if (_request!.status.toLowerCase() == 'cancelled' && _request!.cancelReason != null) ...[
                                      const SizedBox(height: 16),
                                      _buildCancelReasonCard(),
                                    ],
                                    if (_request!.status.toLowerCase() == 'completed') ...[
                                      const SizedBox(height: 16),
                                      _buildCompletionCard(),
                                    ],
                                    const SizedBox(height: 16),
                                    _buildOffersCard(),
                                    const SizedBox(height: 24),
                                    _buildActions(context),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(minimumSize: const Size(44, 44), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SOLICITUDES',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  'Detalles de la solicitud',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (_request != null)
                  Text(
                    'ID: #${_request!.id}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(color: Color(0xFF06b6d4), strokeWidth: 2),
          ),
          SizedBox(height: 16),
          Text('Cargando detalles...', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadDetail,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: _accent),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _request!.status.toLowerCase();
    final color = _statusColors[status] ?? Colors.grey;
    return _card(
      title: 'Estado de la solicitud',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              _request!.statusLabel,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('Creado', _formatDate(_request!.createdAt)),
          if (_request!.pickupTime != null) _infoRow('Iniciado', _formatDate(_request!.pickupTime)),
          if (_request!.deliveryTime != null) _infoRow('Completado', _formatDate(_request!.deliveryTime)),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return _card(
      title: 'Ubicaciones',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue('Origen', _request!.originAddress),
          if (_request!.originLat != null && _request!.originLng != null)
            Text(
              'Lat: ${_request!.originLat!.toStringAsFixed(4)}, Lng: ${_request!.originLng!.toStringAsFixed(4)}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
            ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),
          _labelValue('Destino', _request!.destinationAddress),
          if (_request!.destinationLat != null && _request!.destinationLng != null)
            Text(
              'Lat: ${_request!.destinationLat!.toStringAsFixed(4)}, Lng: ${_request!.destinationLng!.toStringAsFixed(4)}',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildCostDurationCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _card(
            title: 'Costo estimado',
            icon: Icons.payments_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${(_request!.estimatedCost ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_request!.finalCost != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Costo final: \$${_request!.finalCost!.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _card(
            title: 'Duración',
            icon: Icons.schedule_rounded,
            child: Text(
              _request!.estimatedDurationMinutes != null
                  ? '${_request!.estimatedDurationMinutes} min'
                  : '—',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    return _card(
      title: 'Proveedor',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _request!.providerName!,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (_request!.providerRating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFeab308)),
                const SizedBox(width: 4),
                Text(
                  '${_request!.providerRating!.toStringAsFixed(1)}/5',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ],
          if (_request!.providerPhone != null) ...[
            const SizedBox(height: 4),
            Text('📞 ${_request!.providerPhone}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _card(
      title: 'Notas',
      icon: Icons.notes_rounded,
      child: Text(
        _request!.notes!,
        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.4),
      ),
    );
  }

  Widget _buildCancelReasonCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Razón de cancelación',
            style: TextStyle(color: Color(0xFFfca5a5), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _request!.cancelReason!,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF10b981).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF6ee7b7), size: 22),
              SizedBox(width: 8),
              Text(
                'Servicio completado',
                style: TextStyle(color: Color(0xFF6ee7b7), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_request!.finalCost != null)
            Text(
              'Precio final: \$${_request!.finalCost!.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          if (_request!.deliveryTime != null) ...[
            const SizedBox(height: 6),
            Text('Completado: ${_formatDate(_request!.deliveryTime)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ],
          if (_request!.completionNotes != null && _request!.completionNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_request!.completionNotes!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildOffersCard() {
    return _card(
      title: 'Ofertas de proveedores',
      icon: Icons.local_offer_outlined,
      child: _offersLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Color(0xFF06b6d4), strokeWidth: 2))),
            )
          : _offers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No hay ofertas disponibles aún', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))),
                )
              : Column(
                  children: _offers.map((o) {
                    final id = o['id']?.toString() ?? '';
                    final price = (o['proposedPrice'] ?? o['offeredPrice'] ?? 0).toDouble();
                    final status = o['status']?.toString() ?? 'pending';
                    final providerName = o['providerName']?.toString() ?? 'Proveedor';
                    final message = o['message']?.toString();
                    final created = o['createdAt'] ?? o['created_at'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(providerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    if (o['providerId'] != null)
                                      Text('ID: #${o['providerId']}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF34d399), fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  if (_request!.estimatedCost != null && _request!.estimatedCost! > 0)
                                    Text(
                                      price < _request!.estimatedCost!
                                          ? '↓ ${(_request!.estimatedCost! - price).toStringAsFixed(2)}'
                                          : '↑ ${(price - _request!.estimatedCost!).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: price < _request!.estimatedCost! ? const Color(0xFF34d399) : Colors.orange,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (message != null && message.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(left: BorderSide(color: _accent, width: 2)),
                              ),
                              child: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontStyle: FontStyle.italic)),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (created != null) Text(_formatDate(created), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                              if (status == 'pending') ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _acceptCounterOffer(id),
                                      child: const Text('Aceptar', style: TextStyle(color: Color(0xFF34d399), fontWeight: FontWeight.w600)),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Rechazar', style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ] else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'accepted' ? const Color(0xFF34d399).withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status == 'accepted' ? 'Aceptada' : 'Rechazada',
                                    style: TextStyle(
                                      color: status == 'accepted' ? const Color(0xFF6ee7b7) : Colors.red.shade200,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final status = _request!.status.toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == 'in_progress' || status == 'accepted')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => context.push('/requests/${widget.requestId}/tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6).withOpacity(0.3),
                foregroundColor: const Color(0xFF93c5fd),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: const Color(0xFF3b82f6).withOpacity(0.5))),
              ),
              child: const Text('Ver tracking en vivo'),
            ),
          ),
        if (status == 'pending')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Editar solicitud'),
            ),
          ),
        if (status == 'pending' || status == 'in_progress' || status == 'accepted')
          OutlinedButton(
            onPressed: _cancelRequest,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade200,
              side: BorderSide(color: Colors.red.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancelar solicitud'),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
