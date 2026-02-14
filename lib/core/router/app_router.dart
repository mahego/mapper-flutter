import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/client/presentation/pages/client_dashboard_page.dart';
import '../../features/store/presentation/pages/store_dashboard_page.dart';
import '../../features/provider/presentation/pages/provider_dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
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
        path: '/store/dashboard',
        name: 'store_dashboard',
        builder: (context, state) => const StoreDashboardPage(),
      ),
      GoRoute(
        path: '/provider/dashboard',
        name: 'provider_dashboard',
        builder: (context, state) => const ProviderDashboardPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
