# Liquid Glass Navigation Components

Componentes de navegación con diseño Liquid Glass para Flutter, homologados con la versión Angular.

## Componentes Creados

### 1. LiquidGlassAppBar
Top bar con botones de notificaciones y menú, posicionado en la esquina superior derecha.

**Características:**
- Botón de notificaciones con badge contador
- Botón de menú hamburguesa
- Diseño transparente con iconos flotantes
- Respeta SafeArea (iOS/Android)

### 2. LiquidGlassDrawer
Drawer lateral desde la derecha con efecto de vidrio.

**Características:**
- Animación de slide desde la derecha
- Backdrop blur con overlay oscuro
- Lista de items de menú con iconos
- Estilo especial para botón de logout (rojo)
- Soporta header con nombre de usuario

### 3. LiquidGlassBottomNav
Barra de navegación inferior con diseño Liquid Glass.

**Características:**
- Indicador de tab activo (línea superior)
- Iconos con labels
- Backdrop blur
- Responsive (se oculta en desktop si `mobileOnly: true`)
- Scroll horizontal en caso de muchos tabs

### 4. LiquidGlassScaffold
Scaffold completo que combina todos los componentes.

**Características:**
- Background con orbes animados
- AppBar integrado
- Drawer integrado
- Bottom navigation integrado
- Padding automático para evitar overlaps

## Configuración por Rol

### BottomNavConfig
Define los tabs de navegación inferior para cada rol:
- **Cliente**: Inicio, Solicitudes, Tracking, Subastas, Perfil
- **Prestador**: Inicio, POS, Bolsa, Subastas, Vehículos, Perfil
- **Tienda**: POS, Catálogo, Pedidos, Más, Perfil

### DrawerMenuConfig
Define los items del menú lateral para cada rol:
- **Cliente**: Nueva solicitud, Mis solicitudes, Tracking, Subastas, Perfil, Refrescar, Cerrar sesión
- **Prestador**: Inicio, POS, Bolsa, Subastas, Vehículos, Ganancias, Perfil, Refrescar, Cerrar sesión
- **Tienda**: POS, Catálogo, Pedidos, Efectivo, Turnos, Libro, Perfil, Refrescar, Cerrar sesión

## Uso Básico

### Ejemplo Simple con LiquidGlassScaffold

```dart
import 'package:flutter/material.dart';
import 'package:mapper/core/widgets/liquid_glass_scaffold.dart';
import 'package:mapper/core/config/bottom_nav_config.dart';
import 'package:mapper/core/config/drawer_menu_config.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _currentIndex = 0;
  bool _showNotifications = false;

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    // Navigate to corresponding route
    final items = BottomNavConfig.getBottomNavItems('cliente');
    Navigator.pushNamed(context, items[index].route);
  }

  void _onLogout() {
    // Implement logout logic
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onRefresh() {
    // Implement refresh logic
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hola, Usuario',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona tus solicitudes y servicios',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          // Your content here
          Expanded(
            child: Center(
              child: Text(
                'Contenido de la página',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavItems: BottomNavConfig.getBottomNavItems('cliente'),
      currentBottomNavIndex: _currentIndex,
      onBottomNavTap: _onBottomNavTap,
      drawerMenuItems: DrawerMenuConfig.getDrawerMenuItems(
        role: 'cliente',
        onLogout: _onLogout,
        onRefresh: _onRefresh,
      ),
      userName: 'Juan Pérez',
      userRole: 'cliente',
      unreadNotifications: 3,
      onNotificationTap: () {
        setState(() => _showNotifications = !_showNotifications);
      },
    );
  }
}
```

### Ejemplo con Componentes Individuales

