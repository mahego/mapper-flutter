import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/request_repository.dart';

/// Detalle de una solicitud (paridad con Angular RequestDetailComponent).
/// Muestra estado, origen/destino, contraofertas, aceptar/rechazar, cancelar.
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
  String? _error;

  static const _statusLabels = {
    'pending': 'Pendiente',
    'rejected': 'Rechazada',
    'accepted': 'Aceptada',
    'in_progress': 'En Progreso',
    'completed': 'Completada',
    'cancelled': 'Cancelada',
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar la solicitud';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOffers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.requestOffers(widget.requestId));
      final data = response.data;
      final list = data is Map ? (data['data']?['offers'] ?? data['data'] ?? data) : data;
      if (list is List && mounted) {
        setState(() {
          _offers = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _offers = []);
    }
  }

  Future<void> _acceptCounterOffer(String offerId) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.acceptCounterOffer(widget.requestId),
        data: {'counterofferId': offerId},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraoferta aceptada exitosamente')),
        );
        _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar: $e')),
        );
      }
    }
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text('¿Estás seguro de que deseas cancelar esta solicitud?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _apiClient.post(
        ApiEndpoints.cancelRequest(widget.requestId),
        data: {'reason': 'Cancelada por el usuario'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud cancelada')));
        _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/requests'),
                ),
                title: const Text('Detalle de solicitud', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _loadDetail,
                                    child: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _request == null
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStatusChip(_request!.status),
                                    const SizedBox(height: 16),
                                    LiquidGlassCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _row('Origen', _request!.originAddress),
                                          const SizedBox(height: 12),
                                          _row('Destino', _request!.destinationAddress),
                                          if (_request!.estimatedCost != null) ...[
                                            const SizedBox(height: 12),
                                            _row('Costo estimado', '\$${_request!.estimatedCost!.toStringAsFixed(2)}'),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (_offers.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        'Contraofertas',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ..._offers.map((o) {
                                        final id = o['id']?.toString() ?? '';
                                        final price = (o['proposedPrice'] ?? o['offeredPrice'] ?? 0).toDouble();
                                        final status = o['status'] ?? 'pending';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: LiquidGlassCard(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '\$${price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                if (status == 'pending')
                                                  TextButton(
                                                    onPressed: () => _acceptCounterOffer(id),
                                                    child: const Text('Aceptar'),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    const SizedBox(height: 24),
                                    if (_request!.status.toLowerCase() == 'pending' ||
                                        _request!.status.toLowerCase() == 'accepted')
                                      GradientButton(
                                        onPressed: () => context.push('/requests/${widget.requestId}/tracking'),
                                        text: 'Ver tracking',
                                      ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: _cancelRequest,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: const Text('Cancelar solicitud'),
                                    ),
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

  Widget _buildStatusChip(String status) {
    final label = _statusLabels[status.toLowerCase()] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
