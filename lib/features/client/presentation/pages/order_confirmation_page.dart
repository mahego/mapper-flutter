import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/glass_surface.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final String storeName;
  final double total;
  final double deliveryFee;
  final String status;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.total,
    required this.deliveryFee,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10b981).withOpacity(0.3),
                                const Color(0xFF059669).withOpacity(0.3),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF10b981).withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 60,
                            color: Color(0xFF10b981),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Success message
                        const Text(
                          '¡Pedido Creado Exitosamente!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Order details card
                        GlassSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detalles del Pedido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildDetailRow('Número de Orden:', '#$orderId'),
                              const SizedBox(height: 12),
                              _buildDetailRow('Tienda:', storeName),
                              const SizedBox(height: 12),
                              _buildDetailRow('Total:', '\$${total.toStringAsFixed(2)}'),
                              const SizedBox(height: 12),
                              _buildDetailRow('Envío:', '\$${deliveryFee.toStringAsFixed(2)}'),
                              const SizedBox(height: 12),
                              _buildDetailRow('Estado:', _getStatusText(status), statusColor: _getStatusColor(status)),
                              
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 12),
                              
                              Text(
                                'Tu pedido ha sido enviado a la tienda para su preparación. Podrás seguir el estado en tiempo real desde la sección "Mis Pedidos".',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Action buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to orders/requests page
                                context.go('/client/requests');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06b6d4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ver Mis Pedidos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                // Navigate to client dashboard
                                context.go('/client/dashboard');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Volver al Inicio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.zero,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.go('/client/dashboard'),
          ),
          const SizedBox(width: 8),
          const Text(
            'Confirmación',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
