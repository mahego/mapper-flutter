# 📚 GUÍA DE USO - Servicios Homologados Flutter

**Estado:** Todos los repositorios principales implementados ✅

---

## 🎯 Servicios Implementados

### 1. **ProfileRepository** - Gestión de perfil de usuario
**Archivo:** `lib/features/auth/data/repositories/profile_repository.dart`

```dart
// Inyectar en tu página/notifier
final profileRepository = ProfileRepository(apiClient);

// Obtener perfil actual
final profile = await profileRepository.getProfile();

// Actualizar perfil
final updated = await profileRepository.updateProfile(
  name: 'Juan Pérez',
  phone: '3001234567',
  estado: 'Veracruz',
  ciudad: 'Xalapa',
);

// Cambiar contraseña
await profileRepository.changePassword(
  currentPassword: 'old_pass',
  newPassword: 'new_pass',
  confirmPassword: 'new_pass',
);

// Solicitar reset de contraseña
await profileRepository.forgotPassword('user@example.com');
```

---

### 2. **ServiceRepository** - CRUD de servicios del prestador
**Archivo:** `lib/features/provider/domain/repositories/service_repository.dart`

```dart
final serviceRepository = ServiceRepository(apiClient);

// Obtener mis servicios
final services = await serviceRepository.getMyServices();

// Obtener detalles de un servicio
final service = await serviceRepository.getServiceDetail(serviceId);

// Crear nuevo servicio
final newService = await serviceRepository.createService(
  categoryId: 1,
  title: 'Transporte urgente',
  description: 'Servicio de transporte express',
  serviceTypeIds: [1, 2],
  minPrice: 100,
  maxPrice: 500,
  pricePerKm: 15,
  coverageRadius: 20,
);

// Actualizar servicio
final updated = await serviceRepository.updateService(
  serviceId: 1,
  title: 'Nuevo título',
  pricePerKm: 18,
);

// Cambiar estado (activo/pausado)
await serviceRepository.updateServiceStatus(
  serviceId: 1,
  status: 'active', // o 'paused'
);

// Eliminar servicio
await serviceRepository.deleteService(serviceId);
```

---

### 3. **RatingsRepository** - Calificaciones y reseñas
**Archivo:** `lib/features/client/domain/repositories/ratings_repository.dart`

```dart
final ratingsRepository = RatingsRepository(apiClient);

// Enviar calificación
final rating = await ratingsRepository.submitRating(
  requestId: 123,
  rateeId: 456,
  rating: 5,
  title: 'Excelente servicio',
  comment: 'Muy puntual y profesional',
  categories: {'puntualidad': 5, 'profesionalismo': 5},
  anonymous: false,
);

// Obtener calificación de una solicitud
final requestRating = await ratingsRepository.getRatingForRequest(requestId);

// Obtener calificaciones de un usuario
final userRatings = await ratingsRepository.getUserRatings(userId, role: 'ratee');

// Obtener calificación promedio
final avgRating = await ratingsRepository.getUserAverageRating(userId);
// avgRating.average, avgRating.count, avgRating.breakdown

// Responder a una reseña
await ratingsRepository.respondToReview(ratingId, 'Gracias por tu feedback');

// Marcar reseña como útil
await ratingsRepository.markReviewHelpfulness(ratingId, true);

// Reportar reseña inapropiada
await ratingsRepository.flagReview(ratingId, 'Contenido ofensivo');
```

---

### 4. **SubscriptionRepository** - Gestión de suscripciones
**Archivo:** `lib/features/subscription/domain/repositories/subscription_repository.dart`