```dart
import 'package:flutter/material.dart';
import 'package:mapper/core/widgets/liquid_glass_background.dart';
import 'package:mapper/core/widgets/liquid_glass_app_bar.dart';
import 'package:mapper/core/widgets/liquid_glass_drawer.dart';
import 'package:mapper/core/widgets/liquid_glass_bottom_nav.dart';

class CustomDashboard extends StatefulWidget {
  const CustomDashboard({super.key});

  @override
  State<CustomDashboard> createState() => _CustomDashboardState();
}

class _CustomDashboardState extends State<CustomDashboard> {
  bool _drawerOpen = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          LiquidGlassBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 60,
                  bottom: 80,
                ),
                child: YourContent(),
              ),
            ),
          ),

          // Top Bar
          LiquidGlassAppBar(
            onNotificationTap: () {
              // Handle notification tap
            },
            onMenuTap: () {
              setState(() => _drawerOpen = !_drawerOpen);
            },
            unreadCount: 5,
          ),

          // Drawer
          LiquidGlassDrawer(
            isOpen: _drawerOpen,
            onClose: () => setState(() => _drawerOpen = false),
            menuItems: [
              DrawerMenuItem(
                label: 'Inicio',
                icon: Icons.home,
                route: '/home',
              ),
              DrawerMenuItem(
                label: 'Perfil',
                icon: Icons.person,
                route: '/profile',
              ),
              DrawerMenuItem(
                label: 'Cerrar sesión',
                icon: Icons.logout,
                onTap: () {
                  // Logout logic
                },
                isLogout: true,
              ),
            ],
            userName: 'Usuario',
          ),
        ],
      ),
      bottomNavigationBar: LiquidGlassBottomNav(
        items: const [
          BottomNavItem(
            label: 'Inicio',
            icon: Icons.home,
            route: '/home',
          ),
          BottomNavItem(
            label: 'Buscar',
            icon: Icons.search,
            route: '/search',
          ),
          BottomNavItem(
            label: 'Perfil',
            icon: Icons.person,
            route: '/profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
```

## Personalización

### Desactivar Componentes

```dart
LiquidGlassScaffold(
  body: YourContent(),
  showAppBar: false,      // Ocultar top bar
  showDrawer: false,      // Ocultar drawer
  showBottomNav: false,   // Ocultar bottom nav
  showOrbs: false,        // Ocultar orbes animados
)
```

### Padding Personalizado

```dart
LiquidGlassScaffold(
  body: YourContent(),
  padding: EdgeInsets.all(16), // Padding custom
)
```

### Bottom Nav Solo en Móvil

```dart
LiquidGlassBottomNav(
  items: items,
  currentIndex: 0,
  onTap: onTap,
  mobileOnly: true, // Se oculta en desktop (>768px)
)
```

## Diseño Visual

### Colores
- **Background gradient**: `#0b1020` → `#0f172a` → `#111827`
- **Orbe cyan**: `#06b6d4` @ 18% opacity
- **Orbe orange**: `#f97316` @ 20% opacity
- **Glass fill**: white @ 8-12% opacity
- **Glass border**: white @ 10-12% opacity
- **Active tab**: `#22d3ee` (cyan-400)
- **Inactive text**: white @ 65% opacity
- **Logout button**: `#fca5a5` (red-300)

### Efectos
- **Backdrop blur**: 20px
- **Drawer shadow**: 32px blur, -4px offset
- **Bottom nav shadow**: 24px blur, -4px offset
- **Active tab scale**: 1.05x
- **Drawer animation**: 250ms ease-out
- **Backdrop fade**: 200ms ease-out

## Integración con GoRouter

```dart
// Define routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/client/home',
      builder: (context, state) => const ClientHomePage(),
    ),
    GoRoute(
      path: '/client/requests',
      builder: (context, state) => const RequestsPage(),
    ),
    // ... más rutas
  ],
);

// En main.dart
MaterialApp.router(
  routerConfig: router,
  // ...
)
```

## Notas Importantes

1. **SafeArea**: Los componentes respetan las safe areas de iOS/Android
2. **Responsive**: Bottom nav se oculta en desktop si `mobileOnly: true`
3. **Animaciones**: Suaves y optimizadas (250ms drawer, 200ms backdrop)
4. **Accessibility**: Icons tienen `aria-hidden` equivalente, labels descriptivos
5. **Performance**: Backdrop filter puede ser costoso en algunos dispositivos

## Migración desde TropicalScaffold

Si estabas usando `TropicalScaffold`, reemplázalo con:

```dart
// Antes
TropicalScaffold(
  appBar: AppBar(title: Text('Title')),
  body: Content(),
)

// Después
LiquidGlassScaffold(
  body: Column(
    children: [
      Text('Title', style: TextStyle(color: Colors.white, fontSize: 24)),
      Content(),
    ],
  ),
  // ... configuración de navegación
)
```
