import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/pages/not_found_page.dart';
import '../../core/pages/static_legal_page.dart';
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
import '../../features/client/presentation/pages/client_checkout_page.dart';
import '../../features/client/presentation/pages/order_confirmation_page.dart';
import '../../features/client/presentation/pages/store_order_detail_page.dart';
import '../../features/client/presentation/pages/pos_pay_page.dart';
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final tab = extra?['tab'] as int?;
          return ClientDashboardContainer(initialTabIndex: tab);
        },
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
        routes: [
          GoRoute(
            path: 'checkout',
            name: 'cliente_checkout',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              if (extra == null) {
                return const Scaffold(
                  body: Center(child: Text('Error: datos de carrito no disponibles')),
                );
              }
              return ClientCheckoutPage(
                storeId: extra['storeId'] as String,
                storeName: extra['storeName'] as String,
                cart: extra['cart'] as Map<String, Map<String, dynamic>>,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/client/order-confirmation',
        name: 'order_confirmation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Error: datos de orden no disponibles')),
            );
          }
          final deliveryLat = extra['deliveryLat'] is num ? (extra['deliveryLat'] as num).toDouble() : null;
          final deliveryLng = extra['deliveryLng'] is num ? (extra['deliveryLng'] as num).toDouble() : null;
          return OrderConfirmationPage(
            orderId: extra['orderId'] as String,
            storeName: extra['storeName'] as String,
            total: extra['total'] as double,
            deliveryFee: extra['deliveryFee'] as double,
            status: extra['status'] as String,
            deliveryLat: deliveryLat,
            deliveryLng: deliveryLng,
          );
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
      GoRoute(
        path: '/pay',
        name: 'pos_pay',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session'] ?? state.pathParameters['sessionId'] ?? '';
          if (sessionId.isEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Enlace de pago inválido', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }
          return PosPayPage(sessionId: sessionId);
        },
        routes: [
          GoRoute(
            path: 'success',
            name: 'pos_pay_success',
            builder: (context, state) {
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 80, color: Colors.green.shade300),
                        const SizedBox(height: 24),
                        Text('Pago exitoso', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('La tienda recibió tu pago.', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 32),
                        FilledButton(onPressed: () => context.go('/dashboard/cliente'), child: const Text('Ir al inicio')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: 'failure',
            name: 'pos_pay_failure',
            builder: (context, state) {
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 80, color: Colors.red.shade300),
                        const SizedBox(height: 24),
                        Text('Pago no realizado', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('Puedes intentar de nuevo escaneando el QR en la tienda.', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 32),
                        FilledButton(onPressed: () => context.go('/dashboard/cliente'), child: const Text('Ir al inicio')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // === Legales / estáticas (paridad Angular) ===
      GoRoute(
        path: '/aviso-de-privacidad',
        name: 'aviso_privacidad',
        builder: (context, state) => const StaticLegalPage(
          title: 'Aviso de Privacidad',
          content: _legalAvisoPrivacidad,
        ),
      ),
      GoRoute(
        path: '/terminos-y-condiciones',
        name: 'terminos_condiciones',
        builder: (context, state) => const StaticLegalPage(
          title: 'Términos y Condiciones',
          content: _legalTerminos,
        ),
      ),
      GoRoute(
        path: '/politica-cookies',
        name: 'politica_cookies',
        builder: (context, state) => const StaticLegalPage(
          title: 'Política de Cookies',
          content: _legalCookies,
        ),
      ),
      GoRoute(
        path: '/acerca-de',
        name: 'acerca_de',
        builder: (context, state) => const StaticLegalPage(
          title: 'Acerca de',
          content: _legalAcercaDe,
        ),
      ),
      GoRoute(
        path: '/contacto',
        name: 'contacto',
        builder: (context, state) => const StaticLegalPage(
          title: 'Contacto',
          content: _legalContacto,
        ),
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
    errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
  );
}

const String _legalAvisoPrivacidad = '''
En cumplimiento con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares, Mapper.digital informa que los datos personales que nos proporcione serán utilizados para la prestación de servicios de entrega y logística, gestión de pedidos, atención al cliente y comunicación relacionada con su cuenta.

Usted puede ejercer sus derechos de acceso, rectificación, cancelación u oposición contactando a nuestro responsable de datos. Para más información consulte nuestra política completa en la web.
''';

const String _legalTerminos = '''
Al utilizar la plataforma Mapper.digital usted acepta estos términos y condiciones. El servicio permite solicitar servicios de entrega y realizar pedidos a tiendas asociadas. Es responsabilidad del usuario proporcionar información veraz y mantener la confidencialidad de su cuenta.

Mapper.digital se reserva el derecho de modificar estos términos. El uso continuado del servicio tras cambios constituye aceptación de los nuevos términos.
''';

const String _legalCookies = '''
Esta plataforma utiliza cookies y tecnologías similares para mejorar la experiencia del usuario, analizar el uso del servicio y personalizar contenido. Puede configurar su navegador para rechazar cookies, teniendo en cuenta que algunas funciones podrían no estar disponibles.
''';

const String _legalAcercaDe = '''
Mapper.digital es una plataforma de servicios de entrega y pedidos que conecta a clientes con prestadores y tiendas. Nuestra misión es facilitar la logística y el comercio local con tecnología sencilla y confiable.
''';

const String _legalContacto = '''
Para soporte, sugerencias o reportar incidencias puede contactarnos por:\n\n• Email: soporte@mapper.digital\n• Desde la app: sección Ayuda en Mi Perfil
''';
