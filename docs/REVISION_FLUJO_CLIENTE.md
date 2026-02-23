# Revisión completa: flujo del cliente (Mapper Flutter)

**Fecha:** Febrero 2025  
**Objetivo:** Estado actual del flujo cliente y lo que falta respecto a paridad con Angular (Mapper.digital).

---

## 1. Entrada y rutas del cliente

| Ruta | Pantalla | Notas |
|------|----------|--------|
| `/login` | LoginPage | Redirección por rol; cliente → `/dashboard/cliente` |
| `/dashboard/cliente` | ClientDashboardContainer | **Contenedor con 4 pestañas** (IndexedStack): Inicio, Solicitudes, Tracking, Perfil. URL no cambia al cambiar de pestaña. |
| `/client/dashboard` | ClientDashboardContainer | Misma pantalla (alias). |
| `/requests` | RequestsPage | Lista unificada; puede mostrarse como tab dentro del contenedor o como pantalla completa si se navega aquí. |
| `/requests/new` | NewRequestPage | Crear solicitud (4 pasos). |
| `/requests/:id` | RequestDetailPage | Detalle de solicitud de servicio. |
| `/requests/:id/tracking` | RequestTrackingPage | Tracking de una solicitud. |
| `/cliente/tracking` | ClientTrackingPage | Lista/entrada de tracking (cliente elige cuál rastrear). |
| `/cliente/catalog/:storeId` | ClientCatalogPage | Catálogo de una tienda (productos, carrito). |
| `/cliente/catalog/:storeId/checkout` | ClientCheckoutPage | Checkout (dirección, total, crear orden). |
| `/client/order-confirmation` | OrderConfirmationPage | Confirmación post-compra (extra: orderId, storeName, total, etc.). |
| `/cliente/store-order/:id` | StoreOrderDetailPage | Detalle de pedido de tienda. |
| `/profile` | ProfilePage | Datos de usuario, direcciones guardadas, cerrar sesión. |

**Navegación:** `NavigationService` centraliza `goToClientCatalog`, `goToClientCheckout`, `goToOrderConfirmation`, `goToStoreOrderDetail`. Uso de `context.push` / `context.go` con `go_router`.

---

## 2. Lo que está implementado ✅

### 2.1 Login y entrada
- Login (email/contraseña y/o social según configuración).
- Redirección por rol; cliente va a `/dashboard/cliente`.
- Rutas estilo Angular documentadas en `app_router.dart`.

### 2.2 Dashboard cliente (Inicio)
- **Nombre de usuario:** “Hola, {userName}” desde `StorageService.getUserName()`.
- **Ubicación:** Geolocator para lat/lng del usuario.
- **Tiendas disponibles:** `GET /stores` con `clientLat`, `clientLng`, `active=true`; lista ordenada por distancia; búsqueda por nombre/dirección; “Ver Catálogo” → `/cliente/catalog/:storeId`.
- **Volver a pedir:** `GET /store-orders` (recientes); chips por tienda que llevan a `/cliente/catalog/:storeId`.
- **Acciones rápidas:** Nueva solicitud, Mis solicitudes, Tracking, Mi Perfil (y mismo menú en drawer).
- **Empty state:** Si no hay tiendas, CTA “Crear nueva solicitud”.
- **Notificaciones:** Panel y contador; marcar como leídas.
- **Drawer:** Menú (Nueva solicitud, Mis solicitudes, Tracking, Subastas, Perfil, Refrescar, Cerrar sesión).

### 2.3 Lista de solicitudes
- **Lista unificada:** Servicio + tienda mediante `getUnifiedRequests(type, status)` (combina `getMyRequests` y `GET /store-orders`).
- **Filtros:** Tipo (Todos / Servicios / Tiendas) y estado (Todas / Pendientes / Rechazadas / Aceptadas / En Progreso / Completadas / Canceladas).
- **UI:** `UnifiedRequestCard` con estado, tipo, ubicación, monto, “Ver detalles” y “Tracking” (solo servicio en in_progress/accepted).
- **Navegación:** Tap → servicio: `/requests/:id`, tienda: `/cliente/store-order/:id`; “Tracking” → `/requests/:id/tracking`.
- **FAB “Nueva Solicitud”**, pull-to-refresh, empty state y manejo de error con Reintentar.

