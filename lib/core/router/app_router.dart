import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/client/presentation/pages/client_dashboard_page.dart';
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
import '../../features/store/presentation/pages/store_pos_page.dart';
import '../../features/store/presentation/pages/store_catalog_page.dart';
import '../../features/store/presentation/pages/store_orders_page.dart';
import '../../features/store/presentation/pages/store_more_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth/login',
    routes: [
      // Auth Routes
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
      
      // Main Routes
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
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/client/dashboard',
        name: 'client_dashboard',
        builder: (context, state) => const ClientDashboardPage(),
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
      GoRoute(
        path: '/requests',
        name: 'requests',
        builder: (context, state) => const RequestsPage(),
      ),
      GoRoute(
        path: '/requests/new',
        name: 'new_request',
        builder: (context, state) => const NewRequestPage(),
      ),
      GoRoute(
        path: '/cliente/tracking',
        name: 'client_tracking',
        builder: (context, state) => const ClientTrackingPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
