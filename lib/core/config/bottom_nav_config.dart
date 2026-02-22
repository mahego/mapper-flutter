import 'package:flutter/material.dart';
import '../widgets/liquid_glass_bottom_nav.dart';

/// Bottom navigation configuration for each role
/// Based on Angular's bottom-nav.config.ts

class BottomNavConfig {
  /// Get bottom navigation items based on user role
  static List<BottomNavItem> getBottomNavItems(String? role) {
    if (role == null) return [];
    
    switch (role.toLowerCase()) {
      case 'cliente':
        return _clienteBottomNavItems;
      case 'prestador':
        return _prestadorBottomNavItems;
      case 'tienda':
      case 'store':
        return _storeBottomNavItems;
      default:
        return [];
    }
  }

  /// Cliente bottom navigation items
  static const List<BottomNavItem> _clienteBottomNavItems = [
    BottomNavItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      route: '/client/home',
    ),
    BottomNavItem(
      label: 'Solicitudes',
      icon: Icons.assignment_outlined,
      route: '/client/requests',
    ),
    BottomNavItem(
      label: 'Tracking',
      icon: Icons.location_on_outlined,
      route: '/client/tracking',
    ),
    BottomNavItem(
      label: 'Subastas',
      icon: Icons.gavel_outlined,
      route: '/client/auctions',
    ),
    BottomNavItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      route: '/profile',
    ),
  ];

  /// Prestador bottom navigation items
  static const List<BottomNavItem> _prestadorBottomNavItems = [
    BottomNavItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      route: '/provider/home',
    ),
    BottomNavItem(
      label: 'POS',
      icon: Icons.shopping_cart_outlined,
      route: '/provider/pos',
    ),
    BottomNavItem(
      label: 'Bolsa',
      icon: Icons.work_outline,
      route: '/provider/bolsa',
    ),
    BottomNavItem(
      label: 'Subastas',
      icon: Icons.gavel_outlined,
      route: '/provider/auctions',
    ),
    BottomNavItem(
      label: 'Vehículos',
      icon: Icons.directions_car_outlined,
      route: '/provider/vehicles',
    ),
    BottomNavItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      route: '/profile',
    ),
  ];

  /// Store bottom navigation items (max 5 items)
  static const List<BottomNavItem> _storeBottomNavItems = [
    BottomNavItem(
      label: 'POS',
      icon: Icons.shopping_cart_outlined,
      route: '/store/pos',
    ),
    BottomNavItem(
      label: 'Catálogo',
      icon: Icons.inventory_2_outlined,
      route: '/store/catalog',
    ),
    BottomNavItem(
      label: 'Pedidos',
      icon: Icons.assignment_outlined,
      route: '/store/orders',
    ),
    BottomNavItem(
      label: 'Más',
      icon: Icons.menu,
      route: '/store/more',
    ),
    BottomNavItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      route: '/profile',
    ),
  ];
}
