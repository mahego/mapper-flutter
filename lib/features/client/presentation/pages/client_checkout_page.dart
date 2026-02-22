import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../domain/repositories/client_order_repository.dart';
import '../../domain/entities/client_order.dart';

class ClientCheckoutPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final Map<String, Map<String, dynamic>> cart; // {productId: {name, price, quantity}}

  const ClientCheckoutPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.cart,
  });

  @override
  State<ClientCheckoutPage> createState() => _ClientCheckoutPageState();
}

class _ClientCheckoutPageState extends State<ClientCheckoutPage> {
  final _orderRepository = ClientOrderRepository();
  final _cartService = CartService();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  double _deliveryLat = 0.0;
  double _deliveryLng = 0.0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return widget.cart.values.fold<double>(0, (sum, item) {
      return sum + ((item['price'] as double) * (item['quantity'] as int));
    });
  }

  double get _deliveryFee => 30.0; // Fixed delivery fee, can be dynamic later

  double get _total => _subtotal + _deliveryFee;

  List<Map<String, dynamic>> get _orderItems {
    return widget.cart.entries.map((entry) {
      final productId = entry.key;
      final item = entry.value;
      return {
        'productId': productId,
        'productName': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
        'subtotal': (item['price'] as double) * (item['quantity'] as int),
      };
    }).toList();
  }

  bool get _isFormValid {
    return _addressController.text.trim().isNotEmpty;
  }

  Future<void> _submitOrder() async {
    if (!_isFormValid) {
      setState(() {
        _errorMessage = 'Por favor completa la dirección de entrega';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // TODO: Integrate with real address picker to get lat/lng
      // For now, using placeholder coordinates
      final order = await _orderRepository.createOrder(
        storeId: widget.storeId,
        items: widget.cart.entries.map((entry) => {
          'productId': entry.key,
          'quantity': entry.value['quantity'],
        }).toList(),
        deliveryAddress: _addressController.text,
        deliveryLat: _deliveryLat,
        deliveryLng: _deliveryLng,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        // Clear cart from storage
        await _cartService.clearCart();
        
        // Navigate to confirmation page using NavigationService
        navigationService.goToOrderConfirmation(
          context,
          orderId: order.id.toString(),
          storeName: widget.storeName,
          total: order.total,
          deliveryFee: order.deliveryFee ?? _deliveryFee,
          status: order.status,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al crear el pedido. Intenta nuevamente.';
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error message
                          if (_errorMessage != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          
                          // Order Summary
                          _buildOrderSummary(),
                          const SizedBox(height: 16),
                          
                          // Delivery Information
                          _buildDeliveryForm(),
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Loading overlay
            if (_isSubmitting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF06b6d4)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.zero,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Finalizar Pedido',
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

  Widget _buildOrderSummary() {
    return GlassSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Pedido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tienda: ${widget.storeName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Items list
          ...widget.cart.entries.map((entry) {
            final item = entry.value;
            final name = item['name'] as String;
            final price = item['price'] as double;
            final quantity = item['quantity'] as int;
            final subtotal = price * quantity;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$quantity u. × \$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // Totals
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                '\$${_subtotal.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Envío:',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                '\$${_deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF06b6d4),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return GlassSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de Entrega',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Address field
          TextField(
            controller: _addressController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Dirección de entrega *',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Ingresa tu dirección completa',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF06b6d4), width: 2),
              ),
              prefixIcon: Icon(Icons.location_on, color: Colors.white.withOpacity(0.7)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Notes field
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Notas adicionales (opcional)',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Instrucciones de entrega, referencias, etc.',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF06b6d4), width: 2),
              ),
              prefixIcon: Icon(Icons.note, color: Colors.white.withOpacity(0.7)),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting || !_isFormValid ? null : _submitOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06b6d4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        disabledBackgroundColor: Colors.white.withOpacity(0.2),
      ),
      child: Text(
        _isSubmitting ? 'Procesando pedido...' : 'Confirmar Pedido',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