```dart
final subscriptionRepository = SubscriptionRepository(apiClient);

// Obtener suscripción actual
final currentSub = await subscriptionRepository.getCurrentSubscription();
if (currentSub != null) {
  print('Plan: ${currentSub.plan?.name}');
  print('Expira: ${currentSub.endDate}');
}

// Obtener planes disponibles
final plans = await subscriptionRepository.getAvailablePlans();
for (var plan in plans) {
  print('${plan.name}: \$${plan.price}/${plan.billingCycle}');
}

// Obtener detalles de un plan
final planDetail = await subscriptionRepository.getPlanDetails(planId);

// Crear/activar suscripción
final newSub = await subscriptionRepository.createSubscription(
  planId: 2,
  paymentMethodId: 'stripe_token_abc123',
);

// Procesar pago
final paymentResult = await subscriptionRepository.processSubscriptionPayment(
  subscriptionId: subId,
  paymentMethodId: 'stripe_token_abc123',
);

// Cancelar suscripción
await subscriptionRepository.cancelSubscription(subId);

// Renovar suscripción vencida
final renewed = await subscriptionRepository.renewSubscription(
  subscriptionId: subId,
  paymentMethodId: 'stripe_token_abc123',
);
```

---

### 5. **VehiclesRepository** - Gestión de vehículos
**Archivo:** `lib/features/provider/domain/repositories/vehicles_repository.dart`

```dart
final vehiclesRepository = VehiclesRepository(apiClient);

// Obtener todos los vehículos
final vehicles = await vehiclesRepository.getVehicles();

// Obtener detalles de un vehículo
final vehicle = await vehiclesRepository.getVehicleDetail(vehicleId);

// Crear nuevo vehículo
final newVehicle = await vehiclesRepository.createVehicle(
  licensePlate: 'ABC-123',
  brand: 'Nissan',
  model: 'Sentra',
  year: 2023,
  vehicleType: 'auto',
  color: 'Blanco',
  capacity: 500, // kg
);

// Actualizar vehículo
final updated = await vehiclesRepository.updateVehicle(
  vehicleId: 1,
  brand: 'Toyota',
  model: 'Corolla',
);

// Cambiar estado (activo/inactivo)
await vehiclesRepository.updateVehicleStatus(
  vehicleId: 1,
  active: true,
);

// Eliminar vehículo
await vehiclesRepository.deleteVehicle(vehicleId);
```

---

### 6. **PricingRepository** - Cálculo de precios
**Archivo:** `lib/features/pricing/domain/repositories/pricing_repository.dart`

```dart
final pricingRepository = PricingRepository(apiClient);

// Calcular precio estimado
final estimate = await pricingRepository.calculatePrice(
  serviceId: 1,
  originLat: 25.6866,
  originLng: -100.3161,
  destLat: 25.6867,
  destLng: -100.3180,
);
// estimate.basePrice, estimate.distanceKm, estimate.total, etc.

// Calcular distancia
final distance = await pricingRepository.calculateDistance(
  originLat: 25.6866,
  originLng: -100.3161,
  destLat: 25.6867,
  destLng: -100.3180,
);
// distance['distance_km'], distance['duration_minutes']

// Obtener configuración de precios para un servicio
final config = await pricingRepository.getServicePricing(serviceId);

// Obtener tasas generales
final rates = await pricingRepository.getPricingRates();

// Obtener configuración general
final generalConfig = await pricingRepository.getPricingConfig();
```

---

### 7. **CounteroffersRepository** - Contrapropuestas de precio
**Archivo:** `lib/features/request/domain/repositories/counteroffers_repository.dart`

```dart
final counteroffersRepository = CounteroffersRepository(apiClient);

// Crear contrapropuesta
final offer = await counteroffersRepository.createCounterOffer(
  requestId: 123,
  proposedPrice: 450,
  notes: 'Precio por combustible',
);

// Obtener contrapropuestas para una solicitud
final offers = await counteroffersRepository.getCounterOffersForRequest(requestId);

// Obtener detalles de una contrapropuesta
final offerDetail = await counteroffersRepository.getCounterOfferDetail(offerId);

// Aceptar contrapropuesta
final accepted = await counteroffersRepository.acceptCounterOffer(offerId);

// Rechazar contrapropuesta
final rejected = await counteroffersRepository.rejectCounterOffer(
  offerId,
  reason: 'Precio muy alto',
);

// Obtener historial
final history = await counteroffersRepository.getCounterOfferHistory(
  requestId: 123,
  status: 'pending',
  page: 1,
  limit: 20,
);

// Obtener resumen
final summary = await counteroffersRepository.getCounterOfferSummary(requestId);
```

