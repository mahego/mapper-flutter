import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/geolocation_service.dart';
import '../../../../core/services/google_places_service.dart';
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
  final _apiClient = ApiClient();
  final _geolocationService = GeolocationService();
  late final GooglePlacesService _googlePlacesService;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  double _deliveryLat = 0.0;
  double _deliveryLng = 0.0;
  bool _isSubmitting = false;
  bool _loadingLocation = false;
  bool _loadingAddressSearch = false;
  String? _errorMessage;
  GeoPlacesResult? _addressSuggestion;

  @override
  void initState() {
    super.initState();
    _googlePlacesService = GooglePlacesService(
      dio: _apiClient.client,
      apiKey: AppConstants.googlePlacesApiKey,
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _errorMessage = null;
      _addressSuggestion = null;
    });
    try {
      final enabled = await _geolocationService.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) setState(() {
          _loadingLocation = false;
          _errorMessage = 'Activa los servicios de ubicación en tu dispositivo.';
        });
        return;
      }
      final hasPermission = await _geolocationService.handlePermissions();
      if (!hasPermission) {
        if (mounted) setState(() {
          _loadingLocation = false;
          _errorMessage = 'Se necesitan permisos de ubicación para usar esta función.';
        });
        return;
      }
      final pos = await _geolocationService.getCurrentPosition();
      if (pos == null) {
        if (mounted) setState(() {
          _loadingLocation = false;
          _errorMessage = 'No se pudo obtener tu ubicación. Revisa GPS y permisos.';
        });
        return;
      }
      final result = await _googlePlacesService.reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _addressController.text = result.address;
          _deliveryLat = result.lat;
          _deliveryLng = result.lng;
          _loadingLocation = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _loadingLocation = false;
        _errorMessage = 'Error al obtener la ubicación. Intenta de nuevo.';
      });
    }
  }

  Future<void> _searchAddress() async {
    final query = _addressController.text.trim();
    if (query.isEmpty) {
      setState(() => _errorMessage = 'Escribe una dirección para buscar.');
      return;
    }
    setState(() {
      _loadingAddressSearch = true;
      _errorMessage = null;
      _addressSuggestion = null;
    });
    try {
      final result = await _googlePlacesService.searchAddress(query);
      if (result.address.startsWith('Lat:')) {
        if (mounted) setState(() {
          _loadingAddressSearch = false;
          _errorMessage = 'No se encontró la dirección. Prueba con más detalle.';
        });
        return;
      }
      if (mounted) {
        setState(() {
          _addressController.text = result.address;
          _deliveryLat = result.lat;
          _deliveryLng = result.lng;
          _addressSuggestion = result;
          _loadingAddressSearch = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _loadingAddressSearch = false;
        _errorMessage = 'Error al buscar la dirección.';
      });
    }
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
          deliveryLat: (_deliveryLat != 0 || _deliveryLng != 0) ? _deliveryLat : null,
          deliveryLng: (_deliveryLat != 0 || _deliveryLng != 0) ? _deliveryLng : null,
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

  static const _accent = Color(0xFF06b6d4);
  static const _surface = Color(0xFF0f172a);
  static const _surfaceLight = Color(0xFF1e293b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: LiquidGlassBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_errorMessage != null) _buildErrorBanner(),
                          const SizedBox(height: 20),
                          _buildOrderSummary(),
                          const SizedBox(height: 20),
                          _buildDeliveryForm(),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isSubmitting) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Finalizar pedido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.storeName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.red.shade300, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade200, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_accent),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Resumen del pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...widget.cart.entries.map((entry) {
            final item = entry.value;
            final name = item['name'] as String;
            final price = item['price'] as double;
            final quantity = item['quantity'] as int;
            final subtotal = price * quantity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$quantity × \$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(height: 24, color: Colors.white.withOpacity(0.08)),
          _buildSummaryRow('Subtotal', _subtotal),
          const SizedBox(height: 6),
          _buildSummaryRow('Envío', _deliveryFee),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 14),
      prefixIconColor: Colors.white.withOpacity(0.5),
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Entrega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _addressController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Dirección de entrega *',
              hintText: 'Calle, número, colonia, CP',
              prefixIcon: const Icon(Icons.place_outlined, size: 20),
            ),
            maxLines: 2,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                icon: Icons.my_location_rounded,
                label: _loadingLocation ? 'Obteniendo...' : 'Ubicación actual',
                loading: _loadingLocation,
                onTap: _useCurrentLocation,
              ),
              _buildActionChip(
                icon: Icons.search_rounded,
                label: _loadingAddressSearch ? 'Buscando...' : 'Buscar dirección',
                loading: _loadingAddressSearch,
                onTap: _searchAddress,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Notas (opcional)',
              hintText: 'Instrucciones, referencias...',
              prefixIcon: const Icon(Icons.note_add_outlined, size: 20),
            ),
            maxLines: 3,
            minLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _accent.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                )
              else
                Icon(icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final enabled = !_isSubmitting && _isFormValid;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? _submitOrder : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled ? _accent : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _accent.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                _isSubmitting ? 'Procesando...' : 'Confirmar pedido',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
