import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Catálogo de una tienda para el cliente con soporte de carrito.
class ClientCatalogPage extends StatefulWidget {
  final String storeId;

  const ClientCatalogPage({super.key, required this.storeId});

  @override
  State<ClientCatalogPage> createState() => _ClientCatalogPageState();
}

class _ClientCatalogPageState extends State<ClientCatalogPage> {
  final _apiClient = ApiClient();
  late final _notificationService = NotificationService(apiClient: ApiClient());
  late final _cartService = CartService();
  
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;
  
  bool _drawerOpen = false;
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;
  
  // Cart state
  Map<String, Map<String, dynamic>> _cart = {}; // {productId: {name, price, quantity, product_data}}
  int _cartItemCount = 0;

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
      final productsRes = await _apiClient.get(ApiEndpoints.storeProductsList(widget.storeId));
      final data = productsRes.data;
      final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
      if (mounted) {
        setState(() {
          _products = list is List ? list : [];
          _loading = false;
        });
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Carrito retomado: $_cartItemCount artículos'),
                  backgroundColor: const Color(0xFF10b981),
                  duration: const Duration(seconds: 2),
                ),
              );
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
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Catálogo',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() => _showNotifications = !_showNotifications);
                                    if (_unreadNotificationsCount > 0) {
                                      _markNotificationsAsRead();
                                    }
                                  },
                                  icon: const Icon(Icons.notifications, color: Colors.white),
                                ),
                                if (_unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFf97316),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _unreadNotificationsCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: _cartItemCount > 0 ? _showCartSummary : null,
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: _cartItemCount > 0 ? const Color(0xFF10b981) : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                if (_cartItemCount > 0)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10b981),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _cartItemCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (width < 768)
                              IconButton(
                                onPressed: () {
                                  setState(() => _drawerOpen = !_drawerOpen);
                                },
                                icon: const Icon(Icons.menu, color: Colors.white),
                              )
                            else
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                          ],
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
                            : _products.isEmpty
                                ? Center(
                                    child: Text(
                                      'Esta tienda no tiene productos publicados.',
                                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    itemCount: _products.length,
                                    itemBuilder: (context, i) {
                                      final p = _products[i] as Map<String, dynamic>;
                                      final productId = p['id']?.toString() ?? i.toString();
                                      final name = p['name'] ?? p['title'] ?? 'Producto';
                                      final price = (p['price'] ?? p['unitPrice'] ?? 0).toDouble();
                                      final description = p['description'] ?? '';
                                      final inCart = _cart[productId]?['quantity'] ?? 0;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                            fontSize: 14,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '\$${price.toStringAsFixed(2)}',
                                                          style: const TextStyle(
                                                            color: Color(0xFF06b6d4),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (inCart > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFf97316).withOpacity(0.3),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: const Color(0xFFf97316)),
                                                      ),
                                                      child: Text(
                                                        '$inCart',
                                                        style: const TextStyle(
                                                          color: Color(0xFFf97316),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (description.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                  onPressed: () => _showAddToCartDialog(productId, name, price),
                                                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                                                  label: Text(inCart > 0 ? 'Modificar' : 'Agregar'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: const Color(0xFF06b6d4),
                                                    side: const BorderSide(color: Color(0xFF06b6d4)),
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
          // Drawer
          if (width < 768) _buildDrawer(),
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
      bottomNavigationBar: MediaQuery.of(context).size.width < 768 ? _buildBottomNav() : null,
    );
  }

  Widget _buildDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _drawerOpen ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Stack(
        children: [
          if (_drawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Catálogo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _drawerLink('Dashboard', Icons.dashboard_outlined, () {
                        context.go('/dashboard/cliente');
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Mi Carrito', Icons.shopping_cart_outlined, () {
                        _showCartSummary();
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Refrescar', Icons.refresh, () {
                        _load();
                        setState(() => _drawerOpen = false);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLink(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.8)),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildBottomNav() {
    return LiquidGlassBottomNav(
      items: const [
        BottomNavItem(label: 'Inicio', icon: Icons.home_outlined, route: '/dashboard/cliente'),
        BottomNavItem(label: 'Solicitudes', icon: Icons.assignment_outlined, route: '/solicitudes'),
        BottomNavItem(label: 'Tracking', icon: Icons.location_on_outlined, route: '/tracking'),
        BottomNavItem(label: 'Perfil', icon: Icons.person_outline, route: '/perfil'),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard/cliente');
            break;
          case 1:
            context.go('/solicitudes');
            break;
          case 2:
            context.go('/tracking');
            break;
          case 3:
            context.go('/perfil');
            break;
        }
      },
    );
  }

  void _showAddToCartDialog(String productId, String productName, double price) {
    int quantity = _cart[productId]?['quantity'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0f172a).withOpacity(0.95),
              title: Text(
                productName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Precio: \$${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF06b6d4), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cantidad',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: quantity > 0 ? () => setDialogState(() => quantity--) : null,
                          icon: const Icon(Icons.remove, color: Color(0xFF06b6d4)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setDialogState(() => quantity++),
                          icon: const Icon(Icons.add, color: Color(0xFF06b6d4)),
                        ),
                      ],
                    ),
                  ),
                  if (quantity > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Total: \$${(price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF10b981),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quantity > 0 ? const Color(0xFF06b6d4) : Colors.grey,
                  ),
                  onPressed: quantity > 0
                      ? () {
                          setState(() {
                            _cart[productId] = {
                              'name': productName,
                              'price': price,
                              'quantity': quantity,
                            };
                            _cartItemCount = _cart.values.fold(0, (a, b) => a + (b['quantity'] as int));
                          });
                          _saveCartToStorage();
                          Navigator.pop(context);
                          _showCartConfirmation(productName, quantity, price);
                        }
                      : null,
                  child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCartConfirmation(String productName, int quantity, double price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quantity x $productName agregado(s) - \$${(price * quantity).toStringAsFixed(2)}'),
        backgroundColor: const Color(0xFF10b981),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: _showCartSummary,
        ),
      ),
    );
  }

  void _showCartSummary() {
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
                                        _showCartSummary();
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
    final itemCount = _cart.length;
    final total = _cart.values.fold<double>(0, (sum, item) {
      return sum + ((item['price'] as double) * (item['quantity'] as int));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemCount producto(s) por \$$total. Funcionalidad de pago próximamente.'),
        backgroundColor: const Color(0xFF06b6d4),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Implementar pago real
    // Por ahora, limpiar carrito después de "checkout" simulado
    // En producción, esto sucedería después de confirmar el pago
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      setState(() {
        _cart.clear();
        _cartItemCount = 0;
      });
      await _cartService.clearCart();
      print('[ClientCatalogPage] Carrito limpiado después de checkout');
    } catch (e) {
      print('Error clearing cart after checkout: $e');
    }
  }
}
