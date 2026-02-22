import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';

/// Detalle de pedido de tienda (ruta /cliente/store-order/:id) – paridad Angular.
class StoreOrderDetailPage extends StatelessWidget {
  final String orderId;

  const StoreOrderDetailPage({super.key, required this.orderId});

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
                title: const Text('Pedido de tienda', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.white.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Pedido #$orderId',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Detalle de pedido de tienda. Próximamente más opciones.',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          textAlign: TextAlign.center,
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
}
