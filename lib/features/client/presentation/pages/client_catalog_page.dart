import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/widgets/liquid_glass_snackbar.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/repositories/store_repository.dart';

/// Catálogo de una tienda para el cliente con soporte de carrito.
/// 
/// NOTA: Imágenes de Firebase Storage
/// - Las imágenes usan Image.network con errorBuilder para manejar fallos de carga
/// - Si aparecen errores CORS en Flutter Web, es normal para Firebase Storage
/// - Los errores se manejan automáticamente mostrando un icono de fallback
/// - Para producción, configurar CORS en Firebase Storage:
///   https://firebase.google.com/docs/storage/web/download-files#cors_configuration
class ClientCatalogPage extends StatefulWidget {
  final String storeId;

  const ClientCatalogPage({super.key, required this.storeId});

  @override
  State<ClientCatalogPage> createState() => _ClientCatalogPageState();
}

class _ClientCatalogPageState extends State<ClientCatalogPage> {
  final _apiClient = ApiClient();
  final _storeRepository = StoreRepository();
  late final _notificationService = NotificationService(apiClient: ApiClient());
  late final _cartService = CartService();
  
  Map<String, dynamic>? _store; // name, address, imageUrl
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;
  
  String _searchQuery = '';
  String _selectedCategory = '';
  List<String> _categories = [];
  
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;
  bool _showCartDrawer = false;
  
  // Cart state: {productId: {name, price, quantity}}
  Map<String, Map<String, dynamic>> _cart = {};
  int _cartItemCount = 0;

