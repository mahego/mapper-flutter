import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/client/presentation/pages/client_dashboard_container.dart';
import '../../features/provider/presentation/pages/provider_dashboard_page.dart';
import '../../features/provider/presentation/pages/bolsa_trabajo_page.dart';
import '../../features/provider/presentation/pages/provider_requests_page.dart';
import '../../features/provider/presentation/pages/provider_subscriptions_page.dart';
import '../../features/provider/presentation/pages/provider_pos_page.dart';
import '../../features/auctions/presentation/pages/auctions_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/client/presentation/pages/requests_page.dart';
import '../../features/client/presentation/pages/client_tracking_page.dart';
import '../../features/client/presentation/pages/new_request_page.dart';
import '../../features/client/presentation/pages/request_detail_page.dart';
import '../../features/client/presentation/pages/request_tracking_page.dart';
import '../../features/client/presentation/pages/client_catalog_page.dart';
import '../../features/client/presentation/pages/store_order_detail_page.dart';
import '../../features/store/presentation/pages/store_pos_page.dart';
import '../../features/store/presentation/pages/store_catalog_page.dart';
import '../../features/store/presentation/pages/store_orders_page.dart';
import '../../features/store/presentation/pages/store_more_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // === Rutas estilo Angular (paridad cliente) ===
      GoRoute(
        path: '/login',
        name: 'login_angular',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register_angular',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard/cliente',
        name: 'dashboard_cliente',
        builder: (context, state) => const ClientDashboardContainer(),
      ),
      GoRoute(
        path: '/requests',
        name: 'requests_list',
        builder: (context, state) => const RequestsPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'requests_new',
            builder: (context, state) => const NewRequestPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'request_detail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return RequestDetailPage(requestId: id);
            },
          ),
          GoRoute(
            path: ':id/tracking',
            name: 'request_tracking',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return RequestTrackingPage(requestId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/cliente/tracking',
        name: 'cliente_tracking',
        builder: (context, state) => const ClientTrackingPage(),
      ),
      GoRoute(
        path: '/cliente/catalog/:storeId',
        name: 'cliente_catalog',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId'] ?? '';
          return ClientCatalogPage(storeId: storeId);
        },
      ),
      GoRoute(
        path: '/cliente/store-order/:id',
        name: 'store_order_detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StoreOrderDetailPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile_angular',
        builder: (context, state) => const ProfilePage(),
      ),
      // === Auth (legacy) ===
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // Main
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/client/dashboard',
        name: 'client_dashboard',
        builder: (context, state) => const ClientDashboardContainer(),
      ),
      GoRoute(
        path: '/store/pos',
        name: 'store_pos',
        builder: (context, state) => const StorePosPage(),
      ),
      GoRoute(
        path: '/store/catalog',
        name: 'store_catalog',
        builder: (context, state) => const StoreCatalogPage(),
      ),
      GoRoute(
        path: '/store/orders',
        name: 'store_orders',
        builder: (context, state) => const StoreOrdersPage(),
      ),
      GoRoute(
        path: '/store/more',
        name: 'store_more',
        builder: (context, state) => const StoreMorePage(),
      ),
      GoRoute(
        path: '/provider/dashboard',
        name: 'provider_dashboard',
        builder: (context, state) => const ProviderDashboardPage(),
      ),
      GoRoute(
        path: '/provider/bolsa-trabajo',
        name: 'bolsa_trabajo',
        builder: (context, state) => const BolsaTrabajoPage(),
      ),
      GoRoute(
        path: '/provider/requests',
        name: 'provider_requests',
        builder: (context, state) => const ProviderRequestsPage(),
      ),
      GoRoute(
        path: '/provider/subscriptions',
        name: 'provider_subscriptions',
        builder: (context, state) => const ProviderSubscriptionsPage(),
      ),
      GoRoute(
        path: '/provider/pos',
        name: 'provider_pos',
        builder: (context, state) => const ProviderPosPage(),
      ),
      GoRoute(
        path: '/auctions',
        name: 'auctions',
        builder: (context, state) => const AuctionsPage(),
      ),
      GoRoute(
        path: '/vehicles',
        name: 'vehicles',
        builder: (context, state) => const VehiclesPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
