# ✅ Checklist de Ejecución - Flujo Cliente Mapper

**Estado:** Sprint Homologación  
**Fecha:** 22 Febrero 2026  
**Build Status:** ✅ Compilando  
**Última Actualización:** Commit `e246193`

---

## 📌 Priorización Global

```
PRIORITY 1 (CRÍTICO - Bloquea demo):
├── UI Homologación completitud
├── Validaciones de entrada
└── Manejo de errores visible

PRIORITY 2 (ALTO - Mejora experiencia):
├── Persistencia carrito
├── Real-time tracking
└── Notificaciones

PRIORITY 3 (MEDIO - Polish):
├── Animaciones suave
├── Accessibility
└── Performance
```

---

## 🎯 SPRINT 1: Carrito Persistencia & Checkout

### 1.1 Carrito: LocalStorage Persistencia

**Objetivo:** Guardar carrito en navegador, cargar al entrar

**Tareas:**
- [ ] **T1.1.1** Crear `CartService` con métodos:
  - `Future<void> saveCart(Map<String, dynamic> cart)` → JSON localStorage
  - `Future<Map<String, dynamic>> loadCart()` → deserializar
  - `Future<void> clearCart()` → limpiar
  
- [ ] **T1.1.2** En `ClientCatalogPage.initState()`:
  - Llamar `_loadCartFromStorage()` en initState
  - Restaurar `_cart` y `_cartItemCount` si existen
  - Mostrar toast: "Retomando carrito anterior"

- [ ] **T1.1.3** En `_showAddToCartDialog`:
  - Después de "Agregar", llamar `_saveCartToStorage()`
  - Similar en eliminar items

- [ ] **T1.1.4** En `_showCartSummary` al eliminar:
  - Guardar cambios a storage
  - Actualizar badge header

**Archivos a Modificar:**
- `lib/core/services/cart_service.dart` (CREAR)
- `lib/features/client/presentation/pages/client_catalog_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 150-200

**Status:** ⏳ No iniciado

---

### 1.2 Carrito: Expiración & Recovery

**Objetivo:** Notificar si carrito expiró (>24h) y permitir recuperar

**Tareas:**
- [ ] **T1.2.1** En `CartService.loadCart()`:
  - Verificar timestamp: `DateTime.parse(cart['timestamp'])`
  - Si > 24h: retornar null + guardar para recovery
  - Si vigente: retornar

- [ ] **T1.2.2** En `ClientCatalogPage`:
  - Si `_loadCartFromStorage()` retorna null pero hay recovery:
    - Mostrar dialog: "Tienes un carrito antiguo de hace 2 días, ¿Recuperar?"
    - Botones: "Recuperar", "Descartar"
  - Si Recuperar: restaurar _cart, mostrar toast éxito
  - Si Descartar: limpiar recovery

**Archivos a Modificar:**
- `lib/core/services/cart_service.dart` (ACTUALIZAR)
- `lib/features/client/presentation/pages/client_catalog_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 80-120

**Status:** ⏳ No iniciado

---

### 1.3 Checkout: Crear Orden desde Carrito

**Objetivo:** Pasar carrito a orden en backend

**Tareas:**
- [ ] **T1.3.1** Crear modelo `StoreOrder`:
  ```dart
  class StoreOrder {
    final String id;
    final String storeId;
    final String clientId;
    final Map<String, dynamic> items; // {productId: qty}
    final double total;
    final String status; // pending, accepted, etc
    final DateTime createdAt;
  }
  ```

- [ ] **T1.3.2** Crear `OrderRepository`:
  - `Future<StoreOrder> createOrder(String storeId, Map<String, dynamic> items, double total)`
  - POST `/stores/:storeId/orders`
  - Body: `{items: {}, total: 0.0, notes: ""}`

- [ ] **T1.3.3** En `ClientCatalogPage._checkoutCart()`:
  - Cambiar stub message por lógica real
  - Obtener `storeId` del widget
  - Llamar `_orderRepository.createOrder(storeId, _cart, total)`
  - Loading spinner mientras POST
  - Success: mostrar dialog resultado
    - "Orden #{orderId} creada exitosamente"
    - Botones: "Ir a Mi Carrito", "Continuar comprando"
  - Error: mostrar mensaje + reintentar

