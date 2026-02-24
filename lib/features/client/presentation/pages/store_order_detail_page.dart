import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../store/domain/entities/store_order.dart';

/// Detalle de pedido de tienda (ruta /cliente/store-order/:id) – paridad Angular.
/// Carga GET /store-orders/:id, muestra ítems, total, estado y "Volver a pedir".
class StoreOrderDetailPage extends StatefulWidget {
  final String orderId;

  const StoreOrderDetailPage({super.key, required this.orderId});

  @override
  State<StoreOrderDetailPage> createState() => _StoreOrderDetailPageState();
}

class _StoreOrderDetailPageState extends State<StoreOrderDetailPage> {
  final _apiClient = ApiClient();

  StoreOrder? _order;
  bool _loading = true;
  String? _error;

  static String _formatDateSafe(DateTime d, String pattern) {
    try {
      return DateFormat(pattern, 'es').format(d);
    } catch (_) {
      return DateFormat(pattern).format(d);
    }
  }

  static final _statusLabels = {
    'pending': 'Pendiente',
    'confirmed': 'Confirmado',
    'preparing': 'En preparación',
    'in_delivery': 'En camino',
    'delivered': 'Entregado',
    'completed': 'Completado',
    'cancelled': 'Cancelado',
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
      final id = int.tryParse(widget.orderId) ?? 0;
      if (id == 0) throw Exception('ID de pedido no válido');
      final response = await _apiClient.get('${ApiEndpoints.storeOrders}/$id');
      final data = response.data;
      final raw = data is Map ? (data['data'] ?? data) : data;
      if (raw is! Map) throw Exception('Respuesta no válida');
      if (mounted) {
        setState(() {
          _order = StoreOrder.fromJson(Map<String, dynamic>.from(raw));
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el pedido. Verifica tu conexión.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);

    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(AppIcons.arrowBack, color: Colors.white),
                  onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}),
                ),
                title: const Text('Pedido de tienda', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                    : _error != null
                        ? _buildError()
                        : _order == null
                            ? const Center(child: Text('Pedido no encontrado', style: TextStyle(color: Colors.white70)))
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStatusCard(formatter),
                                    const SizedBox(height: 16),
                                    _buildItemsCard(formatter),
                                    const SizedBox(height: 16),
                                    if (_order!.storeId > 0)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => context.push('/cliente/catalog/${_order!.storeId}'),
                                          icon: const Icon(Icons.replay),
                                          label: const Text('Volver a pedir'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFf97316),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
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

  Widget _buildStatusCard(NumberFormat formatter) {
    final statusLabel = _statusLabels[_order!.status] ?? _order!.status;
    final created = _formatDateSafe(_order!.createdAt, 'd MMM y, HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pedido #${_order!.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06b6d4).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(created, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              Text(formatter.format(_order!.total), style: const TextStyle(color: Color(0xFF06b6d4), fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Productos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          ..._order!.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          Text('${item.quantity} × ${formatter.format(item.price)}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(formatter.format(item.subtotal), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              )),
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
            Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9)), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _load, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)), child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