  /// Productos filtrados por búsqueda, categoría y activos (paridad Angular filteredProducts)
  List<dynamic> get _filteredProducts {
    return _products.where((p) {
      if (p is! Map<String, dynamic>) return false;
      final isActive = p['isActive'] ?? true;
      if (!isActive) return false;
      final name = (p['name'] ?? p['title'] ?? '').toString().toLowerCase();
      final desc = (p['description'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString();
      final matchesSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          desc.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory.isEmpty || cat == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  double get _cartTotal => _cart.values.fold<double>(
        0,
        (sum, item) => sum + ((item['price'] as double) * (item['quantity'] as int)),
      );

  static int _stockFromProduct(dynamic p) {
    if (p is! Map) return 0;
    final s = p['stock'] ?? p['available_quantity'];
    if (s == null) return 0;
    if (s is int) return s;
    return (s is num) ? s.toInt() : 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadNotificationCount();
    _loadCartFromStorage();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadNotificationsCount = count);
      }
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  Future<void> _markNotificationsAsRead() async {
    if (_unreadNotificationsCount > 0) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      try {
        await _notificationService.markAllAsRead();
      } catch (e) {
        print('Error marking notifications as read: $e');
      }
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([
        _loadStore(),
        _loadProducts(),
      ]);
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el catálogo.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadStore() async {
    try {
      final store = await _storeRepository.getStoreById(widget.storeId);
      if (mounted) setState(() => _store = store is Map<String, dynamic> ? store : null);
    } catch (_) {
      if (mounted) setState(() => _store = null);
    }
  }

  Future<void> _loadProducts() async {
    final productsRes = await _apiClient.get(ApiEndpoints.storeProductsList(widget.storeId));
    final data = productsRes.data;
    final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
    final listProducts = list is List ? list : [];
    if (mounted) {
      setState(() {
        _products = listProducts;
        _extractCategories();
      });
    }
  }

  void _extractCategories() {
    final cats = <String>{};
    for (final p in _products) {
      if (p is Map && p['category'] != null) {
        cats.add(p['category'].toString());
      }
    }
    _categories = cats.toList()..sort();
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final cartData = await _cartService.loadCart();
      if (cartData != null && mounted) {
        // Only load if cart is for the same store
        if (cartData['storeId'] == widget.storeId) {
          setState(() {
            final items = cartData['items'] as Map<String, dynamic>?;
            if (items != null) {
              // Convert cart format: {productId: {name, price, quantity}}
              for (var entry in items.entries) {
                _cart[entry.key] = {
                  'name': entry.value['name'],
                  'price': (entry.value['price'] as num).toDouble(),
                  'quantity': entry.value['quantity'] as int,
                };
              }
              _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
              
              // Show recovery message
              LiquidGlassSnackBar.showSuccess(context, 'Carrito retomado: $_cartItemCount artículos', duration: const Duration(seconds: 2));
            }
          });
        }
      } else {
        // No active cart, check for expired recovery cart
        await _checkRecoveryCart();
      }
    } catch (e) {
      print('Error loading cart from storage: $e');
    }
  }

  Future<void> _checkRecoveryCart() async {
    try {
      final recoveryCart = await _cartService.getRecoveryCart();
      if (recoveryCart != null && mounted) {
        // Only if same store
        if (recoveryCart['storeId'] == widget.storeId) {
          final items = recoveryCart['items'] as Map<String, dynamic>? ?? {};
          final itemCount = items.length;
          
          // Show dialog asking if user wants to recover
          _showRecoveryDialog(recoveryCart, itemCount);
        }
      }
    } catch (e) {
      print('Error checking recovery cart: $e');
    }
  }

  void _showRecoveryDialog(Map<String, dynamic> recoveryCart, int itemCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f172a).withOpacity(0.95),
        title: const Text(
          '🛒 Carrito Anterior',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encontramos un carrito anterior con $itemCount productos.',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Deseas recuperarlo?',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _cartService.clearRecoveryCart();
              Navigator.pop(context);
            },
            child: Text(
              'Descartar',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
            ),
            onPressed: () async {
              await _recoverCart(recoveryCart);
              Navigator.pop(context);
            },
            child: const Text('Recuperar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _recoverCart(Map<String, dynamic> recoveryCart) async {
    try {
      setState(() {
        final items = recoveryCart['items'] as Map<String, dynamic>?;
        if (items != null) {
          for (var entry in items.entries) {
            _cart[entry.key] = {
              'name': entry.value['name'],
              'price': (entry.value['price'] as num).toDouble(),
              'quantity': entry.value['quantity'] as int,
            };
          }
          _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
        }
      });

      // Save as new cart
      await _saveCartToStorage();
      
      // Clear recovery
      await _cartService.clearRecoveryCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carrito recuperado exitosamente'),
            backgroundColor: Color(0xFF10b981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error recovering cart: $e');
    }
  }

  Future<void> _saveCartToStorage() async {
    if (_cart.isEmpty) {
      // Si el carrito está vacío, borrarlo del storage
      try {
        await _cartService.clearCart();
      } catch (e) {
        print('Error clearing cart from storage: $e');
      }
      return;
    }

    try {
      final total = _cart.values.fold<double>(0, (sum, item) {
        return sum + ((item['price'] as double) * (item['quantity'] as int));
      });

      await _cartService.saveCart(
        items: _cart,
        storeId: widget.storeId,
        total: total,
      );
      
      print('[ClientCatalogPage] Carrito guardado: ${_cart.length} items');
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          LiquidGlassBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header (paridad Angular: back + store info + cart)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: _store != null && _store!['imageUrl'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _store!['imageUrl'].toString(),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(Icons.store, color: Colors.white.withOpacity(0.7), size: 28),
                                        ),
                                      )
                                    : Icon(Icons.store, color: Colors.white.withOpacity(0.7), size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _store?['name'] ?? 'Catálogo',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_store?['address'] != null)
                                      Text(
                                        _store!['address'].toString(),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => _showCartDrawer = true),
                              icon: Icon(
                                AppIcons.shoppingCart,
                                color: _cartItemCount > 0 ? const Color(0xFF06b6d4) : Colors.white.withOpacity(0.7),
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            if (_cartItemCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  constraints: const BoxConstraints(minWidth: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06b6d4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _cartItemCount.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            setState(() => _showNotifications = !_showNotifications);
                            if (_unreadNotificationsCount > 0) _markNotificationsAsRead();
                          },
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Toolbar: búsqueda + categorías (paridad Angular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Buscar productos...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6), size: 22),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _CategoryChip(
                                label: 'Todos',
                                selected: _selectedCategory.isEmpty,
                                onTap: () => setState(() => _selectedCategory = ''),
                              ),
                              ..._categories.map((c) => _CategoryChip(
                                    label: c,
                                    selected: _selectedCategory == c,
                                    onTap: () => setState(() => _selectedCategory = c),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _loading
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
                                      TextButton(onPressed: _load, child: const Text('Reintentar')),
                                    ],
                                  ),
                                ),
                              )
                            : _filteredProducts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.white.withOpacity(0.5)),
                                        const SizedBox(height: 12),
                                        Text(
                                          _products.isEmpty ? 'Esta tienda no tiene productos publicados.' : 'No hay productos en esta categoría',
                                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: width >= 1200 ? 4 : (width >= 768 ? 3 : 2),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.72,
                                    ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, i) {
                                      final p = _filteredProducts[i] as Map<String, dynamic>;
                                      final productId = p['id']?.toString() ?? i.toString();
                                      final name = p['name'] ?? p['title'] ?? 'Producto';
                                      final price = (p['price'] ?? p['unitPrice'] ?? 0).toDouble();
                                      final description = p['description'] ?? '';
                                      final imageUrl = p['imageUrl'] ?? p['image_url'] ?? p['image'];
                                      final stock = _stockFromProduct(p);
                                      final inCart = _cart[productId]?['quantity'] as int? ?? 0;
                                      final canAddMore = inCart < stock;
                                      
                                      return GestureDetector(
                                        onTap: () => _showProductDetails(p),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: inCart > 0 
                                                ? const Color(0xFFf97316).withOpacity(0.5)
                                                : Colors.white.withOpacity(0.12),
                                              width: inCart > 0 ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Image Section
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                                    child: Container(
                                                      height: 140,
                                                      width: double.infinity,
                                                      color: Colors.white.withOpacity(0.05),
                                                      child: imageUrl != null
                                                        ? Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.cover,
                                                            width: double.infinity,
                                                            height: 140,
                                                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                              if (wasSynchronouslyLoaded) return child;
                                                              return frame == null
                                                                ? Center(
                                                                    child: SizedBox(
                                                                      width: 24,
                                                                      height: 24,
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth: 2,
                                                                        color: Colors.white.withOpacity(0.3),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : child;
                                                            },
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Center(
                                                                child: Icon(
                                                                  AppIcons.shoppingBag,
                                                                  size: 48,
                                                                  color: Colors.white.withOpacity(0.3),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Center(
                                                            child: Icon(
                                                              AppIcons.shoppingBag,
                                                              size: 48,
                                                              color: Colors.white.withOpacity(0.3),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  // Cart badge
                                                  if (inCart > 0)
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFf97316),
                                                          borderRadius: BorderRadius.circular(12),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: const Color(0xFFf97316).withOpacity(0.5),
                                                              blurRadius: 8,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              AppIcons.shoppingCart,
                                                              color: Colors.white,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '$inCart',
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  // Stock badge (paridad Angular: X disp. / Agotado)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: stock > 0
                                                            ? const Color(0xFF10b981).withOpacity(0.9)
                                                            : const Color(0xFFef4444).withOpacity(0.9),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        stock > 0 ? '$stock disp.' : 'Agotado',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Content Section
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (description.isNotEmpty)
                                                        Text(
                                                          description,
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.5),
                                                            fontSize: 11,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      const Spacer(),
                                                      Text(
                                                        '\$${price.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          color: Color(0xFF06b6d4),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      // Acciones: Agregar al carrito | +/- | No disponible (paridad Angular)
                                                      if (stock == 0)
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                                          child: Text(
                                                            'No disponible',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.5),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        )
                                                      else if (inCart == 0)
                                                        SizedBox(
                                                          width: double.infinity,
                                                          child: TextButton(
                                                            onPressed: () => _incrementCart(productId, name, price, stock),
                                                            style: TextButton.styleFrom(
                                                              backgroundColor: const Color(0xFF06b6d4),
                                                              foregroundColor: Colors.white,
                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: const Text('Agregar al carrito', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                          ),
                                                        )
                                                      else
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withOpacity(0.08),
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              _QtyButton(
                                                                icon: AppIcons.minus,
                                                                onTap: () => _decrementCart(productId),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                inCart.toString(),
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              _QtyButton(
                                                                icon: AppIcons.add,
                                                                onTap: canAddMore
                                                                    ? () => _incrementCart(productId, name, price, stock)
                                                                    : null,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer del carrito (paridad Angular catalog-cart-drawer)
          if (_showCartDrawer)
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () => setState(() => _showCartDrawer = false),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  color: Colors.black54,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.9,
                                        width: width > 400 ? 400 : width * 0.9,
                                        child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0f172a),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              blurRadius: 24,
                                              offset: const Offset(-4, 0),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Carrito',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () => setState(() => _showCartDrawer = false),
                                                    icon: const Icon(Icons.close, color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(height: 1, color: Colors.white24),
                                            Expanded(
                                              child: _cart.isEmpty
                                                  ? Padding(
                                                      padding: const EdgeInsets.all(32),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            AppIcons.shoppingCart,
                                                            size: 48,
                                                            color: Colors.white.withOpacity(0.5),
                                                          ),
                                                          const SizedBox(height: 16),
                                                          const Text(
                                                            'Tu carrito está vacío',
                                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            'Agrega productos para continuar',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.6),
                                                              fontSize: 14,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : ListView.builder(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      itemCount: _cart.length,
                                                      itemBuilder: (context, index) {
                                                        final entry = _cart.entries.elementAt(index);
                                                        final productId = entry.key;
                                                        final item = entry.value;
                                                        final price = item['price'] as double;
                                                        final qty = item['quantity'] as int;
                                                        final subtotal = price * qty;
                                                        final productList = _products.where((x) =>
                                                            x is Map && x['id']?.toString() == productId).toList();
                                                        final productMap = productList.isNotEmpty ? productList.first as Map<String, dynamic> : null;
                                                        final maxStock = productMap != null ? _stockFromProduct(productMap) : 999;
                                                        return Padding(
                                                          padding: const EdgeInsets.only(bottom: 12),
                                                          child: Container(
                                                            padding: const EdgeInsets.all(12),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.06),
                                                              borderRadius: BorderRadius.circular(12),
                                                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        item['name'] as String,
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 14,
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                      const SizedBox(height: 4),
                                                                      Text(
                                                                        '\$${price.toStringAsFixed(2)} c/u',
                                                                        style: TextStyle(
                                                                          color: Colors.white.withOpacity(0.7),
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    _QtyButton(
                                                                      icon: AppIcons.minus,
                                                                      onTap: () {
                                                                        _decrementCart(productId);
                                                                        if (_cart.isEmpty) setState(() => _showCartDrawer = false);
                                                                      },
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                                                      child: Text(
                                                                        qty.toString(),
                                                                        style: const TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _QtyButton(
                                                                      icon: AppIcons.add,
                                                                      onTap: qty < maxStock
                                                                          ? () => _incrementCartInDrawer(productId, maxStock)
                                                                          : null,
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  '\$${subtotal.toStringAsFixed(2)}',
                                                                  style: const TextStyle(
                                                                    color: Color(0xFF06b6d4),
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  onPressed: () {
                                                                    _removeFromCart(productId);
                                                                    if (_cart.isEmpty) setState(() => _showCartDrawer = false);
                                                                  },
                                                                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                            if (_cart.isNotEmpty) ...[
                                              const Divider(height: 1, color: Colors.white24),
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text(
                                                          'Total',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          '\$${_cartTotal.toStringAsFixed(2)}',
                                                          style: const TextStyle(
                                                            color: Color(0xFF06b6d4),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          setState(() => _showCartDrawer = false);
                                                          _checkoutCart();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF06b6d4),
                                                          foregroundColor: Colors.white,
                                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                        child: const Text('Ir a pagar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                                    ),
          // Notifications panel
          if (_showNotifications)
            Positioned(
              top: 100,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                child: NotificationsPanel(
                  notificationService: _notificationService,
                  unreadCount: _unreadNotificationsCount,
                  onNotificationTap: () {
                    _markNotificationsAsRead();
                    setState(() => _showNotifications = false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }



  /// Agregar o incrementar en carrito respetando stock (paridad Angular quickAddToCart / incrementCartItem)
  void _incrementCart(String productId, String productName, double price, int maxStock) {
    if (maxStock <= 0) {
      LiquidGlassSnackBar.showWarning(context, 'Producto agotado');
      return;
    }
    final currentQty = _cart[productId]?['quantity'] as int? ?? 0;
    if (currentQty >= maxStock) {
      LiquidGlassSnackBar.showWarning(context, 'Solo hay $maxStock unidades disponibles');
      return;
    }
    final previous = currentQty;
    setState(() {
      final current = _cart[productId];
      if (current == null) {
        _cart[productId] = {
          'name': productName,
          'price': price,
          'quantity': 1,
        };
      } else {
        current['quantity'] = (current['quantity'] as int) + 1;
      }
      _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
    });
    _saveCartToStorage();
    if (previous == 0) {
      _showCartConfirmation(productName, 1, price);
      // Abrir drawer brevemente como feedback (paridad Angular)
      setState(() => _showCartDrawer = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _cart.isNotEmpty) setState(() => _showCartDrawer = false);
      });
    }
  }

  void _decrementCart(String productId) {
    setState(() {
      final current = _cart[productId];
      if (current == null) return;
      final qty = (current['quantity'] as int) - 1;
      if (qty <= 0) {
        _cart.remove(productId);
      } else {
        current['quantity'] = qty;
      }
      _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
    });
    _saveCartToStorage();
  }

  void _removeFromCart(String productId) {
    setState(() {
      _cart.remove(productId);
      _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
    });
    _saveCartToStorage();
  }

  /// Incrementar desde el drawer del carrito (necesita stock actual del producto)
  void _incrementCartInDrawer(String productId, int maxStock) {
    final item = _cart[productId];
    if (item == null) return;
    final qty = item['quantity'] as int;
    if (qty >= maxStock) {
      LiquidGlassSnackBar.showWarning(context, 'Stock máximo: $maxStock');
      return;
    }
    setState(() {
      item['quantity'] = qty + 1;
      _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
    });
    _saveCartToStorage();
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final name = product['name'] ?? product['title'] ?? 'Producto';
    final price = (product['price'] ?? product['unitPrice'] ?? 0).toDouble();
    final description = product['description'] ?? 'Sin descripción disponible';
    final imageUrl = product['imageUrl'] ?? product['image_url'] ?? product['image'];
    final stock = product['stock'] ?? product['available_quantity'];
    final category = product['category'] ?? product['categoryName'];
    final productId = product['id']?.toString() ?? '';
    final inCart = _cart[productId]?['quantity'] ?? 0;
    int dialogQty = inCart;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // Image Section
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.05),
                        child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return frame == null
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    )
                                  : child;
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    AppIcons.shoppingBag,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                AppIcons.shoppingBag,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                    if (inCart > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf97316),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFf97316).withOpacity(0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(AppIcons.shoppingCart, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '$inCart en carrito',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // Content Section
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF06b6d4),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Category and Stock
                        Row(
                          children: [
                            if (category != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06b6d4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF06b6d4).withOpacity(0.5)),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Color(0xFF06b6d4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (stock != null && stock is int)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (stock > 10 ? const Color(0xFF10b981) : const Color(0xFFef4444)).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (stock > 10 ? const Color(0xFF10b981) : const Color(0xFFef4444)).withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  stock > 10 ? 'En stock' : 'Solo $stock disponibles',
                                  style: TextStyle(
                                    color: stock > 10 ? const Color(0xFF10b981) : const Color(0xFFef4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Description
                        Text(
                          'Descripción',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Inline quantity control
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QtyButton(
                        icon: AppIcons.minus,
                        onTap: dialogQty > 0
                            ? () {
                                _decrementCart(productId);
                                setDialogState(() => dialogQty = (dialogQty - 1).clamp(0, 999));
                              }
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dialogQty.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QtyButton(
                        icon: AppIcons.add,
                        onTap: () {
                          final maxStock = _stockFromProduct(product);
                          if (dialogQty < maxStock) {
                            _incrementCart(productId, name, price, maxStock);
                            setDialogState(() => dialogQty = dialogQty + 1);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCartConfirmation(String productName, int quantity, double price) {
    LiquidGlassSnackBar.showSuccess(
      context,
      '$quantity x $productName agregado(s) - \$${(price * quantity).toStringAsFixed(2)}',
      duration: const Duration(seconds: 2),
    );
    setState(() => _showCartDrawer = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCartDrawer = false);
    });
  }

  void _openCartDrawer() {
    setState(() => _showCartDrawer = true);
  }

  void _showCartSummaryLegacy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_cart.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0f172a).withOpacity(0.95),
            title: const Text('Carrito', style: TextStyle(color: Colors.white)),
            content: Text(
              'Tu carrito está vacío',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: Color(0xFF06b6d4))),
              ),
            ],
          );
        }

        double total = 0;
        for (var item in _cart.values) {
          total += (item['price'] as double) * (item['quantity'] as int);
        }

        return AlertDialog(
          backgroundColor: const Color(0xFF0f172a).withOpacity(0.95),
          title: const Text('Carrito de Compras', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final entry = _cart.entries.elementAt(index);
                      final productId = entry.key;
                      final item = entry.value;
                      final subtotal = (item['price'] as double) * (item['quantity'] as int);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _cart.remove(productId);
                                        _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
                                      });
                                      _saveCartToStorage();
                                      Navigator.pop(context);
                                      if (_cart.isNotEmpty) {
                                        _openCartDrawer();
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cantidad: ${item['quantity']}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                                  ),
                                  Text(
                                    '\$${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF06b6d4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFF06b6d4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF10b981),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continuar comprando',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
              ),
              onPressed: () {
                Navigator.pop(context);
                _checkoutCart();
              },
              child: const Text('Proceder a Pago', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkoutCart() async {
    if (_cart.isEmpty) {
      LiquidGlassSnackBar.showWarning(context, 'El carrito está vacío');
      return;
    }

    String storeName = _store?['name']?.toString() ?? 'Tienda';

    // Navigate to checkout page using NavigationService
    navigationService.goToClientCheckout(
      context,
      widget.storeId,
      storeName: storeName,
      cart: Map<String, Map<String, dynamic>>.from(_cart),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isEnabled ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(isEnabled ? 0.25 : 0.12),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isEnabled ? const Color(0xFF06b6d4) : Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? const Color(0xFF06b6d4) : Colors.white.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(999),
              color: selected ? const Color(0xFF06b6d4).withOpacity(0.35) : Colors.white.withOpacity(0.08),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
