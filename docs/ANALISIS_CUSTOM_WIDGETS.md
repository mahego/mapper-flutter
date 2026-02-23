# Análisis de custom widgets – Flutter vs Angular

Objetivo: comparar los widgets reutilizables de Flutter con la experiencia ya completa de Angular (Mapper.digital) y proponer mejoras para acercar la UX.

---

## 1. Inventario actual (Flutter)

### 1.1 Core – layout y fondo
| Widget | Uso | Estado |
|--------|-----|--------|
| `TropicalScaffold` | Scaffold con orbes de gradiente (Liquid Aurora), SafeArea, FAB, bottomNav | ✅ Usado; orbes fijos, sin animación |
| `LiquidGlassBackground` | Fondo con gradiente + orbes (otra variante) | ✅ Usado en varias pantallas |
| `GlassSurface` | Superficie con blur, borde, highlight y ruido (CustomPaint) | ✅ Base de cards y bottom nav |
| `LiquidGlassCard` | Card que usa `glass` package o GlassSurface | ✅ Muy usado |
| `ModernGlassCard` | Card con `glass` package, opcional onTap | ✅ Alternativa |

**Observación:** Hay dos fondos (TropicalScaffold con orbes vs LiquidGlassBackground). En Angular el fondo “liquid-aurora” es uno solo. Unificar criterio y, si se quiere paridad visual, revisar valores de gradientes/orbes con el CSS de Angular.

### 1.2 Core – formularios y botones
| Widget | Uso | Estado |
|--------|-----|--------|
| `LiquidGlassTextField` | Input con label, hint, prefix/suffix, estilos glass | ✅ Completo; falta `autofocus`, `focusNode`, `inputFormatters` |
| `GradientButton` | Botón naranja→cyan, loading, icon opcional | ✅ Bien; falta variante outline/secondary |
| `SocialLoginButton` | Botón Google/Facebook con estilo glass | ✅ Solo `provider: String` |

**Observación:** Angular usa el mismo estilo de inputs y botones en toda la app. En Flutter hay pantallas que usan `TextField`/`TextFormField` directo sin `LiquidGlassTextField`, lo que rompe consistencia.

### 1.3 Core – feedback y errores
| Widget | Uso | Estado |
|--------|-----|--------|
| `LiquidGlassSnackBar` | showError, showSuccess, showInfo, showWarning (floating, copiar en error) | ✅ Muy útil |
| `ErrorStateCard` | Mensaje + icono + Reintentar | ✅ Reutilizable |
| `InlineErrorText` | Error debajo de campo | ✅ |
| `ErrorSnackbar` | Snackbar rojo con acción Reintentar | Duplicado con LiquidGlassSnackBar |
| `ErrorBanner` | Banner persistente con cerrar/reintentar | ✅ |

**Observación:** Tener un solo sistema de “toast/snackbar” (p. ej. solo LiquidGlassSnackBar) y reutilizarlo evita duplicados. En Angular el SnackbarService es único.

### 1.4 Core – navegación y shell
| Widget | Uso | Estado |
|--------|-----|--------|
| `LiquidGlassBottomNav` | Bottom nav con GlassSurface, items configurables | ✅ Paridad con dashboard-bottom-nav |
| `LiquidGlassDrawer` | Drawer derecha, items, nombre/rol | ✅ Paridad con dashboard-nav drawer |
| `LiquidGlassAppBar` | Botones notificación + menú (positioned top-right) | ✅ |
| `ClientBottomNav` | 5 ítems (Inicio, Solicitudes, Tracking, Subastas, Perfil) con go_router | ✅ |
| `StoreBottomNav` | 5 ítems para tienda | ✅ |
| `ProviderBottomNav` | Navegación prestador | ✅ |

**Observación:** En Angular el bottom nav usa `RouterModule` y `routerLinkActive` para marcar la ruta activa. En Flutter, ClientBottomNav usa `context.go` y no recibe `currentIndex` desde la ruta, por lo que el ítem activo puede no coincidir con la URL si se entra por deep link.

### 1.5 Core – notificaciones y mapas
| Widget | Uso | Estado |
|--------|-----|--------|
| `NotificationsPanel` | Lista de notificaciones, marcar leídas, mock si no hay servicio | ✅ Completo |
| `TropicalMapWidget` | Mapa (Mapbox dark), marcadores, polylines, círculos, onTap | ✅ Depende de Mapbox token |

### 1.6 Feature – cliente
| Widget | Uso | Estado |
|--------|-----|--------|
| `UnifiedRequestCard` | Card solicitud (servicio/tienda), estado, monto, Ver detalles / Tracking | ✅ |
| `ServiceRequestCard` | Card de solicitud de servicio | Posible duplicado con UnifiedRequestCard |
| `QuickActionCard` | Card con icono, título, descripción, “Ver más” con gradiente | ✅ |
| `ClientStatCard` | Estadística (número + label) | ✅ |