### 2.4 Crear solicitud (servicio)
- **4 pasos:** Categoría → Tipo de servicio → Ubicación → Confirmar.
- **Paso 3 – Ubicación:** Chips de direcciones guardadas (`getSavedAddresses()`); al tocar rellenan origen/destino y lat/lng.
- **Paso 4 – Confirmar:** Botones +/- (pasos de 5) para ajustar el precio propuesto; un solo “Crear Solicitud” envía todo.
- **API:** `POST /requests/express` con categoría, tipo, ubicaciones, precio, etc.

### 2.5 Detalle de solicitud (servicio)
- Carga con `getRequestById`; muestra estado, origen/destino.
- Contraofertas (`GET /requests/:id/offers`); aceptar contraoferta; cancelar solicitud.

### 2.6 Tracking
- **RequestTrackingPage** (`/requests/:id/tracking`): pantalla por request id (mapa, etc.).
- **ClientTrackingPage** (`/cliente/tracking`): entrada de tracking (actualmente con request mock; lista de activas para elegir pendiente de alinear con backend).

### 2.7 Flujo tienda (cliente)
- **Catálogo:** `ClientCatalogPage` con productos (`GET /stores/:storeId/products`), carrito en memoria y persistido (CartService), detalle de producto, recuperación de carrito.
- **Checkout:** Dirección de entrega, total, envío fijo; `ClientOrderRepository.createOrder`; limpieza de carrito y navegación a confirmación.
- **Confirmación:** OrderConfirmationPage con resumen (orderId, tienda, total, estado).
- **Detalle de pedido tienda:** `StoreOrderDetailPage` en `/cliente/store-order/:id` (placeholder: “Pedido #id”, mensaje “Próximamente más opciones”).

### 2.8 Perfil
- Datos de usuario (nombre, email, teléfono, rol).
- Direcciones guardadas (lista, alta/edición si existe en backend).
- Cerrar sesión.
- Cambio de contraseña (diálogo).
- Notificaciones y drawer coherentes con el resto del flujo.

### 2.9 Infra y UX
- Tema “glass” / LiquidGlass; colores alineados con Angular.
- `go_router` con rutas anteriores; `errorBuilder` genérico (p. ej. “Page not found: …”).

---

## 3. Lo que falta o está a medias

### 3.1 Filtro por fecha en solicitudes
- **PENDIENTES.md:** Filtros por rango de fechas o calendario como en Angular.
- **Estado:** No implementado en RequestsPage; solo tipo y estado.
- **Acción:** Añadir selector de rango (o calendario simplificado) y pasar `dateFrom`/`dateTo` a `getUnifiedRequests` si el backend lo soporta.

### 3.2 Detalle de pedido de tienda (store-order)
- **Estado:** StoreOrderDetailPage es placeholder (solo “Pedido #id” y texto “Próximamente”).
- **Acción:** Cargar detalle con `GET /store-orders/:id` (o equivalente) y mostrar ítems, total, estado, posible re-pedido.

### 3.3 Cliente tracking list
- **PENDIENTES.md:** `/cliente/tracking` como lista de solicitudes activas para elegir cuál rastrear.
- **Estado:** ClientTrackingPage usa un `_mockRequestId`; no hay lista real desde API.
- **Acción:** Listar solicitudes activas (p. ej. `getMyRequests(status: 'in_progress')` o endpoint específico) y al elegir una navegar a `/requests/:id/tracking`.

### 3.4 Registro ✅ (wizard 3 pasos)
- **Estado:** RegisterPage con wizard: Paso 1 = tipo de cuenta (Cliente/Prestador/Tienda), Paso 2 = método (Email o Google/Facebook), Paso 3 = formulario con datos; botones Regresar y Cambiar tipo de cuenta. Verificación SMS pendiente si el backend lo requiere.

### 3.5 Pantallas legales / estáticas ✅ (implementado)
- **Estado:** Rutas `/aviso-de-privacidad`, `/terminos-y-condiciones`, `/politica-cookies`, `/acerca-de`, `/contacto` con `StaticLegalPage` y textos placeholder (se pueden sustituir por URL WebView si Angular sirve el contenido).

### 3.6 Errores y estados
- **Sin conexión:** No hay detección explícita (p. ej. DioException por conexión) ni mensaje unificado “No hay conexión. Verifica tu internet.” con Reintentar.
- **401/403:** Interceptor en ApiClient puede redirigir a login; mensaje tipo “Tu sesión ha expirado” no unificado en todas las pantallas.
- **404:** `errorBuilder` de go_router muestra texto genérico; no hay página “No encontrado” dedicada.
- **Empty states:** Textos en RequestsPage y Dashboard alineados; revisar resto de pantallas frente a Angular.

### 3.7 Infra / calidad
- **Token:** Uso de SharedPreferences; PENDIENTES sugiere `flutter_secure_storage` para token (y refresh).
- **Dio:** Retry para GET y logging opcional no implementados de forma estándar.
- **Flavors:** Dev/prod con `--dart-define=BASE_URL=...` o `env_*.dart` no documentados en flujo cliente.
- **Complete profile:** Ruta `/complete-profile` para usuarios social que deban completar datos; no implementada.

### 3.8 Navegación y consistencia
- **Container vs rutas:** Desde `/dashboard/cliente` el bottom nav cambia solo el índice (Inicio, Solicitudes, Tracking, Perfil); la URL sigue siendo `/dashboard/cliente`. Si el usuario abre “Mis solicitudes” desde el drawer con `context.push('/requests')`, sale del contenedor y ve RequestsPage con su propio scaffold (ClientBottomNav con 5 ítems, incl. Subastas). Tener en cuenta si se quiere que “Solicitudes” desde el drawer también cambie solo de pestaña dentro del contenedor (sin push a `/requests`) para mantener una sola experiencia.
- **ClientBottomNav:** Usa `context.go('/client/dashboard')` (con “client” en singular); el router tiene tanto `/dashboard/cliente` como `/client/dashboard` apuntando al mismo container. Conviene unificar criterio de URL canónica.

---

## 4. Resumen por área

| Área | Estado | Comentario |
|------|--------|------------|
| Login / redirección | ✅ | Rol cliente → dashboard. |
| Dashboard (tiendas, volver a pedir, nombre) | ✅ | GET /stores, /store-orders, búsqueda, chips, catálogo. |
| Lista solicitudes (unificada + filtros tipo/estado) | ✅ | Filtros tipo/estado; falta filtro por fecha. |
| Crear solicitud (chips direcciones, +/- precio) | ✅ | Un solo Guardar; chips en paso 3; +/- en paso 4. |
| Detalle solicitud / contraofertas / cancelar | ✅ | Carga, ofertas, aceptar, cancelar. |
| Tracking por request id | ✅ | Pantalla por id. |
| Tracking list (cliente) | ⚠️ | Página existe; lista real y navegación a tracking por id pendientes. |
| Catálogo tienda + carrito + checkout + confirmación | ✅ | Flujo completo; carrito persistido. |
| Detalle pedido tienda | ⚠️ | Placeholder; falta integración con API. |
| Perfil (datos, direcciones, logout) | ✅ | Alineado con lo esperado. |
| Registro (wizard 3 pasos, SMS) | ❌ | Por hacer. |
| Legales / estáticas | ❌ | No implementadas. |
| Errores (sin conexión, 401, 404) | ⚠️ | Parcial; unificar mensajes y comportamientos. |
| Infra (secure storage, retry, flavors, complete-profile) | ⚠️ | Parcial o no hecho. |

---

## 5. Recomendaciones prioritarias

1. **Cerrar flujo store-order:** Implementar detalle real en `StoreOrderDetailPage` (GET pedido, ítems, estado).
2. **Tracking list real:** En ClientTrackingPage, listar solicitudes activas y navegar a `/requests/:id/tracking`.
3. **Filtro por fecha:** En RequestsPage, añadir rango de fechas (o calendario simple) si el backend lo permite.
4. **Unificar manejo de errores:** Sin conexión, 401/403 y 404 con mensajes y acciones coherentes en todo el flujo cliente.
5. **Opcional:** Ajustar navegación drawer/container para que “Mis solicitudes” no salga del contenedor (cambiar pestaña en lugar de push `/requests`) y unificar URL canónica del dashboard (`/dashboard/cliente` vs `/client/dashboard`).

Con esto el flujo del cliente queda revisado de punta a punta: lo que está listo, lo que falta y los siguientes pasos sugeridos.
