# 📱 Flujo Completo de Cliente - Mapper Flutter App

**Fecha:** 22 de Febrero 2026  
**Estado:** Sprint Homologación - 95% Completado  
**Lenguaje:** Flutter + GoRouter + Liquid Glass Design

---

## 1. Visión General

El flujo de cliente representa todo el recorrido de un usuario desde que accede al dashboard hasta completar una transacción (solicitud de servicio o compra en tienda).

### Roles y Acceso
- **Cliente**: Acceso a dashboard, catálogos, solicitudes, tracking, perfil
- **Prestador**: Dashboard diferente (no en alcance actual)
- **Store Manager**: Dashboard diferente (no en alcance actual)

### Arquitectura de Navegación
```
ClientDashboardContainer (IndexedStack - Mantiene estado de todas las páginas)
├── [0] ClientDashboardPage (Inicio/Home)
├── [1] RequestsPage (Mis Solicitudes)
├── [2] ClientTrackingPage (Tracking en vivo)
└── [3] ProfilePage (Mi Perfil)

Rutas adicionales (Stack sobre el contenedor):
├── /cliente/catalog/:storeId → ClientCatalogPage
├── /cliente/request/new → NewRequestPage (Wizard 4 pasos)
├── /cliente/request/:id → RequestDetailPage
└── /cliente/request/:id/tracking → RequestTrackingPage
```

---

## 2. Pantallas Principales

### 2.1 Dashboard de Cliente (ClientDashboardPage)
**Estado:** ✅ Homologado y Compilando

#### Propósito
Centro de control: buscar tiendas, ver órdenes recientes, acceder a todas las funciones.

#### Componentes
- **Header**
  - Saludo personalizado: "Hola, {nombre_usuario}"
  - Icono notificaciones con badge
  - Botón menú (mobile) / botón atrás (desktop)

- **Búsqueda y Ubicación**
  - Campo búsqueda stores: filtra por nombre en tiempo real
  - Ubicación actual del usuario (geolocalización)
  - Botón "Usar Mi Ubicación"

- **Sección "Tiendas Recientes"**
  - Últimas 3-5 tiendas donde compró
  - Card pequeño para navegar rápido
  - Click → `ClientCatalogPage` con storeId

- **Listado de Tiendas**
  - Scroll infinito / paginado
  - Cards con: nombre, distancia, horario, rating
  - Busca distancia desde ubicación del cliente
  - Click → `ClientCatalogPage`

- **Botón FAB (Floating Action Button)**
  - "+ Nueva Solicitud" → `NewRequestPage`
  - Solo visible en mobile (en desktop, naveg bottom nav)

- **Drawer (Mobile)**
  - Perfil mini (foto, nombre, email)
  - Links: Solicitudes, Tracking, Perfil, Cerrar sesión

- **Bottom Navigation (Mobile)**
  - Inicio, Solicitudes, Tracking, Perfil
  - NavBar tipo Liquid Glass

#### Estado Local
```dart
String _userName = 'Cliente';
double _userLat = 0, _userLng = 0;
List<StoreModel> _stores = [];
List<RecentStoreModel> _recentOrderStores = [];
bool _loadingStores = false, _loadingRecent = false;
String _searchQuery = '';
int _unreadNotificationsCount = 0;
```

#### Llamadas API
- **GET** `/stores` (con filtro búsqueda y ubicación)
- **GET** `/clients/recent-stores`
- **GET** `/notifications/unread/count`

#### Validaciones
- ✓ Ubicación debe ser válida (lat/lng)
- ✓ Búsqueda vacía → mostrar todas las tiendas
- ✓ Si error en ubicación → usar última conocida o center país

#### Cambios de Estado
- Click tienda → navegar a catálogo (stack push)
- Click "+Nueva Solicitud" → abrir NewRequestPage
- Click notificaciones → abrir panel
- Bottom nav index 0-3 → cambiar _selectedIndex en container

---

### 2.2 Catálogo de Tienda (ClientCatalogPage)
**Estado:** ✅ RECIÉN HOMOLOGADO - Carrito completo

#### Propósito
Mostrar productos de una tienda y permitir agregarlos al carrito.

#### Componentes

