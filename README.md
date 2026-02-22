# Mapper.digital – Flutter (paridad con Angular)

App Flutter que replica el flujo **Cliente** de la app Angular (fletapp-angular) de Mapper.digital: misma UI/UX, rutas equivalentes, mismos contratos de API.

## Mapeo Angular → Flutter

### Rutas

| Angular (path) | Flutter (go_router path) | Pantalla |
|----------------|--------------------------|----------|
| `''` (landing) | `/` | HomePage / redirect a login en móvil |
| `login` | `/login` | LoginPage |
| `register` | `/register` | RegisterPage |
| `forgot-password` | `/forgot-password` | ForgotPasswordPage |
| `complete-profile` | `/complete-profile` | CompleteProfilePage (si aplica) |
| `dashboard/cliente` | `/dashboard/cliente` | ClientDashboardPage |
| `requests` | `/requests` | RequestListPage |
| `requests/new` | `/requests/new` | CreateRequestPage |
| `requests/:id` | `/requests/:id` | RequestDetailPage |
| `requests/:id/tracking` | `/requests/:id/tracking` | RequestTrackingPage |
| `cliente/tracking` | `/cliente/tracking` | ClientTrackingPage |
| `cliente/tracking/:id` | `/cliente/tracking/:id` | ClientTrackingPage |
| `profile` | `/profile` | ProfilePage |
| `cliente/catalog/:storeId` | `/cliente/catalog/:storeId` | StoreCatalogPage (opcional MVP) |
| `cliente/checkout` | `/cliente/checkout` | CheckoutPage (opcional MVP) |
| `cliente/store-order/:id` | `/cliente/store-order/:id` | StoreOrderDetailPage (opcional MVP) |

### Componentes Angular → Widgets Flutter

| Angular | Flutter |
|---------|--------|
| LoginComponent | LoginPage + LiquidGlassCard, LiquidGlassTextField, GradientButton |
| RegisterComponent | RegisterPage (wizard rol → método → formulario) |
| ClienteDashboardComponent | ClientDashboardPage + drawer, cards Crear solicitud / Mis solicitudes / Tracking |
| RequestListComponent | RequestListPage (filtros tipo/estado/fecha, lista unificada servicio+tienda) |
| CreateRequestComponent | CreateRequestPage (pasos: Categoría → Servicio → Ubicación → Confirmar) |
| RequestDetailComponent | RequestDetailPage (timeline, contraofertas, aceptar/rechazar, cancelar) |
| RequestTrackingComponent | RequestTrackingPage (mapa/estado) |
| ProfileComponent | ProfilePage (tabs: editar, contraseña, direcciones, ajustes) |
| DashboardNavComponent | AppBar + Drawer en dashboard |
| lg-glass / .liquid-aurora-bg | LiquidGlassBackground, LiquidGlassCard |

### Tema y tokens de diseño (Angular → Flutter)

Extraídos de `fletapp-angular/src/styles.scss` y templates:

