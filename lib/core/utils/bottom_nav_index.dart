import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Devuelve el índice del bottom nav según la ruta actual (paridad con Angular routerLinkActive).
/// Uso: ProviderBottomNav(currentIndex: BottomNavIndex.provider(context))
class BottomNavIndex {
  /// Rutas en orden para cliente (si se usara un shell con rutas)
  static const List<String> clientPaths = [
    '/client/dashboard',
    '/dashboard/cliente',
    '/requests',
    '/cliente/tracking',
    '/profile',
  ];

  /// Rutas en orden para tienda
  static const List<String> storePaths = [
    '/store/pos',
    '/store/catalog',
    '/store/orders',
    '/store/more',
    '/profile',
  ];

  /// Rutas en orden para prestador (ProviderBottomNav.items)
  static const List<String> providerPaths = [
    '/provider/dashboard',
    '/provider/pos',
    '/provider/bolsa-trabajo',
    '/auctions',
    '/vehicles',
    '/profile',
  ];

  /// Índice para StoreBottomNav (0=POS, 1=Catálogo, 2=Pedidos, 3=Más, 4=Perfil)
  static int store(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final idx = storePaths.indexWhere((p) => path == p || path.startsWith('$p/'));
    return idx >= 0 ? idx : 0;
  }

  /// Índice para ProviderBottomNav (0=Inicio, 1=POS, 2=Bolsa, 3=Subastas, 4=Vehículos, 5=Perfil)
  static int provider(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final idx = providerPaths.indexWhere((p) => path == p || path.startsWith('$p/'));
    return idx >= 0 ? idx : 0;
  }

  /// Índice para cliente (Inicio=0, Solicitudes=1, Tracking=2, Perfil=3)
  static int client(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == '/client/dashboard' || path == '/dashboard/cliente') return 0;
    if (path == '/requests' || path.startsWith('/requests/')) return 1;
    if (path == '/cliente/tracking') return 2;
    if (path == '/profile') return 3;
    return 0;
  }
}