- [ ] **T1.3.4** En success del checkout:
  - Limpiar carrito: `_cart.clear()`, `_cartItemCount = 0`
  - Limpiar storage
  - Navegar a `RequestsPage` con highlight nueva orden
  - SnackBar verde: "Orden creada, verás en 'Mis Solicitudes'"

**Archivos a Crear/Modificar:**
- `lib/features/client/domain/models/store_order_model.dart` (CREAR)
- `lib/features/client/domain/repositories/order_repository.dart` (CREAR)
- `lib/features/client/presentation/pages/client_catalog_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 250-300

**Status:** ⏳ No iniciado

---

### 1.4 Orden: Detalle de Tienda (StoreOrderDetailPage)

**Objetivo:** Ver detalles específicos de orden en tienda

**Tareas:**
- [ ] **T1.4.1** Crear página `StoreOrderDetailPage`:
  - Route: `/cliente/store-order/:orderId`
  - GET `/stores/:storeId/orders/:orderId`
  - Mostrar:
    - ID orden
    - Items con cantidades y precios
    - Total
    - Estado (badge de color)
    - Timestamp creación
    - Notas

- [ ] **T1.4.2** Botones de acción:
  - Si estado `pending`: "Cancelar Orden" → dialog confirmación
  - Si estado `accepted`: "Ver detalles"
  - Si estado `completed`: "Reordenar" → pre-llena carrito

- [ ] **T1.4.3** Header con:
  - Back button
  - Icono compartir (copy link)
  - Menú acciones (...)

**Archivos a Crear:**
- `lib/features/client/presentation/pages/store_order_detail_page.dart`

**Líneas Estimadas:** 200-250

**Status:** ⏳ No iniciado

---

## 🎯 SPRINT 2: Perfil Mejoras

### 2.1 Profile: Direcciones CRUD Completo

**Objetivo:** ABM de direcciones guardadas con mapa

**Tareas:**
- [ ] **T2.1.1** Expandir panel "Direcciones":
  - Lista de direcciones guardadas (GET `/auth/saved-addresses`)
  - Card por dirección: nombre, dirección completa, botón editar, botón eliminar
  - Botón "+ Agregar Nueva Dirección"

- [ ] **T2.1.2** Dialog Agregar/Editar Dirección:
  - Campos: nombre (ej: "Casa"), dirección completa
  - Botón "Usar Mi Ubicación" → geoloc + address lookup
  - Botón "Seleccionar en Mapa" → abre mini mapa flotante
  - Validación: nombre min 2 chars, dirección no vacía

- [ ] **T2.1.3** Confirmación Eliminar:
  - Dialog: "¿Eliminar dirección 'Casa'?"
  - Botones: "Cancelar", "Eliminar"
  - DELETE `/auth/saved-addresses/:id`
  - Success: toast + reload lista

- [ ] **T2.1.4** Guardar dirección:
  - POST `/auth/saved-addresses` (nueva)
  - PUT `/auth/saved-addresses/:id` (editar)
  - Success: toast + close dialog + update lista

**Archivos a Modificar:**
- `lib/features/profile/presentation/pages/profile_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 300-400

**Status:** ⏳ No iniciado

---

### 2.2 Profile: Preferencias & Settings

**Objetivo:** Panel de configuración completo

**Tareas:**
- [ ] **T2.2.1** En panel "Configuración":
  - Toggle "Notificaciones habilitadas" (PUT `/auth/settings`)
  - Toggle "Mensajes de marketing"
  - Select "Idioma" (ES, EN, PT)
  - Select "Tema" (Dark, Light - mock por ahora)
  - Botón "Eliminar Cuenta" rojo