---

### 8. **CatalogsRepository** - Búsqueda de catálogos
**Archivo:** `lib/features/catalog/domain/repositories/catalogs_repository.dart`

```dart
final catalogsRepository = CatalogsRepository(apiClient);

// Búsqueda simple
final results = await catalogsRepository.searchCatalogs(
  query: 'nissan',
  page: 1,
  limit: 10,
);
// results.items, results.total, results.totalPages

// Búsqueda avanzada
final advResults = await catalogsRepository.advancedSearch(
  query: 'sentra',
  brand: 'Nissan',
  yearFrom: 2020,
  yearTo: 2023,
  priceFrom: 10000,
  priceTo: 30000,
);

// Obtener detalles de un item
final item = await catalogsRepository.getCatalogItemDetail(itemId);

// Obtener categorías
final categories = await catalogsRepository.getAvailableCategories();

// Obtener marcas
final brands = await catalogsRepository.getAvailableBrands(category: 'vehículos');

// Obtener items destacados
final featured = await catalogsRepository.getFeaturedItems(limit: 5);
```

---

## 🔌 Inyección de Dependencias (GetIt)

Para usar fácilmente en toda la app:

```dart
// En tu setup de GetIt (main.dart o setup.dart)
final getIt = GetIt.instance;

// Registrar repositorios
getIt.registerSingleton<ProfileRepository>(
  ProfileRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<ServiceRepository>(
  ServiceRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<RatingsRepository>(
  RatingsRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<SubscriptionRepository>(
  SubscriptionRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<VehiclesRepository>(
  VehiclesRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<PricingRepository>(
  PricingRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<CounteroffersRepository>(
  CounteroffersRepository(getIt<ApiClient>()),
);
getIt.registerSingleton<CatalogsRepository>(
  CatalogsRepository(getIt<ApiClient>()),
);

// Usar en páginas/notifiers
class MyPage extends StatelessWidget {
  final profileRepo = getIt<ProfileRepository>();
  
  // ...
}
```

---

## 🌐 Endpoints Backend Validados

Todos los endpoints están implementados en el backend:

✅ `/auth/profile` - GET/PUT (perfil)
✅ `/auth/change-password` - POST
✅ `/auth/forgot-password` - POST
✅ `/auth/reset-password` - POST
✅ `/services` - GET/POST/PUT/DELETE
✅ `/services/my-services` - GET
✅ `/services/:id/status` - PATCH
✅ `/ratings` - POST/GET
✅ `/ratings/user/:id` - GET
✅ `/ratings/user/:id/average` - GET
✅ `/subscriptions` - GET/POST
✅ `/subscriptions/current` - GET
✅ `/subscriptions/payment` - POST
✅ `/vehicles` - GET/POST/PUT/DELETE
✅ `/pricing/calculate` - POST
✅ `/pricing/calculate-distance` - POST
✅ `/pricing/config` - GET
✅ `/counteroffers` - GET/POST
✅ `/counteroffers/:id/accept` - POST
✅ `/counteroffers/:id/reject` - POST
✅ `/catalogs/search` - GET
✅ `/catalogs/categories` - GET
✅ `/catalogs/brands` - GET

---

## 🚀 Próximos Pasos

1. **Crear Notifiers/Providers en Riverpod** para estos repositorios
2. **Integrar en páginas existentes** (ProfilePage, ServicePage, etc.)
3. **Crear tests unitarios** para cada repositorio
4. **Implementar caché local** con Isar para offline support
5. **Sincronización bidireccional** con el backend

---

## 📝 Notas Importantes

1. **Error Handling:** Todos los repositorios lanzan excepciones. Envuelve en try-catch en UI
2. **Token Auth:** El ApiClient maneja automáticamente los headers de autenticación
3. **Modelo de respuesta:** El backend devuelve `{ success, data: {...} }` - los mappers normalizan esto
4. **Consistencia:** Todos los endpoints usan snake_case en BD, camelCase en API
5. **Tipos de datos:** Los modelos manejan conversión automática de números a doubles, strings a enums