### 1.7 Feature – tienda / provider
| Widget | Uso | Estado |
|--------|-----|--------|
| `ProductCard` | Producto con imagen, nombre, categoría, precio, stock, menú editar/eliminar | ✅ |
| `OrderCard` | Pedido tienda | ✅ |
| `MetricCard` | Métrica (valor + label) | ✅ |
| `ShiftCard`, `RequestCard`, `StatCard`, `SubscriptionStatusCard` | Prestador | ✅ |

---

## 2. Componentes en Angular que no tienen paridad en Flutter

| Componente Angular | Función | En Flutter |
|--------------------|--------|------------|
| **ModalComponent** | Modal tipo info/success/warning/error/confirm, icono, título, mensaje, botones Aceptar/Cancelar | No hay modal reutilizable; se usa `showDialog` + `AlertDialog` ad hoc |
| **AddressPickerComponent** | Flujo: CP → ciudad/estado → calle → geocode → mapa con marker arrastrable → guardar; compat con direcciones guardadas | No hay widget “address picker”; en nueva solicitud hay chips de direcciones y campos de texto |
| **CookieBannerComponent** | Banner de cookies, aceptar/rechazar/preferencias, servicio de consentimiento | No existe |
| **ImageSourceBottomSheetComponent** | Bottom sheet “Galería” / “Tomar fotografía” / “Cancelar” | No hay; en producto se usa solo `pickImage(source: gallery)`. Falta opción cámara y sheet unificado |
| **RatingsDisplayComponent** | Reseñas: promedio, desglose por estrellas, lista de ratings | No hay (ratings_repository existe pero sin UI) |
| **RatingFormComponent** | Formulario para dejar reseña (estrellas + fotos) | No hay |
| **PwaInstallPromptComponent** | Prompt “Instalar app” PWA | No hay |
| **TrackingMapComponent** | Mapa de tracking (proveedor/cliente) reutilizable | Hay TropicalMapWidget pero no un “tracking map” con leyenda/ETA reutilizable |
| **SubscriptionBadgeComponent** | Badge de estado de suscripción | No hay |
| **FeaturedServicesComponent** | Servicios destacados (dashboard) | No hay widget dedicado; dashboard cliente tiene cards genéricas |
| **ServiceCategoryFilterComponent** | Filtro por categoría de servicio | No hay componente reutilizable de filtro por categoría |

---

## 3. Mejoras recomendadas por widget

### 3.1 Unificar fondo y “glass”
- **TropicalScaffold vs LiquidGlassBackground:** Elegir uno como estándar (p. ej. TropicalScaffold que ya incluye body y bottom nav) y migrar pantallas que usen solo LiquidGlassBackground a ese scaffold.
- **LiquidGlassCard:** Añadir parámetros opcionales: `onTap`, `elevation`/sombra sutil, y variante “outline” (solo borde, sin relleno) para listas más ligeras.

### 3.2 LiquidGlassTextField
- Añadir `FocusNode?`, `autofocus`, `inputFormatters` (para máscaras de teléfono, etc.).
- Soportar `helperText` y `counterText` como en Material.
- Revisar deprecación de `withOpacity` y usar `withValues(alpha: x)` donde aplique.
- Usar **siempre** en formularios de login, registro, perfil, nueva solicitud y checkout para consistencia con Angular.

### 3.3 Botones
- **GradientButton:** Añadir variantes: `variant: primary | secondary | outline | text` para alinear con Angular (botones secundarios, “Cancelar”, etc.).
- **SocialLoginButton:** Mantener un solo componente; si hace falta, añadir variante “compact” para registro paso 2.

### 3.4 Snackbars y modales
- Centralizar en **LiquidGlassSnackBar** (eliminar uso de ErrorSnackbar donde sea redundante) y, si se quiere paridad con Angular, añadir `showSnackBar(context, type: success|error|warning|info, message, { action, duration })`.
- Crear **LiquidGlassModal** (o `showLiquidModal`) reutilizable: tipos info/success/warning/error/confirm, icono, título, mensaje, Aceptar/Cancelar, estilo glass. Así los diálogos de confirmación y mensajes críticos se ven igual que en Angular.

### 3.5 Navegación
- **ClientBottomNav / StoreBottomNav / ProviderBottomNav:** Recibir `currentIndex` derivado de la ruta actual (p. ej. con `GoRouter.of(context).routerDelegate.currentConfiguration.fullPath` o un wrapper que inyecte el índice) para que el ítem activo coincida con la URL.
- Opción: un **DashboardShell** único que reciba `currentIndex` y la lista de ítems y renderice el bottom nav + body, usado por cliente/tienda/prestador con distinta configuración.