- [ ] **T2.2.2** Confirmación Eliminar Cuenta:
  - Dialog: "¿Estás seguro? Se borrarán todos tus datos."
  - Requerido ingresar contraseña para confirmar
  - POST `/auth/delete-account` con password
  - Success: logout + redirect login
  - Error: "Contraseña incorrecta"

- [ ] **T2.2.3** Guardar settings:
  - PUT `/auth/settings`
  - Toast confirmación
  - Persistir en localStorage (offline-first)

**Archivos a Modificar:**
- `lib/features/profile/presentation/pages/profile_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 150-200

**Status:** ⏳ No iniciado

---

## 🎯 SPRINT 3: Validaciones & Error Handling

### 3.1 Validación Global: Campos de Entrada

**Objetivo:** Validadores reutilizables en toda la app

**Tareas:**
- [ ] **T3.1.1** Crear `lib/core/validators/input_validators.dart`:
  ```dart
  class InputValidators {
    static String? validateName(String? value) {
      if (value == null || value.isEmpty) return 'Requerido';
      if (value.length < 2) return 'Mín 2 caracteres';
      if (value.length > 100) return 'Máx 100 caracteres';
      return null;
    }
    
    static String? validatePhone(String? value) {
      if (value == null || value.isEmpty) return null; // Optional
      if (value.length < 10) return 'Mín 10 dígitos';
      if (value.length > 15) return 'Máx 15 dígitos';
      if (!RegExp(r'^[0-9\-+\s()]*$').hasMatch(value)) return 'Formato inválido';
      return null;
    }
    
    static String? validatePassword(String? value) {
      if (value == null || value.isEmpty) return 'Requerido';
      if (value.length < 6) return 'Mín 6 caracteres';
      return null;
    }
    
    static String? validateEmail(String? value) {
      if (value == null || value.isEmpty) return 'Requerido';
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Email inválido';
      return null;
    }
    
    static String? validatePostalCode(String? value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^\d{5}$').hasMatch(value)) return '5 dígitos requeridos';
      return null;
    }
    
    static String? validateQuantity(int value) {
      if (value <= 0) return 'Mín 1';
      if (value > 999) return 'Máx 999';
      return null;
    }
    
    static String? validateNotes(String? value) {
      if (value == null) return null;
      if (value.length > 500) return 'Máx 500 caracteres';
      return null;
    }
  }
  ```

- [ ] **T3.1.2** Aplicar validadores en:
  - `ProfilePage` (nombre, teléfono, código postal)
  - `NewRequestPage` (notas)
  - `CartDialog` (cantidad)
  - `ChangePasswordDialog` (contraseña, confirmación)

- [ ] **T3.1.3** Mostrar mensajes de error:
  - Below cada input
  - Color rojo (#ec4146)
  - Tamaño 12px
  - Max 1 línea con ellipsis

**Archivos a Crear/Modificar:**
- `lib/core/validators/input_validators.dart` (CREAR)
- Varios pages .dart (ACTUALIZAR)

**Líneas Estimadas:** 200 validators + 300 aplicación

**Status:** ⏳ No iniciado

---

### 3.2 Error Handling: Mensajes Consistentes

**Objetivo:** UX uniforme para errores

**Tareas:**
- [ ] **T3.2.1** Crear `lib/core/utils/error_handler.dart`:
  ```dart
  class ErrorHandler {
    static String getErrorMessage(dynamic error) {
      if (error is DioException) {
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            return 'Conexión lenta. Intenta en unos momentos.';
          case DioExceptionType.sendTimeout:
            return 'Envío lento. Verifica tu conexión.';
          case DioExceptionType.receiveTimeout:
            return 'Servidor lento. Intenta más tarde.';
          case DioExceptionType.badResponse:
            return _handleBadResponse(error.response?.statusCode ?? 500,
              error.response?.data);
          default:
            return 'Error desconocido. Intenta nuevamente.';
        }
      }
      return 'Error. Por favor intenta nuevamente.';
    }
    
    static String _handleBadResponse(int statusCode, dynamic data) {
      switch (statusCode) {
        case 400:
          return data?['message'] ?? 'Datos inválidos';
        case 401:
          return 'Sesión expirada. Por favor inicia sesión.';
        case 403:
          return 'No tienes permiso para hacer esto.';
        case 404:
          return 'El recurso no existe o fue eliminado.';
        case 500:
        case 502:
        case 503:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return 'Error $statusCode: Intenta nuevamente.';
      }
    }
  }
  ```

- [ ] **T3.2.2** Usar en todas las páginas:
  - Try-catch en _load(), POST, etc
  - Capturar error con `ErrorHandler.getErrorMessage(e)`
  - Mostrar SnackBar rojo con mensaje
  - Mantener estado cargable para reintentar

- [ ] **T3.2.3** Implementar en:
  - ClientDashboardPage (tiendas)
  - ClientCatalogPage (productos)
  - NewRequestPage (categorías, submit)
  - ProfilePage (load profile, update, change password)
  - RequestsPage (listar)

**Archivos a Crear/Modificar:**
- `lib/core/utils/error_handler.dart` (CREAR)
- Varios pages .dart (ACTUALIZAR)

**Líneas Estimadas:** 100 handler + 200 aplicación

**Status:** ⏳ No iniciado

---

### 3.3 Error Handling: Retry Buttons

**Objetivo:** UI clara con opciones de reintentar

**Tareas:**
- [ ] **T3.3.1** Creating error widget reutilizable:
  ```dart
  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(error, 
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  ```

- [ ] **T3.3.2** Aplicar en páginas con estado:
  - `_error != null ? _buildErrorState(_error, _load) : _buildContent()`
  - En lugar de Center message actual

**Archivos a Modificar:**
- Varios pages .dart (ACTUALIZAR)

**Líneas Estimadas:** 50-100

**Status:** ⏳ No iniciado

---

## 🎯 SPRINT 4: Real-Time Tracking & WebSocket

### 4.1 Tracking: WebSocket Real-time

**Objetivo:** Ubicación en vivo del prestador

**Tareas:**
- [ ] **T4.1.1** En `ClientTrackingPage._setupSocketListeners()`:
  - Join room: `_socketService.joinTrackingRoom(_mockRequestId)`
  - Listen provider location:
    ```dart
    _socketService.on('provider_location', (data) {
      setState(() {
        _providerLocation = LocationCoordinates(...);
        _calculateDistance();
        _updateMapMarker();
      });
    });
    ```
  - Listen status change:
    ```dart
    _socketService.on('request_status_changed', (data) {
      setState(() {
        _requestStatus = data['status'];
        _showStatusNotification();
      });
    });
    ```

- [ ] **T4.1.2** Actualizar distancia en tiempo real:
  - `_calculateDistance()` usa Haversine formula
  - Actualiza cada vez que llega location event
  - Muestra en UI: "Distancia: 2.4 km"

- [ ] **T4.1.3** Mapa dinámico:
  - Marca azul (usuario) fija
  - Marca roja (prestador) actualiza
  - Línea ruta entre ellos
  - Zoom automático para ambos

- [ ] **T4.1.4** En dispose:
  - `_socketService.leaveTrackingRoom(_mockRequestId)`
  - `_locationSubscription?.cancel()`

**Archivos a Modificar:**
- `lib/features/client/presentation/pages/client_tracking_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 150-200

**Status:** ⏳ No iniciado

---

### 4.2 Tracking: Notificaciones Estado

**Objetivo:** Avisar cambios en tiempo real

**Tareas:**
- [ ] **T4.2.1** Crear modelos para eventos:
  ```dart
  class TrackingEvent {
    final String type; // 'location', 'status', 'eta', 'arrival'
    final dynamic data;
    final DateTime timestamp;
  }
  ```

- [ ] **T4.2.2** En tracking page:
  - Listen `provider_arrived`: mostrar snackbar verde
  - Listen `provider_delayed`: mostrar snackbar naranja + new ETA
  - Listen `provider_cancelled`: mostrar dialog rojo

- [ ] **T4.2.3** Actualizar ETA dinámicamente:
  - WebSocket envía `eta_minutes: int`
  - Mostrar: "ETA: 5 minutos"
  - Actualizar cada vez que llega

**Archivos a Modificar:**
- `lib/features/client/presentation/pages/client_tracking_page.dart` (ACTUALIZAR)

**Líneas Estimadas:** 80-120

**Status:** ⏳ No iniciado

---

## 🎯 SPRINT 5: Notificaciones Push (Opcional - Phase 2)

### 5.1 Notificaciones: Capturar FCM Token

**Objetivo:** Registrar usuario para push notifications

**Tareas:**
- [ ] **T5.1.1** En splash o después de login:
  - `FirebaseMessaging _messaging = FirebaseMessaging.instance;`
  - `String? token = await _messaging.getToken();`
  - POST `/auth/fcm-token` con token
  - Guardar en localStorage de respaldo

- [ ] **T5.1.2** Escuchar cambios de token:
  ```dart
  _messaging.onTokenRefresh.listen((newToken) {
    POST `/auth/fcm-token` con newToken
  });
  ```

**Archivos a Modificar:**
- `lib/main.dart` o splash
- Auth service

**Líneas Estimadas:** 50-80

**Status:** ⏳ No iniciado (Phase 2)

---

### 5.2 Notificaciones: Recibir y Mostrar

**Objetivo:** Mostrar notificaciones locales

**Tareas:**
- [ ] **T5.2.1** Setup local notifications:
  - `flutter_local_notifications` package
  - Init en main()
  - Setup notification channels

- [ ] **T5.2.2** Manejar foreground messages:
  ```dart
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);
  });
  ```

- [ ] **T5.2.3** Deep linking on tap:
  - Si `action: 'request_status'` → navigate a RequestDetailPage
  - Si `action: 'order_status'` → navigate a StoreOrderDetailPage

**Archivos a Modificar:**
- `lib/main.dart`
- `lib/core/services/notification_service.dart`

**Líneas Estimadas:** 150-200

**Status:** ⏳ No iniciado (Phase 2)

---

## 📊 Matriz de Dependencias

```
┌─────────────────────────────────────────────────┐
│ SPRINT 1: Carrito & Checkout                    │
│ ├─ T1.1: Persistencia LocalStorage             │
│ ├─ T1.2: Expiración & Recovery                 │
│ ├─ T1.3: Crear Orden (✓ DEPS: backend ready)  │
│ └─ T1.4: Ver Detalle Orden (✓ DEPS: T1.3)     │
└─────────────────────────────────────────────────┘
         │
         ↓ (después completar SPRINT 1)
┌─────────────────────────────────────────────────┐
│ SPRINT 3: Validaciones (PARALELO)               │
│ ├─ T3.1: Validadores centralizados (✓ SIN DEPS)
│ ├─ T3.2: Error Handler (✓ SIN DEPS)            │
│ └─ T3.3: Retry UI (✓ DEPS: T3.2)               │
└─────────────────────────────────────────────────┘
         │
         ↓ (aplicar en SPRINT 1 & 2)
┌─────────────────────────────────────────────────┐
│ SPRINT 2: Profile Mejoras                       │
│ ├─ T2.1: Direcciones CRUD (✓ DEPS: validadores │
│ └─ T2.2: Settings (✓ DEPS: validadores)        │
└─────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────┐
│ SPRINT 4: Tracking Real-Time (✓ SIN DEPS)      │
│ ├─ T4.1: WebSocket Live                        │
│ └─ T4.2: Notificaciones Estado                 │
└─────────────────────────────────────────────────┘
```

---

## 🗓 Cronograma Estimado

**SPRINT 1 (5-7 días)**
- Carrito persistencia: 2 días
- Carrito expiration: 1 día
- Checkout & orden: 2 días
- Testing: 1 día

**SPRINT 2 (4-5 días)** - Paralelo con SPRINT 3
- Profile direcciones: 2 días
- Settings: 1 día
- Testing: 1 día

**SPRINT 3 (2-3 días)** - Paralelo con SPRINT 2
- Validadores: 1 día
- Error handling: 1 día
- Aplicar en todas páginas: 1 día

**SPRINT 4 (3-4 días)**
- WebSocket tracking: 2 días
- Notificaciones estado: 1 día
- Testing e-2e: 1 día

**Total Estimado:** 14-19 días

---

## 🔧 Requisitos Técnicos

### Packages Nuevos Necesarios
```yaml
# Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.2.4

# Networking
dio: ^5.3.1

# Maps (ya tiene)
flutter_map: ^7.0.2

# Local notifications (para phase 2)
flutter_local_notifications: ^17.0.0
firebase_messaging: ^14.6.0

# Testing
mockito: ^5.4.0
```

### APIs Nuevas Necesarias
```
POST /stores/:storeId/orders
GET /stores/:storeId/orders/:orderId
PUT /auth/settings
DELETE /auth/delete-account
GET /auth/saved-addresses
POST /auth/saved-addresses
PUT /auth/saved-addresses/:id
DELETE /auth/saved-addresses/:id
POST /auth/fcm-token
```

### WebSocket Nuevos
```
/tracking/{requestId}
  - provider_location
  - request_status_changed
  - eta_update
  - provider_arrived
  - provider_cancelled
```

---

## ✨ Testing Checklist

### Unit Tests
```
□ InputValidators todas las funciones
□ ErrorHandler todos los status codes
□ CartService save/load/clear
□ Models serialization
```

### Widget Tests
```
□ ClientCatalogPage dialogs
□ ProfilePage collapsible panels
□ ChangePasswordDialog validation
□ ErrorState widget
```

### Integration Tests
```
□ Flujo completo: carrito → checkout → orden
□ Profile: editar datos → cambiar contraseña
□ Tracking: conectar socket → actualizar marcas
```

### Manual QA
```
□ Responsividad: mobile 375px, tablet 768px, desktop 1920px
□ Interactividad: todos los botones y campos
□ Errores: probar con internet desconectada
□ Performance: lista 100 items sin lag
```

---

## 📝 Notas Importantes

1. **Orden Recomendado:**
   - Comienza con **SPRINT 3** (validadores/error handling) - NO DEPENDEN DE NADA
   - Aplica esos patterns mientras haces **SPRINT 1**
   - **SPRINT 2** paralelo a mitad de SPRINT 1
   - **SPRINT 4** al final cuando todo esté estable

2. **Branch Strategy:**
   - `feature/sprint1-cart` - T1.1, T1.2, T1.3, T1.4
   - `feature/sprint2-profile` - T2.1, T2.2
   - `feature/sprint3-validation` - T3.1, T3.2, T3.3
   - `feature/sprint4-tracking` - T4.1, T4.2

3. **Commits:**
   - Un commit por tarea (T1.1, T1.2, etc)
   - Mensaje: `✨ T1.1: Save cart to localStorage`

4. **Testing:**
   - Ejecutar `flutter analyze` después de cada tarea
   - `flutter test` para unit tests
   - Manual QA antes de merge

5. **Backend Coordination:**
   - Verificar APIs están listas (SPRINT 1 requiere crear orden)
   - Confirm WebSocket events (SPRINT 4)
   - FCM tokens (SPRINT 5 - phase 2)

---

## 🎯 Quick Start

```bash
# 1. Si no existe branch feature
git checkout -b feature/sprint1-cart

# 2. Crear archivo de test
touch lib/core/validators/input_validators.dart

# 3. Implementar validador (T3.1.1)
# ... código ...

# 4. Ejecutar analyze
flutter analyze

# 5. Commit
git add lib/core/validators/input_validators.dart
git commit -m "✨ T3.1.1: Create centralized input validators"

# 6. Siguiente tarea
# Repetir 2-5 para cada tarea
```

---

**Estado Inicial:** ✅ Listo para comenzar  
**Próximo Paso:** Crear branch `feature/sprint1-cart` y comenzar con **T1.1.1**

---

**Documento Actualizado:** 22 Febrero 2026  
**Referencia:** docs/CLIENTE_FLUJO_COMPLETO.md
