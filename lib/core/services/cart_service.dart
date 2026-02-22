import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de persistencia del carrito de compras
/// 
/// Características:
/// - Persistencia automática en SharedPreferences (web + mobile)
/// - Expiración de 24 horas con sistema de recuperación
/// - Validación de tienda (evita conflictos entre stores)
/// - Soporte para carritos expirados (recovery cart)
/// 
/// Flujo típico:
/// 1. Usuario agrega items → saveCart()
/// 2. Cierra app → datos persistidos
/// 3. Abre app < 24h → loadCart() retorna items
/// 4. Abre app > 24h → carrito movido a recovery
/// 5. Usuario decide: recuperar o descartar
/// 
/// Ejemplo de uso:
/// ```dart
/// final cartService = CartService();
/// 
/// // Guardar
/// await cartService.saveCart(
///   items: _cart,
///   storeId: '123',
///   total: 45.99,
/// );
/// 
/// // Cargar
/// final cart = await cartService.loadCart();
/// if (cart != null) {
///   // Carrito válido (< 24h)
/// } else {
///   // Verificar recovery
///   final recovery = await cartService.getRecoveryCart();
/// }
/// ```
class CartService {
  static const String _cartKey = 'mapper_cart';
  static const String _cartRecoveryKey = 'mapper_cart_recovery';
  static const Duration _cartExpiration = Duration(hours: 24);

  /// Guarda el carrito actual en storage
  /// 
  /// El carrito incluye:
  /// - items: {productId: {name, price, quantity, ...}}
  /// - timestamp: DateTime ISO string para validar expiración
  /// - storeId: ID de la tienda
  /// - total: Precio total
  Future<void> saveCart({
    required Map<String, Map<String, dynamic>> items,
    required String storeId,
    required double total,
  }) async {
    try {
      final cartData = {
        'items': items,
        'storeId': storeId,
        'total': total,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final jsonString = jsonEncode(cartData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonString);
      
      debugPrint('[CartService] Guardado: ${jsonString.length} bytes, ${items.length} items');
    } catch (e) {
      debugPrint('[CartService] Error guardando carrito: $e');
    }
  }

  /// Carga el carrito del storage si es válido (< 24h)
  /// Retorna null si no hay carrito o expiró
  /// 
  /// Si encontró carrito expirado, lo guarda en recovery para poder recuperarlo
  Future<Map<String, dynamic>?> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartKey);
      
      if (jsonString == null) {
        debugPrint('[CartService] No hay carrito guardado');
        return null;
      }

      final cartData = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestampStr = cartData['timestamp'] as String?;
      
      if (timestampStr == null) {
        debugPrint('[CartService] Carrito sin timestamp, descartando');
        await clearCart();
        return null;
      }

      final savedTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final age = now.difference(savedTime);

      // Verificar si expiró (> 24h)
      if (age > _cartExpiration) {
        debugPrint('[CartService] Carrito expirado (${age.inHours}h), moviendo a recovery');
        
        // Mover a recovery cart
        await prefs.setString(_cartRecoveryKey, jsonString);
        await clearCart();
        
        return null;
      }

      debugPrint('[CartService] Carrito cargado (${age.inMinutes} min de antigüedad)');
      return cartData;
      
    } catch (e) {
      debugPrint('[CartService] Error cargando carrito: $e');
      return null;
    }
  }

  /// Obtiene carrito de recuperación si existe
  /// Retorna null si no hay o ya fue recuperado/descartado
  Future<Map<String, dynamic>?> getRecoveryCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartRecoveryKey);
      
      if (jsonString == null) {
        debugPrint('[CartService] No hay carrito de recovery');
        return null;
      }

      final cartData = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('[CartService] Recovery cart encontrado');
      return cartData;
      
    } catch (e) {
      debugPrint('[CartService] Error cargando recovery cart: $e');
      return null;
    }
  }

  /// Limpia el carrito actual del storage
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      debugPrint('[CartService] Carrito borrado');
    } catch (e) {
      debugPrint('[CartService] Error borrando carrito: $e');
    }
  }

  /// Limpia el carrito de recuperación
  Future<void> clearRecoveryCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartRecoveryKey);
      debugPrint('[CartService] Carrito de recovery borrado');
    } catch (e) {
      debugPrint('[CartService] Error borrando recovery cart: $e');
    }
  }

  /// Verifica si el carrito existe y es válido (no expiró)
  Future<bool> hasValidCart() async {
    final cart = await loadCart();
    return cart != null;
  }

  /// Verifica si existe un carrito de recuperación (expirado)
  Future<bool> hasRecoveryCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartRecoveryKey);
      return jsonString != null;
    } catch (e) {
      debugPrint('[CartService] Error verificando recovery cart: $e');
      return false;
    }
  }

  /// Obtiene la antigüedad del carrito actual (si existe)
  /// Retorna Duration o null si no hay carrito
  Future<Duration?> getCartAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartKey);
      
      if (jsonString == null) return null;

      final cartData = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestampStr = cartData['timestamp'] as String?;
      
      if (timestampStr == null) return null;

      final savedTime = DateTime.parse(timestampStr);
      return DateTime.now().difference(savedTime);
    } catch (e) {
      debugPrint('[CartService] Error obteniendo antigüedad del carrito: $e');
      return null;
    }
  }

  /// Obtiene resumen del carrito guardado (sin cargar items completos)
  /// Útil para mostrar en badge del header
  Future<CartSummary?> getCartSummary() async {
    try {
      final cart = await loadCart();
      if (cart == null) return null;

      final items = cart['items'] as Map<String, dynamic>? ?? {};
      final total = cart['total'] as double? ?? 0.0;
      final itemCount = items.length;

      return CartSummary(
        itemCount: itemCount,
        total: total,
        storeId: cart['storeId'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[CartService] Error obteniendo summary: $e');
      return null;
    }
  }

  /// Limpia todos los datos del carrito (activo + recovery)
  /// Útil para debugging o logout
  Future<void> clearAll() async {
    await clearCart();
    await clearRecoveryCart();
    debugPrint('[CartService] Todos los datos del carrito borrados');
  }
}

/// Datos resumidos del carrito para mostrar en UI
class CartSummary {
  final int itemCount;
  final double total;
  final String storeId;

  CartSummary({
    required this.itemCount,
    required this.total,
    required this.storeId,
  });

  @override
  String toString() => 'CartSummary(items: $itemCount, total: \$$total, store: $storeId)';
}

/// Extensión para cálculo rápido de cantidad total de items
extension CartExtension on Map<String, Map<String, dynamic>> {
  /// Conta el total de items en el carrito (sumando cantidades)
  int get totalItemCount {
    int count = 0;
    for (final item in values) {
      final qty = item['quantity'] as int? ?? 1;
      count += qty;
    }
    return count;
  }

  /// Calcula el total del carrito
  double get totalPrice {
    double total = 0.0;
    for (final item in values) {
      final price = (item['price'] as num? ?? 0).toDouble();
      final qty = item['quantity'] as int? ?? 1;
      total += price * qty;
    }
    return total;
  }
}