- **Glass**
  - `--glass-surface`: `rgba(255,255,255,0.08)` → `Color.white.withOpacity(0.08)`
  - `--glass-border**: `rgba(255,255,255,0.16)` → `Color.white.withOpacity(0.16)`
  - `--glass-highlight**: `rgba(255,255,255,0.65)`
  - `--glass-blur**: 16px → `BackdropFilter` blur 16

- **Fondo**
  - `liquid-aurora-bg`: gradientes radiales + lineal:
    - `radial-gradient(120% 120% at 10% 20%, rgba(99,102,241,0.25), transparent)`
    - `radial-gradient(90% 90% at 80% 0%, rgba(14,165,233,0.22), transparent)`
    - `radial-gradient(70% 70% at 25% 80%, rgba(236,72,153,0.18), transparent)`
    - `linear-gradient(135deg, #0b1020 0%, #0e1a32 35%, #0c1326 70%, #050a14 100%)`
  - Body: `bg-slate-950` → `#020617` (Slate 950)

- **Acentos**
  - `--accent`: `#f97316` (Orange 500)
  - `--accent-2`: `#06b6d4` (Cyan 500)
  - Botón primario: `linear-gradient(135deg, #f97316, #06b6d4)`

- **Tipografía**
  - Font: `'Space Grotesk', 'Inter', system-ui`
  - Títulos: Space Grotesk, bold; cuerpo: Inter

- **Espaciado / bordes**
  - Card radius: `1.75rem` (28px) / `rounded-3xl` (24px)
  - Botón radius: `0.9rem` / `rounded-2xl` (16px)
  - Input padding: `px-5 py-3`, radius `rounded-xl` (12px)

### API utilizada por pantalla (Cliente)

| Pantalla | Endpoints |
|----------|-----------|
| Login | `POST /api/auth/login` |
| Register | `POST /api/auth/register` |
| Dashboard cliente | `GET /api/stores` (lat, lng), `GET /api/store-orders` (recientes) |
| Requests list | `GET /api/requests?role=client&page&limit&status&date&startDate&endDate`, `GET /api/store-orders` |
| Create request | `GET /api/services/service-categories`, `GET /api/addresses`, `POST /api/addresses`, `POST /api/requests/express` |
| Request detail | `GET /api/requests/:id`, `GET /api/requests/:id/offers`, `PATCH /api/requests/:id/accept-counteroffer`, `PATCH /api/requests/:id/reject-counteroffer`, `POST /api/requests/:id/cancel` |
| Request tracking | `GET /api/requests/:id`, `GET /api/tracking/:id/events` (o similar) |
| Profile | `GET /api/auth/profile`, `PATCH` perfil, cambio contraseña, `GET /api/addresses`, `POST/DELETE /api/addresses` |

### Contrato requests/express (crear solicitud)

```json
{
  "category_id": number,
  "service_type_id": number (opcional),
  "service_type_name": string (opcional),
  "delivery_location": string,
  "delivery_latitude": number,
  "delivery_longitude": number,
  "offered_price": number,
  "pickup_location": string (opcional),
  "pickup_latitude": number (opcional),
  "pickup_longitude": number (opcional),
  "urgency": "low" | "normal" | "high" | "urgent",
  "description": string (opcional)
}
```

### Checklist de flujos verificados (Cliente)

- [x] Login → redirección a `/dashboard/cliente` para rol cliente
- [ ] Register (wizard rol/método/form, validación teléfono)
- [ ] Dashboard cliente: saludo, cards Crear solicitud / Mis solicitudes / Tracking, tiendas (si hay), “Volver a pedir”
- [x] Lista de solicitudes: pestañas Activas/Historial, navegación a detalle `/requests/:id`
- [x] Crear solicitud: pantalla `/requests/new` (pendiente conectar categorías y POST express)
- [x] Detalle solicitud: estado, origen/destino, contraofertas, aceptar, cancelar
- [x] Tracking: pantalla `/requests/:id/tracking`
- [x] Perfil: ruta `/profile`
- [x] Estados de error con Reintentar en lista y detalle

---

## Configuración

### Entorno

- **Dev**: `lib/core/constants/app_config.dart` (o env) con `baseUrl = http://localhost:3000/api` si corres backend local.
- **Prod**: `baseUrl = https://flet-app-mahegots.fly.dev/api` (ya en `AppConstants`).

Flavors: definir `--dart-define=BASE_URL=...` o archivos `env_*.dart` por flavor.

### Dependencias

- Flutter 3.x, null-safety.
- `dio`, `go_router`, `flutter_secure_storage` (o shared_preferences para token), `google_fonts` (Space Grotesk / Inter).

### Ejecución

```bash
cd mapper-flutter
flutter pub get
flutter run
```

Para flavor dev con API local:

```bash
flutter run --dart-define=BASE_URL=http://localhost:3000/api
```

---

## Estructura del proyecto

- `lib/core/` – theme, router, network (Dio), constants, widgets reutilizables (glass, botones, inputs).
- `lib/features/auth/` – login, register, forgot-password.
- `lib/features/client/` – dashboard, requests (list, new, detail), tracking.
- `lib/features/profile/` – profile, direcciones.
- `lib/features/store/` – catalog, checkout, store-order (opcional en MVP).

Pagos: solo efectivo (CASH ONLY). No integrar Payr ni pasarelas online.
