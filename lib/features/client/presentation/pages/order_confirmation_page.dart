import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/static_map_image.dart';

class OrderConfirmationPage extends StatelessWidget {
  static const _accent = Color(0xFF06b6d4);
  static const _surfaceLight = Color(0xFF1e293b);
  final String orderId;
  final String storeName;
  final double total;
  final double deliveryFee;
  final String status;
  final double? deliveryLat;
  final double? deliveryLng;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.total,
    required this.deliveryFee,
    required this.status,
    this.deliveryLat,
    this.deliveryLng,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
    final maxWidth = MediaQuery.sizeOf(context).width - (horizontalPadding * 2);
    final mapHeight = (maxWidth * 0.5).clamp(160.0, 220.0);

    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildSuccessHeader(),
                      const SizedBox(height: 28),
                      _buildMapCard(context, maxWidth, mapHeight),
                      const SizedBox(height: 20),
                      _buildOrderDetailsCard(),
                      const SizedBox(height: 28),
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

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10b981).withOpacity(0.25),
                const Color(0xFF059669).withOpacity(0.25),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF10b981).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            size: 52,
            color: Color(0xFF10b981),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Pedido creado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Te notificaremos cuando esté en camino',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(BuildContext context, double width, double height) {
    final hasLocation = deliveryLat != null && deliveryLng != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: _accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ubicación de entrega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasLocation)
            StaticMapImage(
              lat: deliveryLat!,
              lng: deliveryLng!,
              width: width,
              height: height,
              borderRadius: BorderRadius.circular(10),
            )
          else
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_outlined, color: Colors.white38, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'No se especificó ubicación',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
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
              Icon(Icons.receipt_long_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Detalles del pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Número de orden', '#$orderId'),
          const SizedBox(height: 10),
          _buildDetailRow('Tienda', storeName),
          const SizedBox(height: 10),
          _buildDetailRow('Total', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildDetailRow('Envío', '\$${deliveryFee.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildDetailRow('Estado', _getStatusText(status), statusColor: _getStatusColor(status)),
          const SizedBox(height: 14),
          Divider(height: 24, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 10),
          Text(
            'Tu pedido fue enviado a la tienda. Puedes seguir el estado en "Mis pedidos".',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06b6d4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Ver mis pedidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/dashboard/cliente'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Volver al inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/dashboard/cliente'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Confirmación',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: statusColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'En Preparación';
      case 'ready':
        return 'Listo';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFf59e0b); // amber
      case 'confirmed':
      case 'preparing':
        return const Color(0xFF3b82f6); // blue
      case 'ready':
        return const Color(0xFF10b981); // green
      case 'delivered':
        return const Color(0xFF10b981); // green
      case 'cancelled':
        return const Color(0xFFef4444); // red
      default:
        return Colors.white;
    }
  }
}