### 3.6 Notificaciones
- **NotificationsPanel:** Ya está bien. Opcional: animación de entrada/salida y “pull to refresh” en la lista.

### 3.7 Mapas
- **TropicalMapWidget:** Documentar dependencia de Mapbox y manejo cuando el token falta. Opcional: widget **TrackingMapView** que encapsule mapa + leyenda (distancia, ETA, estado) y marcadores de usuario/proveedor para reutilizar en RequestTrackingPage y ClientTrackingPage.

### 3.8 Cards de dominio
- **UnifiedRequestCard:** Añadir animación ligera al tap (scale o highlight) y soporte para “arrastrar para refrescar” a nivel de lista si no existe.
- **QuickActionCard:** El texto “Ver más” está fijo; hacerlo opcional o parametrizable (p. ej. `actionLabel`).
- **ProductCard:** Ya incluye imagen, menú, etc. Opcional: skeleton de carga (shimmer) mientras llega la imagen.

---

## 4. Nuevos widgets sugeridos (paridad Angular)

### 4.1 Prioridad alta
1. **LiquidGlassModal**  
   Modal tipo info/success/warning/error/confirm con icono, título, mensaje, botones. Uso: confirmaciones, avisos, errores bloqueantes. Sustituiría varios `AlertDialog` sueltos.

2. **AddressPickerWidget** (o pantalla “address picker”)  
   Flujo: CP (opcional) → dirección texto → geocode → mapa con marker arrastrable → guardar. Reutilizable en perfil (direcciones), nueva solicitud (origen/destino) y checkout (dirección de entrega). Angular ya tiene este flujo muy pulido.

3. **ImageSourceBottomSheet**  
   Bottom sheet con “Galería” y “Tomar fotografía” (y Cancelar). Usar en edición de producto, perfil (avatar), subastas, etc., para no abrir solo galería por defecto.

### 4.2 Prioridad media
4. **CookieBanner**  
   Banner inferior con texto, “Aceptar todo”, “Solo esenciales”, “Preferencias”. Servicio `CookieConsentService` equivalente (SharedPreferences o secure storage) y mostrar solo hasta que el usuario decida.

5. **RatingsDisplayWidget**  
   Muestra promedio, desglose por estrellas y lista de reseñas. Consumir `RatingsRepository` y usarlo en detalle de solicitud completada o perfil de prestador.

6. **RatingFormWidget**  
   Formulario para enviar reseña (estrellas + comentario + fotos opcionales). Flujo post-servicio completado.

7. **Loading / Skeleton**  
   Widget reutilizable de “cargando” (spinner o skeleton con shimmer) para listas y cards. Angular usa “Cargando…” + a veces `animate-pulse`; en Flutter conviene un **LiquidGlassSkeleton** (card/lista con placeholders animados) para evitar parpadeo de contenido.

### 4.3 Prioridad baja
8. **PwaInstallPrompt**  
   Solo relevante en web; mostrar banner o botón “Instalar app” cuando sea instalable y el usuario no la haya instalado.

9. **SubscriptionBadge**  
   Pequeño badge “Activo” / “Vencido” / “Sin suscripción” reutilizable en navegación o perfil prestador.

10. **ServiceCategoryFilterChip**  
    Barra de chips por categoría de servicio (como en Angular) para filtrar en creación de solicitud o listados.

---

## 5. Resumen de acciones

| Acción | Impacto |
|--------|--------|
| Unificar uso de LiquidGlassTextField en todos los formularios | Consistencia visual con Angular |
| Crear LiquidGlassModal y sustituir AlertDialogs genéricos | Paridad con ModalComponent y UX unificada |
| Implementar ImageSourceBottomSheet (galería + cámara) | Paridad con Angular y mejor UX en móvil |
| Implementar AddressPicker (flujo CP/dirección/mapa) | Paridad con Angular y menos fricción en direcciones |
| Añadir variantes a GradientButton (outline, secondary) | Botones “Cancelar” y secundarios consistentes |
| Derivar currentIndex del router en bottom navs | Ítem activo correcto en deep links |
| CookieBanner + servicio de consentimiento | Paridad legal y transparencia |
| LiquidGlassSkeleton / loading unificado | Menos parpadeo y sensación más “completa” |
| RatingsDisplay + RatingForm | Paridad con reseñas en Angular |
| Documentar/centralizar SnackBar en LiquidGlassSnackBar | Un solo sistema de toasts |

Con esto los custom widgets de Flutter quedan alineados con la experiencia de Angular y se cubren los huecos más importantes (modales, direcciones, imagen, cookies, ratings, loading).