**Header**
- Título: "Catálogo"
- Icono notificaciones + badge
- **Icono carrito (NUEVO) + badge contador**
  - Verde (#10b981) cuando hay items
  - Badge muestra cantidad total
  - Click abre `_showCartSummary()`

**Listado de Productos**
- ListView con productos de la tienda
- Cards por producto:
  - Nombre (2 líneas max)
  - Precio en cyan (#06b6d4)
  - Descripción breve
  - Badge naranja con cantidad si ya está en carrito
  - Botón "Agregar" o "Modificar" (OutlinedButton)

**Carrito (Dialogs)**

1. **Dialog Agregar al Carrito** (`_showAddToCartDialog`)
   - Nombre producto
   - Precio unitario
   - Selector cantidad: botones - / + / input
   - Total calculado: `cantidad × precio`
   - Botón "Agregar" (disabled si cantidad = 0)
   - Botón "Cancelar"

2. **Dialog Resumen Carrito** (`_showCartSummary`)
   - Si vacío: "Carrito vacío" + botón Cerrar
   - Si con items:
     - Lista de items: nombre, cantidad, subtotal
     - Botón eliminar (X rojo) por item
     - Total final en card destacada
     - Botones: "Continuar comprando", "Proceder a Pago"

**Confirmación**
- SnackBar verde al agregar: "{cantidad} x {producto} - ${total}"
- Acción "Ver carrito" en snackbar

#### Estado Local
```dart
Map<String, Map<String, dynamic>> _cart = {}; 
// {productId: {name, price, quantity, product_data}}
int _cartItemCount = 0;
List<dynamic> _products = [];
bool _loading = true;
String? _error;
bool _drawerOpen = false;
bool _showNotifications = false;
```

#### Llamadas API
- **GET** `/stores/:storeId/products`

#### Validaciones
- ✓ Cantidad debe ser > 0 para agregar
- ✓ Producto no debe duplicarse (si existe, actualizar cantidad)
- ✓ Precio debe ser válido (número positivo)
- ✓ Preload spinner mientras carga productos

#### Flujo Carrito
1. Click "Agregar" → Dialog cantidad
2. Ingresa cantidad → Total se recalcula
3. Click "Agregar" → Item en _cart[productId]
4. _cartItemCount actualiza
5. Badge header muestra contador
6. Click carrito header → Resumen carrito
7. Opción eliminar → Remove del carrito
8. "Proceder a Pago" → (stub: message "Próximamente")

#### UI Rules
- **Liquid Glass**: Todos los containers con `Colors.white.withOpacity(0.08-0.15)`
- **Bordes**: `Colors.white.withOpacity(0.1-0.15)`
- **Colors**:
  - Precio: #06b6d4 (cyan)
  - En carrito badge: #f97316 (orange)
  - Carrito header badge: #10b981 (green)
- **Responsive**:
  - Mobile: Mostrar drawer + bottom nav
  - Desktop (width >= 768): Mostrar back button

---

### 2.3 Nueva Solicitud - Wizard 4 Pasos (NewRequestPage)
**Estado:** ✅ Homologado (sin cambios recientes)

#### Propósito
Crear solicitud de servicio (transporte, mudanza, etc.) en 4 pasos guiados.

#### Pasos

**Paso 1: Categoría**
- Carga de categorías: GET `/service-categories`
- Lista seleccionable de categorías
- Cada categoría tiene subservicios
- Click categoría → desbloquea Paso 2

**Paso 2: Tipo de Servicio**
- Muestra servicios de categoría seleccionada
- Select de servicio
- click servicio → desbloquea Paso 3
- Nota: si categoría solo tiene 1 servicio, saltar a siguiente

**Paso 3: Ubicación**
- **Origen** (si `requiresOrigin = true`)
  - Campo texto ubicación origen
  - Botón "Usar Mi Ubicación" → geolocalización
  - Lista de "Direcciones Guardadas"
  - Al seleccionar: geocoding → lat/lng

- **Destino** (si servicio lo requiere)
  - Similar a origen
  - Cálculo de distancia entre coordenadas
  - Propuesta de precio según categoría (GET `/estimate-price`)

- **Notas opcionales**
  - TextArea para instrucciones
  - Max 500 caracteres

**Paso 4: Confirmar**
- Resumen: categoría, servicio, ubicaciones, notas
- Precio final
- Botón "Confirmar Solicitud"
- Validaciones finales
- POST `/requests` → submit

#### Estado Local
```dart
int _currentStep = 1 / 2 / 3 / 4;
List<ServiceCategoryModel> _categories = [];
ServiceCategoryModel? _selectedCategory;
ServiceTypeModel? _selectedService;

// Origen
double? _originLat, _originLng;
String _originDisplay = '';
bool _loadingOrigin = false;

// Destino (similar)
double? _destLat, _destLng;
String _destDisplay = '';
bool _loadingDest = false;

String _notesController.text;
double _proposedPrice = 0;
double? _estimatedDistance;

List<SavedAddressModel> _savedAddresses = [];
bool _isSubmitting = false;
```

#### Validaciones
1. **Paso 1**: Categoría seleccionada
2. **Paso 2**: Servicio seleccionado
3. **Paso 3**:
   - Origen: requerido si `requiresOrigin = true`
   - Destino: requerido si servicio lo necesita
   - Ubicaciones deben ser válidas (lat/lng válido)
   - Notas: max 500 chars
4. **Paso 4**:
   - Resumen válido, sin cambios requeridos

#### Cambios de Estado
- Next button: valida paso actual → _currentStep++
- Back button: _currentStep--
- Cancel: volver a dashboard con context.pop()
- Submit: POST `/requests` → home + success toast

#### UI Rules
- Liquid Glass: cards, botones, inputs
- Indicador de pasos: "Paso 1 de 4"
- Progress bar visual
- Step labels: ['Categoría', 'Servicio', 'Ubicación', 'Confirmar']

---

### 2.4 Lista de Solicitudes (RequestsPage)
**Estado:** ✅ Homologado (con widgets unificados)

#### Propósito
Visor de todas las solicitudes (servicios + tiendas) del cliente con filtros.

#### Componentes

**Filtros**
- **Tipo**: Todos, Servicios, Tiendas (3 botones toggle)
- **Estado**: Todas, Pendientes, Rechazadas, Aceptadas, En Progreso, Completadas, Canceladas

**Listado**
- Cards unificadas: `UnifiedRequestCard`
- Campos:
  - Tipo (icono + label): "Servicio" o "Tienda"
  - ID solicitud
  - Fecha/hora creación
  - Estado (badge de color)
  - Descripción breve
  - Click → `RequestDetailPage` con ID

**Estados y Colores**
- Pending: Amarillo
- Rejected: Rojo
- Accepted: Verde
- In Progress: Azul
- Completed: Verde oscuro
- Cancelled: Gris

#### Llamadas API
- **GET** `/requests?type={type}&status={status}` (con paginación)

#### Validaciones
- ✓ Si vacío: "No hay solicitudes"
- ✓ Filtros no rompen paginación
- ✓ Error en carga: mostrar retry

---

### 2.5 Detalle de Solicitud (RequestDetailPage)
**Estado:** ✅ Existe (no recientemente modificado)

#### Propósito
Ver detalles completos de una solicitud individual.

#### Componentes
- Encabezado: tipo, ID, estado, fecha
- Detalles: origen, destino, precio, notas
- Timeline de eventos (si aplica)
- Botones de acción (según estado)
  - Cancelar
  - Aceptar (si no fue aceptada)
  - Ver Tracking (si en progreso)

#### Llamadas API
- **GET** `/requests/:id`
- **POST** `/requests/:id/cancel` (condicional)

---

### 2.6 Tracking en Vivo (ClientTrackingPage)
**Estado:** ⚠️ Parcialmente - Usa WebSocketService

#### Propósito
Mostrar en tiempo real ubicación del prestador/delivery en mapa.

#### Componentes
- **Mapa Interactivo** (flutter_map + latlong2)
  - Marca usuario (azul)
  - Marca prestador (rojo)
  - Línea ruta entre ellos
  - Distancia calculada
  - Bearing/dirección

- **Información**
  - Distancia en km (actualiza c/10m)
  - ETA estimado
  - Nombre prestador
  - Teléfono

#### WebSocket
- Conectar a room de tracking: `/tracking/{requestId}`
- Escuchar eventos:
  - `provider_location` → actualizar _providerLocation
  - `request_status_changed` → actualizar UI
- Disconnect: ondispose

#### Validaciones
- ✓ Usuario debe tener permisos de ubicación
- ✓ Si no hay proveedor en tracking → mostrar "Esperando..."

---

### 2.7 Perfil de Usuario (ProfilePage)
**Estado:** ✅ RECIÉN HOMOLOGADO - 3 panels colapsables + cambio contraseña

#### Propósito
Gestión de datos personales, direcciones guardadas, preferencias, cambio contraseña.

#### Paneles (Colapsables)

**1. Datos Personales** (_expandPersonal)
- Nombre completo
- Email (read-only)
- Teléfono
- Dirección (estado, ciudad, colonia, código postal)
- Botón Editar → formulario inline

**2. Direcciones Guardadas** (_expandAddresses)
- Lista de direcciones guardadas
- Botones eliminar por dirección
- Botón "+ Agregar nueva"
- Cada dirección: nombre, dirección completa

**3. Configuración** (_expandSettings)
- Notificaciones (toggle)
- Botón "Cambiar Contraseña" → Dialog

**4. Dialog Cambiar Contraseña** (_showPasswordChangeDialog)

Campos:
- Contraseña actual (required)
- Nueva contraseña (required, min 6)
- Confirmar contraseña (required, matches)

Validaciones:
- Contraseña actual debe ser correcta (compare con backend)
- Nueva contraseña ≠ actual
- Confirmación debe coincidir
- Min 6 caracteres (backend: min 8)

Botones:
- "Cancelar"
- "Cambiar" (disabled si inválido)

Estados:
```dart
bool _expandPersonal = false;
bool _expandAddresses = false;
bool _expandSettings = false;
String _currentPassword = '';
String _newPassword = '';
String _confirmPassword = '';
bool _changingPassword = false;
String? _passwordError = null;
```

#### Cambios de Estado
- Click panel → toggle expand/collapse suave
- Click Editar → abre forma inline
- Click Guardar Cambios → PUT `/auth/profile`
- Click Cambiar Contraseña → Dialog
- Submit Dialog → POST `/auth/change-password`
- Success → SnackBar verde, limpiar campos

#### Llamadas API
- **GET** `/auth/profile` (onInit)
- **PUT** `/auth/profile` (guardar cambios)
- **POST** `/auth/change-password` (cambiar contraseña)
- **GET** `/auth/saved-addresses` (cargar direcciones)
- **POST** `/auth/saved-addresses` (agregar)
- **DELETE** `/auth/saved-addresses/:id` (eliminar)

#### Validaciones
- ✓ Nombre: min 2, max 100 caracteres
- ✓ Teléfono: 10-15 dígitos, patrón válido
- ✓ Email: read-only
- ✓ Código postal: 5 dígitos (regex)
- ✓ Nueva contraseña: min 6 caracteres
- ✓ Coincidencia de contraseñas

#### UI Rules
- **Liquid Glass**: Cards, panels, botones
- **Colores**:
  - Botón cambiar: Cyan #06b6d4
  - Error: Rojo
  - Success: Verde #10b981
- **Animación**: Panels colapsan con smooth animation
- **Panel Header**: Icono + Nombre + Icono expand/collapse

---

## 3. Flujos de Usuario (Happy Paths)

### Flujo 1: Comprar en Tienda
```
1. Dashboard → Click tienda
2. ClientCatalogPage → Carga productos
3. Click "Agregar" → Dialog cantidad
4. Ingresa cantidad → Total actualiza
5. Click "Agregar" → Item en carrito, badge actualiza
6. Click carrito header → Resumen
7. Click "Proceder a Pago" → (Próxima fase)
```

### Flujo 2: Crear Solicitud de Servicio
```
1. Dashboard → Click "+Nueva Solicitud" o Bottom Nav
2. NewRequestPage Paso 1 → Select categoría
3. Paso 2 → Select servicio
4. Paso 3 → Ingresa origen/destino (geoloc o manual)
5. Paso 3 → Ingresa notas opcionales
6. Paso 4 → Confirma resumen
7. Submit → POST /requests → Redirect dashboard + toast éxito
```

### Flujo 3: Ver Tracking en Vivo
```
1. RequestsPage → Click solicitud en progreso
2. RequestDetailPage → Click "Ver Tracking"
3. ClientTrackingPage → Mapa + ubicación real-time
4. WebSocket escucha cambios
5. Mapa actualiza cada 10m de distancia
6. Back → vuelve a detalle
```

### Flujo 4: Cambiar Contraseña
```
1. Dashboard → Bottom Nav Perfil
2. ProfilePage → Panel "Configuración" → Click "Cambiar Contraseña"
3. Dialog abre → Ingresa 3 campos
4. Validación: coincidencia, longitud
5. Click "Cambiar" → POST /auth/change-password
6. Success → SnackBar verde, close dialog
7. Error → SnackBar rojo + reintentar
```

---

## 4. Reglas de UI y Diseño

### Design System: Liquid Glass

```dart
// Colores Base
const Color cyan = Color(0xFF06b6d4);      // Primary - Precios, botones
const Color orange = Color(0xFFf97316);    // En carrito, cambios
const Color green = Color(0xFF10b981);     // Éxito, completado, carrito badge
const Color red = Color(0xFFec4146);       // Error, cancelado
const Color gray = Color(0xFF64748b);      // Texto secundario

// Fondo escuro
const Color dark = Color(0xFF0f172a);      // Fondo principal

// Efecto vidrio translúcido
Colors.white.withOpacity(0.08)            // Background containers
Colors.white.withOpacity(0.15)            // Hover/Active
Colors.white.withOpacity(0.1)             // Borders
```

### Componentes Estándares

**LiquidGlassCard**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withOpacity(0.12)),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: /* content */
  ),
)
```

**Botones**
- **Primary**: `ElevatedButton` - cyan bg
- **Secondary**: `OutlinedButton` - cyan border
- **Text**: `TextButton` - text only
- **States**: disabled si validation fail

**Headers**
- Altura: 60-70px
- Spacing: 12px padding vert, 20px horiz
- Border bottom: 1px white 10% opacity

**Bottom Navigation** (Mobile)
- 4 items: Inicio, Solicitudes, Tracking, Perfil
- Icono + Label en mobile
- LiquidGlass styling

### Responsividad

**Mobile** (width < 768px)
- Stack drawer lateral (250px ancho)
- Bottom navigation 4 items
- Full width cards con padding 16px
- Texto reducido en headers

**Desktop** (width >= 768px)
- No drawer (nav integrado)
- No bottom nav (side nav o top nav)
- Max width contenedor: 1200px
- Cards con padding 20px

### Animaciones
- Drawer: AnimatedPositioned 300ms ease
- Panels: expandCollapse smooth 200ms
- Badges: fade-in 150ms
- Dialogs: Material slide/fade default

---

## 5. Validaciones Centrales

### Ubicación (Geolocalización)
```
✓ Debe estar enabled en device
✓ Debe tener permiso (iOS/Android)
✓ Coordenadas válidas: lat [-90, 90], lng [-180, 180]
✓ Timeout: 10 segundos máximo
✓ Fallback: última ubicación conocida o center país
```

### Campos de Texto
```
Nombre:        min 2, max 100 caracteres
Email:         formato válido, read-only en profile
Teléfono:      10-15 dígitos, patrón /^[0-9\-+\s()]*$/
Contraseña:    min 6 caracteres (backend: 8)
Código Postal: 5 dígitos, patrón /^\d{5}$/
Notas:         max 500 caracteres
Búsqueda:      trim, min 1 char para buscar
```

### Números
```
Cantidad:      > 0, < 999
Precio:        >= 0, 2 decimales
Distancia:     >= 0, formato km
Lat/Lng:       formato double, precisión ~4 decimales
```

### Estados
```
Validación: no enviar si hay error
Loading:    disable botones mientras fetch
Success:    mostrar snackbar 2-3 segs
Error:      mostrar mensaje + retry option
Empty:      mostrar placeholder
```

---

## 6. Manejo de Estados y Errores

### Estados de Página
```dart
// Loading
_loading = true → CircularProgressIndicator

