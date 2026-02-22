# Pendientes – Flutter vs Angular (Cliente)

## Hecho ✅
- Login, redirección por rol, rutas estilo Angular
- Dashboard cliente: saludo, 4 cards (Nueva solicitud, Mis solicitudes, Tracking, Mi Perfil)
- Lista de solicitudes: pestañas Activas/Historial, navegación a detalle
- Crear solicitud: 4 pasos (Categoría → Servicio → Ubicación → Confirmar), POST /requests/express
- Detalle solicitud: estado, origen/destino, contraofertas, aceptar, cancelar
- Tracking: pantalla por request id
- Perfil: datos de usuario, direcciones guardadas, cerrar sesión
- Tema glass y colores Angular
- go_router con rutas /login, /dashboard/cliente, /requests, /requests/new, /requests/:id, /profile

---

## Por hacer (prioridad)

### 1. Dashboard cliente – Tiendas y “Volver a pedir”
- **Angular**: Carga tiendas con `GET /stores` (lat, lng), “Volver a pedir” con `GET /store-orders` (recientes por tienda), búsqueda, grid de tiendas, “Ver Catálogo”.
- **Flutter**: Solo están las 4 cards. Falta:
  - Obtener ubicación y llamar `GET /stores`, `GET /store-orders`.
  - Mostrar nombre del usuario (ej. “Hola, {{ userName }}”) desde AuthService/Storage.
  - Sección “Volver a pedir” con enlaces a `/cliente/catalog/:storeId`.
  - Sección “Tiendas disponibles” con búsqueda y cards que lleven al catálogo.

### 2. Lista de solicitudes – Filtros como en Angular
- **Angular**: Filtros por tipo (Todos / Servicios / Tiendas), estado (Todas / Pendientes / Aceptadas / …), y rango de fechas con calendario.
- **Flutter**: Solo pestañas Activas/Historial. Falta:
  - Filtros tipo (all / service / store) y estado.
  - Filtros por fecha (rango o calendario).
  - Unificar en la misma lista pedidos de servicio y pedidos de tienda (store-orders) como en Angular.

### 3. Crear solicitud – Ajustes de paridad
- **Direcciones guardadas**: En paso 3 (Ubicación), mostrar chips “Casa”, “Oficina”, etc. desde `getSavedAddresses()` y al tocar rellenar origen/destino (y lat/lng).
- **Precio editable**: En paso 4, botones +/- para ajustar el precio propuesto (ej. +5 / -5) como en Angular.
- **Validación “Recuerda mis datos”**: Solo aplica si en login se guarda email; no bloquea el flujo.

### 4. Registro – Wizard completo
- **Angular**: Paso 1 rol (cliente/prestador/store), paso 2 método (email/teléfono/Google/Facebook), paso 3 formulario o verificación SMS.
- **Flutter**: Pantalla de registro existe pero sin wizard de 3 pasos ni verificación por teléfono. Falta alinear pasos y textos.

### 5. Pantallas legales / estáticas
- **Angular**: Rutas aviso-de-privacidad, terminos-y-condiciones, politica-cookies, acerca-de, contacto.
- **Flutter**: No existen. Opcional: añadir rutas y pantallas estáticas o WebView con la misma URL que Angular.

### 6. Errores y estados vacíos
- **Sin conexión**: Detección (ej. DioException tipo connection) y mensaje tipo “No hay conexión. Verifica tu internet.” con botón Reintentar.
- **401/403**: Redirigir a login con mensaje “Tu sesión ha expirado.”
- **404**: Página “No encontrado” en lugar del error genérico de go_router.
- **Empty states**: Revisar que los textos coincidan con Angular (ej. “No hay solicitudes con estado …”).

### 7. Infra / calidad
- **Token en almacenamiento seguro**: Usar `flutter_secure_storage` para token (y refresh) en lugar de solo SharedPreferences.
- **Dio**: Interceptor de retry para GET (idempotentes) y logging opcional.
- **Flavors**: Configurar dev/prod con `--dart-define=BASE_URL=...` o `env_*.dart` y usarlos en `AppConstants`/ApiClient.
- **Complete profile**: Ruta `/complete-profile` para usuarios que llegan por Google/Facebook y necesitan completar datos; pantalla básica si el backend lo requiere.

### 8. Opcional (fuera del MVP cliente)
- Flujo tienda: `/cliente/catalog/:storeId`, checkout, order-confirmation, store-order/:id.
- Subastas: rutas /auctions, /auctions/new, /auctions/:id si se replica ese flujo.
- Cliente tracking list: `/cliente/tracking` como lista de solicitudes activas para elegir cuál rastrear (Angular tiene esa lista).

---

## Resumen rápido
| Área              | Estado | Acción principal                                      |
|-------------------|--------|--------------------------------------------------------|
| Dashboard tiendas | Falta  | GET /stores, /store-orders, “Volver a pedir”, nombre  |
| Filtros requests | Falta  | Tipo, estado, fechas; unificar servicio + tienda      |
| Nueva solicitud  | Casi   | Chips direcciones guardadas, +/- precio               |
| Registro         | Falta  | Wizard 3 pasos + teléfono/SMS                          |
| Legales          | Falta  | Rutas y pantallas estáticas                           |
| Errores/empty    | Parcial| Sin conexión, 401 → login, 404, textos empty          |
| Infra            | Parcial| Secure storage, retry Dio, flavors                    |
