# Arquitectura del Proyecto Mapper

## 📋 Descripción General

Mapper es una aplicación de delivery construida con Flutter siguiendo las mejores prácticas de desarrollo moderno. La arquitectura se basa en una organización por features con separación clara de responsabilidades.

## 🏗️ Estructura del Proyecto

### Core (Núcleo)
Contiene toda la funcionalidad compartida y transversal de la aplicación:

#### `core/constants/`
- **app_constants.dart**: Constantes globales de la aplicación
  - Información de la app (nombre, versión)
  - Configuración de API (URLs, timeouts)
  - Claves de almacenamiento
  - Estados de delivery

#### `core/router/`
- **app_router.dart**: Configuración de navegación usando GoRouter
  - Rutas declarativas
  - Navegación type-safe
  - Deep linking preparado

#### `core/theme/`
- **app_theme.dart**: Sistema de temas de la aplicación
  - Tema claro y oscuro
  - Material Design 3
  - Colores personalizados
  - Tipografía con Google Fonts
  - Componentes customizados

#### `core/utils/`
- Utilidades y helpers (preparado para futuras implementaciones)

### Features (Funcionalidades)

Cada feature sigue la arquitectura limpia:

#### `features/home/`
**Pantalla principal de la aplicación**
- Quick actions (acciones rápidas)
- Lista de pedidos recientes
- Navegación por tabs
- Dashboard del usuario

**Componentes:**
- `HomePage`: Widget principal con navegación por tabs
- `_HomeContent`: Contenido de la pestaña home
- `_QuickActionCard`: Cards de acciones rápidas
- `_OrdersContent`: Vista de órdenes
- `_ProfileContent`: Vista de perfil

#### `features/orders/`
**Gestión de pedidos**
- Lista de todos los pedidos
- Estados de pedidos (Entregado, En Progreso, Pendiente)
- Detalles de cada pedido
- Historial completo

**Componentes:**
- `OrdersPage`: Lista completa de órdenes con cards

#### `features/profile/`
**Perfil del usuario**
- Información personal
- Configuraciones
- Direcciones
- Métodos de pago
- Soporte y ayuda

**Componentes:**
- `ProfilePage`: Página de perfil con menú de opciones
- `_ProfileMenuItem`: Item de menú reutilizable

### Shared (Compartido)
- `widgets/`: Widgets reutilizables entre features (preparado para futuras implementaciones)

## 🎨 Sistema de Diseño

### Temas
- **Modo claro**: Diseño limpio con fondo blanco
- **Modo oscuro**: Diseño optimizado para condiciones de baja luz
- **Adaptación automática**: Sigue las preferencias del sistema

### Colores
- **Primary**: #2196F3 (Azul)
- **Secondary**: #FF9800 (Naranja)
- **Background**: #F5F5F5 (Gris claro)
- **Surface**: Blanco
- **Error**: #D32F2F (Rojo)

### Tipografía
- Fuente: **Poppins** (via Google Fonts)
- Pesos: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 📦 Dependencias Principales

### Producción
- **flutter_bloc (^8.1.3)**: Gestión de estado
- **equatable (^2.0.5)**: Comparación de objetos
- **go_router (^13.0.0)**: Navegación
- **dio (^5.4.0)**: Cliente HTTP
- **shared_preferences (^2.2.2)**: Almacenamiento local
- **google_fonts (^6.1.0)**: Tipografías
- **intl (^0.19.0)**: Internacionalización y formato
- **logger (^2.0.2+1)**: Logging

### Desarrollo
- **flutter_lints (^3.0.0)**: Reglas de análisis
- **bloc_test (^9.1.5)**: Testing de BLoCs
- **mocktail (^1.0.2)**: Mocking para tests

## 🔄 Flujo de Navegación

```
/ (Home)
├── Tab 1: Home Content
│   ├── Quick Actions
│   └── Recent Orders
├── Tab 2: Orders List
│   └── All Orders
└── Tab 3: Profile
    └── User Settings
```

## 📱 Compatibilidad

### Android
- API mínima: 21 (Android 5.0)
- API objetivo: 34 (Android 14)
- Gradle: 8.3
- Kotlin: 1.9.0

### iOS
- Versión mínima: 12.0
- Swift nativo

## 🚀 Próximos Pasos

### Backend Integration
1. Implementar servicios API con Dio
2. Agregar modelos de datos
3. Implementar capa de dominio
4. Agregar repositorios

### State Management
1. Crear BLoCs para cada feature
2. Implementar eventos y estados
3. Manejar loading/error states

### Features Adicionales
1. Sistema de autenticación
2. Mapas y geolocalización
3. Notificaciones push
4. Sistema de pagos
5. Chat con repartidor
6. Valoraciones y reviews

### Testing
1. Unit tests para lógica de negocio
2. Widget tests para UI
3. Integration tests
4. Golden tests para diseño

## 📝 Convenciones de Código

- Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Usar `const` constructors cuando sea posible
- Preferir `final` sobre `var`
- Single quotes para strings
- Documentar funciones públicas
- Mantener widgets pequeños y enfocados

## 🔒 Seguridad

- No se encontraron vulnerabilidades en las dependencias
- Análisis de seguridad CodeQL: Limpio
- Todas las dependencias están actualizadas

## 📚 Recursos

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)