// Error
_error = "Mensaje" → Centro: mensaje + botón "Reintentar"

// Empty
items.isEmpty → Centro: icono + "Sin elementos"

// Success
responseOk → toast/snackbar verde + navegación
```

### Errores API
```
400 Bad Request:  "Datos inválidos. Revisa los campos."
401 Unauthorized: "Sesión expirada. Por favor, inicia sesión."
403 Forbidden:    "No tienes permiso para hacer esto."
404 Not Found:    "El recurso no existe o fue eliminado."
500+ Server:      "Error del servidor. Intenta más tarde."
```

### Timeouts y Reintentos
```
Timeout padrón: 10 segundos
Reintentos: máx 1 reintento automático
User retry: botón "Reintentar" visible en error
```

---

## 7. Integración con Backend (APIs)

### Endpoints Utilizados

**Tiendas**
- GET `/stores` - listar con búsqueda
- GET `/stores/:storeId/products` - productos de tienda

**Solicitudes de Servicio**
- GET `/service-categories` - categorías
- POST `/requests` - crear solicitud
- GET `/requests/:id` - detalle
- GET `/requests?type=&status=` - listar con filtros
- POST `/requests/:id/cancel` - cancelar

**Autenticación**
- GET `/auth/profile` - perfil actual
- PUT `/auth/profile` - actualizar perfil
- POST `/auth/change-password` - cambiar contraseña
- PUT `/auth/settings` - settings

**Ubicación y Precios**
- POST `/estimate-price` - estimar costo servicio
- GET `/clients/recent-stores` - tiendas recientes

**Notificaciones**
- GET `/notifications/unread/count` - contador
- POST `/notifications/mark-read` - marcar leídas
- GET `/notifications` - listar

**WebSocket (Real-time)**
- `/tracking/{requestId}` - eventos tracking
  - `provider_location` → {lat, lng, bearing}
  - `request_status_changed` → {status}

---

## 8. Cambios Recientes y Estado Sprint

### ✅ Completado
- [x] Dashboard homologado con Liquid Glass
- [x] Catálogo con carrito completo (agregar, ver, eliminar)
- [x] NewRequest Wizard 4 pasos (categoría → servicio → ubicación → confirmar)
- [x] RequestsPage con filtros
- [x] ProfilePage con 3 panels colapsables
- [x] Change Password con dialog y validaciones
- [x] CartUI en header con badge
- [x] Responsive design (mobile + desktop)
- [x] Bottom Navigation (mobile)
- [x] Drawer lateral (mobile)
- [x] Liquid Glass design consistency
- [x] Compilación exitosa (flutter build web ✓)

### 🔄 En Progreso
- Carrito: persistencia (localStorage/SQLite)
- Checkout: integración de pago real
- OrderCreation: crear orden desde carrito

### ⏳ Pendiente
- Pago: integración con procesador (Stripe/MercadoPago)
- Órdenes: historial y gestión
- Notificaciones: push real (actualmente mock)
- Analytics/Tracking eventos usuario

---

## 9. Consideraciones Técnicas

### Gestión de Estado
- **IndexedStack**: Mantiene 4 páginas en memoria (Dashboard, Solicitudes, Tracking, Perfil)
- **StatefulWidget**: Local state en cada página (no BLoC/Provider en este sprint)
- **Controllers**: TextEditingController liberados en dispose()

### Almacenamiento Local
- **SharedPreferences** / **SecureStorage**:
  - Token JWT
  - User info (nombre, email, role)
  - Últimas ubicaciones
  - Preferencias (idioma, tema)

### Performance
- **Lazy Loading**: Productos pagados, solicitudes con scroll infinito
- **Caching**: Tiendas recientes en localStorage
- **Debounce**: Búsqueda con delay 300ms
- **Geolocalización**: Actualización cada 10m mínimo

### Seguridad
- Token JWT en autorización header
- Contraseña hasheada con bcrypt (backend)
- HTTPS todas las llamadas
- Validación frontend + backend
- Permisos geolocalización solicitados

### Testing
- [ ] Unit tests: validadores, models
- [ ] Widget tests: cards, dialogs, forms
- [ ] Integration tests: flujos completos
- [ ] Manual: QA en device real

---

## 10. Checklist de Homologación

### Dashboard
- [x] Carga tiendas
- [x] Búsqueda time-real
- [x] Tiendas recientes muestran
- [x] Notificaciones badge
- [x] Drawer mobile
- [x] Bottom nav mobile
- [x] Click tienda → catálogo
- [x] Liquid Glass styling
- [x] Responsive layout

### Catalogo
- [x] Carga productos
- [x] Muestra precio, descripción
- [x] Botón "Agregar"
- [x] Dialog cantidad selector
- [x] Total calculado
- [x] Agregar al carrito
- [x] Badge cantidad en carrito
- [x] Icono carrito header
- [x] Resumen carrito
- [x] Quitar del carrito
- [x] Liquid Glass styling
- [x] Error handling

### Perfil
- [x] Panel datos personales colapsable
- [x] Panel direcciones colapsable
- [x] Panel configuración colapsable
- [x] Botón "Cambiar Contraseña"
- [x] Dialog con 3 campos
- [x] Validación contraseña actual
- [x] Validación confirmación
- [x] POST cambio exitoso
- [x] SnackBar feedback
- [x] Liquid Glass styling

### NewRequest
- [x] Paso 1: categorías cargan
- [x] Paso 2: servicios por categoría
- [x] Paso 3: geolocalización
- [x] Paso 3: direcciones guardadas
- [x] Paso 3: cálculo distancia
- [x] Paso 4: resumen
- [x] Validaciones completas
- [x] Submit POST
- [x] Success redirect

### Solicitudes
- [x] Listado carga
- [x] Filtros funcionan
- [x] Cards unificadas
- [x] Estados + colores
- [x] Paginación

### Tracking
- [x] Mapa renderiza
- [x] Ubicación usuario (azul)
- [x] Ubicación proveedor (rojo)
- [x] WebSocket escucha
- [x] Distancia calcula
- [x] Actualiza c/10m

---

## 11. Notas para Desarrollo Siguientes

### Phase 2: Carrito Persistencia
```
1. LocalStorage: guardar _cart en JSON
2. Sincronización: reload _cart de localStorage al entrar
3. Expiración: limpiar si pasan 24h sin usar
4. Backup: opción "Recuperar carrito antiguo"
```

### Phase 3: Checkout y Órdenes
```
1. OrderModel: estructura en backend
2. POST /orders: crear desde carrito
3. StoreOrderDetailPage: ver detalles
4. Pago: integrar procesador
5. Confirmación: enviar email/SMS
```

### Phase 4: Notificaciones Push
```
1. FCM tokens: capturar y enviar a backend
2. Local notifications: recibir y mostrar
3. Notification routing: deep link según tipo
4. Settings: user puede opt-in/out
```

### Mejoras UX Potenciales
- [ ] Favoritos por tienda
- [ ] Wishlist de productos
- [ ] Recomendaciones ML
- [ ] Chat con prestador
- [ ] Ratings/Reviews
- [ ] Promociones/Cupones
- [ ] Historial completo

---

## 12. Referencia de Archivos

```
mapper-flutter/lib/features/client/
├── presentation/
│   ├── pages/
│   │   ├── client_dashboard_container.dart (48 líneas - IndexedStack)
│   │   ├── client_dashboard_page.dart (827 líneas)
│   │   ├── client_catalog_page.dart (750 líneas - RECIÉN ACTUALIZADO)
│   │   ├── new_request_page.dart (797 líneas)
│   │   ├── requests_page.dart (289 líneas)
│   │   ├── request_detail_page.dart
│   │   ├── client_tracking_page.dart (444 líneas)
│   │   ├── request_tracking_page.dart
│   │   └── store_order_detail_page.dart
│   └── widgets/
│       ├── unified_request_card.dart
│       └── [otros widgets]
├── domain/
│   └── repositories/
│       ├── request_repository.dart
│       └── [otros]
└── [infrastructure si aplica]

Perfil:
lib/features/profile/presentation/pages/profile_page.dart (489 líneas)
```

---

## 13. Status General

| Aspecto | Status | % |
|---------|--------|-----|
| UI Homologación | ✅ | 95% |
| Validaciones | ✅ | 90% |
| API Integration | ✅ | 85% |
| Mobile Responsive | ✅ | 95% |
| Error Handling | ⚠️ | 80% |
| Testing | ⏳ | 10% |
| Documentación | ✅ | 85% |

**Fecha Compilación Última:** 22 Feb 2026  
**Build Status:** ✅ flutter build web success  
**Git Commit:** `5850d0a` (CartUI Full Implementation)

---

**Documento Actualizado:** 22 Febrero 2026  
**Autor:** Architecture Sprint - Homologación Cliente  
**Próxima Revisión:** Post Phase 2 (Persistencia Carrito)
