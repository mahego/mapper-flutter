import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Servicio centralizado para manejar toda la navegación de la app
/// Evita hardcodear rutas y centraliza los flujos de navegación
class NavigationService {
  // Singleton
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // ============================================
  // AUTH ROUTES
  // ============================================
  
  void goToLogin(BuildContext context) {
    context.go('/login');
  }

  void goToRegister(BuildContext context) {
    context.go('/register');
  }

  void goToForgotPassword(BuildContext context) {
    context.go('/auth/forgot-password');
  }

  // ============================================
  // CLIENT ROUTES
  // ============================================
  
  void goToClientDashboard(BuildContext context) {
    context.go('/dashboard/cliente');
  }

  void goToClientRequests(BuildContext context) {
    context.go('/dashboard/cliente', extra: {'tab': 1});
  }

  void goToNewRequest(BuildContext context) {
    context.push('/requests/new');
  }

  void goToRequestDetail(BuildContext context, String requestId) {
    context.push('/requests/$requestId');
  }

  void goToRequestTracking(BuildContext context, String requestId) {
    context.push('/requests/$requestId/tracking');
  }

  void goToClientTracking(BuildContext context) {
    context.go('/cliente/tracking');
  }

  void goToClientCatalog(BuildContext context, String storeId) {
    context.push('/cliente/catalog/$storeId');
  }

  void goToClientCheckout(
    BuildContext context,
    String storeId, {
    required String storeName,
    required Map<String, Map<String, dynamic>> cart,
  }) {
    context.push(
      '/cliente/catalog/$storeId/checkout',
      extra: {
        'storeId': storeId,
        'storeName': storeName,
        'cart': cart,
      },
    );
  }

  void goToOrderConfirmation(
    BuildContext context, {
    required String orderId,
    required String storeName,
    required double total,
    required double deliveryFee,
    required String status,
  }) {
    context.go(
      '/client/order-confirmation',
      extra: {
        'orderId': orderId,
        'storeName': storeName,
        'total': total,
        'deliveryFee': deliveryFee,
        'status': status,
      },
    );
  }

  void goToStoreOrderDetail(BuildContext context, String orderId) {
    context.push('/cliente/store-order/$orderId');
  }

  void goToProfile(BuildContext context) {
    context.go('/profile');
  }

  // ============================================
  // PROVIDER ROUTES
  // ============================================
  
  void goToProviderDashboard(BuildContext context) {
    context.go('/dashboard/provider');
  }

  void goToBolsaTrabajo(BuildContext context) {
    context.go('/bolsa-trabajo');
  }

  void goToProviderRequests(BuildContext context) {
    context.go('/provider/requests');
  }

  void goToProviderSubscriptions(BuildContext context) {
    context.go('/provider/subscriptions');
  }

  void goToProviderPOS(BuildContext context) {
    context.go('/provider/pos');
  }

  // ============================================
  // STORE ROUTES
  // ============================================
  
  void goToStorePOS(BuildContext context) {
    context.go('/store/pos');
  }

  void goToStoreCatalog(BuildContext context) {
    context.go('/store/catalog');
  }

  void goToStoreOrders(BuildContext context) {
    context.go('/store/orders');
  }

  void goToStoreMore(BuildContext context) {
    context.go('/store/more');
  }

  // ============================================
  // OTHER ROUTES
  // ============================================

  void goToAuctions(BuildContext context) {
    context.go('/auctions');
  }

  void goToVehicles(BuildContext context) {
    context.go('/vehicles');
  }

  void goToOrders(BuildContext context) {
    context.go('/orders');
  }

  // ============================================
  // NAVIGATION HELPERS
  // ============================================

  /// Navega hacia atrás
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Reemplaza la ruta actual
  void replace(BuildContext context, String path, {Object? extra}) {
    context.replace(path, extra: extra);
  }

  /// Navega y limpia el stack hasta una ruta específica
  void goAndClearUntil(BuildContext context, String path) {
    context.go(path);
  }
}

// Instancia global para acceso rápido
final navigationService = NavigationService();
