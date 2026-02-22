# Servicio de Navegación Centralizado

## 📋 Resumen

El `NavigationService` es un servicio singleton que centraliza toda la navegación de la aplicación, eliminando la necesidad de hardcodear rutas en múltiples lugares y reduciendo errores como paths incorrectos.

## ✅ Ventajas

1. **Evita errores de tipeo** - Las rutas están centralizadas en un solo lugar
2. **Autocompletado** - IDE sugiere métodos de navegación disponibles
3. **Refactorización fácil** - Cambiar una ruta solo requiere editar el servicio
4. **Type-safe** - Los parámetros requeridos están definidos en los métodos
5. **Documentación implícita** - Los métodos documentan qué flujos existen

## 🚀 Uso Básico

### Importar el servicio

```dart
import '../../../../core/services/navigation_service.dart';
```

### Navegación simple

```dart
// En lugar de:
context.go('/dashboard/cliente');

// Usar:
navigationService.goToClientDashboard(context);
```

### Navegación con parámetros

```dart
// En lugar de:
context.push('/requests/$requestId');

// Usar:
navigationService.goToRequestDetail(context, requestId);
```

### Navegación con datos extra

```dart
// En lugar de:
context.push('/cliente/catalog/$storeId/checkout', extra: {
  'storeId': storeId,
  'storeName': storeName,
  'cart': cart,
});

// Usar:
navigationService.goToClientCheckout(
  context,
  storeId,
  storeName: storeName,
  cart: cart,
);
```

## 📚 Métodos Disponibles

### Autenticación

- `goToLogin(context)` - Ir a login
- `goToRegister(context)` - Ir a registro
- `goToForgotPassword(context)` - Ir a recuperar contraseña

### Cliente

- `goToClientDashboard(context)` - Dashboard principal del cliente
- `goToClientRequests(context)` - Lista de solicitudes
- `goToNewRequest(context)` - Crear nueva solicitud
- `goToRequestDetail(context, requestId)` - Detalle de solicitud
- `goToRequestTracking(context, requestId)` - Tracking de solicitud
- `goToClientTracking(context)` - Tracking general
- `goToClientCatalog(context, storeId)` - Catálogo de tienda
- `goToClientCheckout(context, storeId, storeName, cart)` - Proceso de checkout
- `goToOrderConfirmation(context, orderId, storeName, total, deliveryFee, status)` - Confirmación de orden
- `goToStoreOrderDetail(context, orderId)` - Detalle de orden de tienda
- `goToProfile(context)` - Perfil del usuario

### Proveedor

- `goToProviderDashboard(context)` - Dashboard del proveedor
- `goToBolsaTrabajo(context)` - Bolsa de trabajo
- `goToProviderRequests(context)` - Solicitudes del proveedor
- `goToProviderSubscriptions(context)` - Suscripciones  
- `goToProviderPOS(context)` - POS del proveedor

### Tienda

- `goToStorePOS(context)` - POS de la tienda
- `goToStoreCatalog(context)` - Catálogo de la tienda
- `goToStoreOrders(context)` - Órdenes de la tienda
- `goToStoreMore(context)` - Más opciones de la tienda

### Otros

- `goToAuctions(context)` - Subastas
- `goToVehicles(context)` - Vehículos
- `goToOrders(context)` - Órdenes

### Helpers de Navegación

- `goBack(context)` - Navegar hacia atrás (solo si es posible)
- `replace(context, path, extra)` - Reemplazar ruta actual
- `goAndClearUntil(context, path)` - Navegar y limpiar el stack

## 🔧 Agregar Nuevas Rutas

Cuando necesites agregar una nueva ruta:

1. **Agregar el método en `navigation_service.dart`**:

```dart
void goToNewFeature(BuildContext context, String id) {
  context.push('/new-feature/$id');
}
```

2. **Usar el método en tus páginas**:

```dart
navigationService.goToNewFeature(context, featureId);
```

## 📝 Ejemplos de Migración

### Antes

```dart
class MyPage extends StatelessWidget {
  void _handleButtonPress(BuildContext context) {
    context.push('/cliente/catalog/${storeId}/checkout', extra: {
      'storeId': storeId,
      'storeName': storeName,
      'cart': cart,
    });
  }
}
```

### Después

```dart
import '../../../../core/services/navigation_service.dart';

class MyPage extends StatelessWidget {
  void _handleButtonPress(BuildContext context) {
    navigationService.goToClientCheckout(
      context,
      storeId,
      storeName: storeName,
      cart: cart,
    );
  }
}
```

## ⚠️ Errores Comunes Resueltos

### 1. Path incorrecto
**Antes**: `context.push('/client/catalog/...')` vs `/cliente/catalog/...`  
**Después**: `navigationService.goToClientCheckout(...)` - siempre correcto

### 2. Parámetros faltantes
**Antes**: Olvidas pasar `extra` y la app crashea  
**Después**: Los parámetros requeridos están en la firma del método

### 3. Rutas duplicadas
**Antes**: La misma ruta escrita diferente en varios lugares  
**Después**: Una sola fuente de verdad

## 🎯 Best Practices

1. **Siempre usar NavigationService** - No uses `context.go()` o `context.push()` directamente
2. **Nombrar métodos descriptivamente** - `goToClientCheckout` es mejor que `navigateToCheckout`
3. **Agrupar por módulo** - Mantén los métodos organizados por feature (Auth, Client, Provider, etc.)
4. **Documentar parámetros complejos** - Si un método recibe muchos parámetros, agregar comentarios

## 🔄 Acceso Global

El servicio está disponible globalmente:

```dart
// Opción 1: Crear instancia (singleton)
final nav = NavigationService();
nav.goToClientDashboard(context);

// Opción 2: Usar instancia global
navigationService.goToClientDashboard(context);
```

Ambas opciones son equivalentes porque es un singleton.

## 📄 Ubicación del Archivo

```
lib/
  core/
    services/
      navigation_service.dart  <-- El servicio
```

## 🧪 Testing

Para testear navegación:

```dart
// Mock del NavigationService en tests
final mockNav = MockNavigationService();

// Verificar que se llamó el método correcto
verify(mockNav.goToClientDashboard(any)).called(1);
```
