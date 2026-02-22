import 'package:flutter/material.dart';
import '../widgets/liquid_glass_drawer.dart';

/// Drawer menu configuration for each role
/// Based on Angular's drawer content structure

class DrawerMenuConfig {
  /// Get drawer menu items based on user role
  static List<DrawerMenuItem> getDrawerMenuItems({
    required String? role,
    required VoidCallback onLogout,
    VoidCallback? onRefresh,
  }) {
    if (role == null) return [];

    switch (role.toLowerCase()) {
      case 'cliente':
        return _buildClienteMenu(onLogout, onRefresh);
      case 'prestador':
        return _buildPrestadorMenu(onLogout, onRefresh);
      case 'tienda':
      case 'store':
        return _buildStoreMenu(onLogout, onRefresh);
      default:
        return [];
    }
  }

  /// Cliente drawer menu
  static List<DrawerMenuItem> _buildClienteMenu(
    VoidCallback onLogout,
    VoidCallback? onRefresh,
  ) {
    return [
      const DrawerMenuItem(
        label: 'Nueva solicitud',
        icon: Icons.add_circle_outline,
        route: '/client/requests/new',
      ),
      const DrawerMenuItem(
        label: 'Mis solicitudes',
        icon: Icons.assignment_outlined,
        route: '/client/requests',
      ),
      const DrawerMenuItem(
        label: 'Tracking',
        icon: Icons.location_on_outlined,
        route: '/client/tracking',
      ),
      const DrawerMenuItem(
        label: 'Subastas',
        icon: Icons.gavel_outlined,
        route: '/client/auctions',
      ),
      const DrawerMenuItem(
        label: 'Mi Perfil',
        icon: Icons.person_outline,
        route: '/profile',
      ),
      if (onRefresh != null)
        DrawerMenuItem(
          label: 'Refrescar',
          icon: Icons.refresh,
          onTap: onRefresh,
        ),
      DrawerMenuItem(
        label: 'Cerrar sesión',
        icon: Icons.logout,
        onTap: onLogout,
        isLogout: true,
      ),
    ];
  }

  /// Prestador drawer menu
  static List<DrawerMenuItem> _buildPrestadorMenu(
    VoidCallback onLogout,
    VoidCallback? onRefresh,
  ) {
    return [
      const DrawerMenuItem(
        label: 'Inicio',
        icon: Icons.home_outlined,
        route: '/provider/home',
      ),
      const DrawerMenuItem(
        label: 'POS Prestador',
        icon: Icons.shopping_cart_outlined,
        route: '/provider/pos',
      ),
      const DrawerMenuItem(
        label: 'Bolsa de Trabajo',
        icon: Icons.work_outline,
        route: '/provider/bolsa',
      ),
      const DrawerMenuItem(
        label: 'Subastas',
        icon: Icons.gavel_outlined,
        route: '/provider/auctions',
      ),
      const DrawerMenuItem(
        label: 'Mis Vehículos',
        icon: Icons.directions_car_outlined,
        route: '/provider/vehicles',
      ),
      const DrawerMenuItem(
        label: 'Ganancias',
        icon: Icons.attach_money,
        route: '/provider/earnings',
      ),
      const DrawerMenuItem(
        label: 'Mi Perfil',
        icon: Icons.person_outline,
        route: '/profile',
      ),
      if (onRefresh != null)
        DrawerMenuItem(
          label: 'Refrescar',
          icon: Icons.refresh,
          onTap: onRefresh,
        ),
      DrawerMenuItem(
        label: 'Cerrar sesión',
        icon: Icons.logout,
        onTap: onLogout,
        isLogout: true,
      ),
    ];
  }

  /// Store drawer menu
  static List<DrawerMenuItem> _buildStoreMenu(
    VoidCallback onLogout,
    VoidCallback? onRefresh,
  ) {
    return [
      const DrawerMenuItem(
        label: 'POS',
        icon: Icons.shopping_cart_outlined,
        route: '/store/pos',
      ),
      const DrawerMenuItem(
        label: 'Catálogo',
        icon: Icons.inventory_2_outlined,
        route: '/store/catalog',
      ),
      const DrawerMenuItem(
        label: 'Pedidos',
        icon: Icons.assignment_outlined,
        route: '/store/orders',
      ),
      const DrawerMenuItem(
        label: 'Efectivo',
        icon: Icons.monetization_on_outlined,
        route: '/store/cash',
      ),
      const DrawerMenuItem(
        label: 'Turnos',
        icon: Icons.access_time,
        route: '/store/shifts',
      ),
      const DrawerMenuItem(
        label: 'Libro de Pedidos',
        icon: Icons.menu_book,
        route: '/store/order-book',
      ),
      const DrawerMenuItem(
        label: 'Mi Perfil',
        icon: Icons.person_outline,
        route: '/profile',
      ),
      if (onRefresh != null)
        DrawerMenuItem(
          label: 'Refrescar',
          icon: Icons.refresh,
          onTap: onRefresh,
        ),
      DrawerMenuItem(
        label: 'Cerrar sesión',
        icon: Icons.logout,
        onTap: onLogout,
        isLogout: true,
      ),
    ];
  }
}
