# Configuración Pendiente para Flutter App

## ✅ YA CONFIGURADO

### Package Name
- ✅ Android: `com.mapper.app` en `build.gradle`
- ✅ iOS: Bundle ID debe configurarse en Xcode

### Permisos
- ✅ Android: Cámara, Ubicación, Internet en `AndroidManifest.xml`
- ✅ iOS: NSCameraUsageDescription, NSLocationUsageDescription en `Info.plist`

### Packages Instalados
- ✅ `mobile_scanner: ^5.2.3` - Barcode scanner
- ✅ `dio: ^5.4.0` - HTTP client
- ✅ `go_router: ^13.0.0` - Navegación
- ✅ `intl: ^0.19.0` - Formato de números/fechas

### Configuración
- ✅ Mapbox Token en `app_config.dart`
- ✅ API endpoints en `api_endpoints.dart`

---

## ❌ FALTA IMPLEMENTAR

### 1. SERVICIOS CRÍTICOS

#### Geolocalización (ALTA PRIORIDAD)
```dart
// lib/core/services/geolocation_service.dart
- getCurrentPosition() -> Ubicación actual del dispositivo
- watchPosition() -> Stream de ubicación en tiempo real
- Permisos de ubicación
- Manejo de errores (GPS desactivado, permiso denegado)
```

**Package requerido:**
```yaml
geolocator: ^10.1.0
```

#### Geocoding/Mapbox (ALTA PRIORIDAD)
```dart
// lib/core/services/geocoding_service.dart
- searchAddress(String query) -> Lista de direcciones
- reverseGeocode(lat, lng) -> Dirección desde coordenadas
- API de Mapbox Geocoding
```

**Package requerido:**
```yaml
http: ^1.1.0  # Para llamadas a Mapbox API
```

#### WebSocket/Tracking en Tiempo Real (ALTA PRIORIDAD)
```dart
// lib/core/services/socket_service.dart
- connect(token) -> Conexión Socket.IO
- joinTracking(requestId) -> Unirse a sala de tracking
- onTrackingUpdate -> Stream de actualizaciones de ubicación
- updateProviderLocation(lat, lng) -> Enviar ubicación del proveedor
```

**Package requerido:**
```yaml
socket_io_client: ^2.0.3
```

#### Firebase Services (ALTA)
```dart
// lib/core/services/firebase_storage_service.dart
- uploadImage(File image) -> Subir fotos (recibos, productos)
- deleteImage(String url) -> Eliminar imagen

// lib/core/services/fcm_service.dart
- initializeNotifications() -> Push notifications
- getToken() -> Token FCM
- onMessage -> Stream de notificaciones
```

**Packages requeridos:**
```yaml
firebase_core: ^2.24.2
firebase_storage: ^11.5.6
firebase_messaging: ^14.7.6
image_picker: ^1.0.5
```

**Configuración Firebase:**
- `google-services.json` en `android/app/`
- `GoogleService-Info.plist` en `ios/Runner/`
- Firebase project setup

#### Autenticación Completa (MEDIA)
```dart
// lib/core/services/auth_service.dart
- login(email, password) -> JWT token
- register(userData) -> Crear cuenta
- logout() -> Limpiar sesión
- refreshToken() -> Renovar token automático
- isAuthenticated() -> Validar sesión
- getCurrentUser() -> Datos del usuario
```

**Package requerido:**
```yaml
jwt_decoder: ^2.0.1
```

---

### 2. MAPAS Y UI

#### Componente de Mapa (ALTA)
```dart
// lib/core/widgets/map_widget.dart
- Mapa interactivo con Mapbox/Google Maps
- Marcadores para origen/destino
- Ruta entre dos puntos
- Marcador de proveedor en movimiento
```

**Opciones de packages:**
```yaml
# Opción 1: Google Maps (más común)
google_maps_flutter: ^2.5.0

# Opción 2: Mapbox (más personalizable)
mapbox_maps_flutter: ^1.0.0

# Opción 3: Open Source
flutter_map: ^6.0.0
latlong2: ^0.9.0
```

#### Address Picker (MEDIA)
```dart
// lib/core/widgets/address_picker_widget.dart
- Seleccionar ubicación en mapa
- Autocompletado de direcciones
- Geocoding inverso al mover mapa
```

#### Tracking Map (ALTA)
```dart
// lib/features/client/presentation/widgets/tracking_map.dart
- Mapa en tiempo real del proveedor
- Ruta actualizada dinámicamente
- ETA estimado
```

---

### 3. STORAGE Y PERSISTENCIA

#### Local Storage Service (MEDIA)
```dart
// lib/core/services/storage_service.dart
- saveToken(token) -> Guardar JWT
- getToken() -> Recuperar JWT
- saveUserData(user) -> Guardar datos de usuario
- clearAll() -> Logout completo
```

Ya tienes `shared_preferences`, solo falta implementar el wrapper.

---

### 4. PÁGINAS FALTANTES

#### Login/Register (ALTA)
```dart
// lib/features/auth/presentation/pages/
- login_page.dart
- register_page.dart
- forgot_password_page.dart
```

#### Provider Tracking Live (ALTA)
```dart
// lib/features/provider/presentation/pages/
- provider_tracking_page.dart -> Enviar ubicación en tiempo real
- active_service_page.dart -> Servicio activo con mapa
```

#### Client Tracking Live (ALTA)
```dart
// lib/features/client/presentation/pages/
- live_tracking_page.dart -> Ver ubicación del proveedor
- Ya existe client_tracking_page.dart pero falta conexión WebSocket
```

#### Store Delivery Tracking (MEDIA)
```dart
// lib/features/store/presentation/pages/
- store_delivery_tracking_page.dart -> Tracking de entregas de la tienda
```

---

### 5. CONFIGURACIÓN DE FIREBASE

#### Android (`android/app/google-services.json`)
```json
{
  "project_info": {
    "project_number": "TU_PROJECT_NUMBER",
    "firebase_url": "https://TU_PROJECT.firebaseio.com",
    "project_id": "TU_PROJECT_ID",
    "storage_bucket": "TU_PROJECT.appspot.com"
  },
  ...
}
```

#### iOS (`ios/Runner/GoogleService-Info.plist`)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CLIENT_ID</key>
  <string>TU_CLIENT_ID</string>
  ...
</dict>
</plist>
```

---

### 6. CONFIGURACIÓN iOS ADICIONAL

#### Podfile (`ios/Podfile`)
```ruby
platform :ios, '12.0'  # Mínimo iOS 12

# Si usas Google Maps
pod 'GoogleMaps'

# Si usas Firebase
pod 'FirebaseCore'
pod 'FirebaseMessaging'
pod 'FirebaseStorage'
```

Ejecutar después de agregar pods:
```bash
cd ios && pod install
```

---

## 📊 RESUMEN DE PRIORIDADES

### CRÍTICO (Sin esto NO funciona)
1. ✅ ~~Barcode Scanner~~ (YA HECHO)
2. ❌ Geolocalización Service
3. ❌ WebSocket/Socket.IO Service
4. ❌ Auth Service completo
5. ❌ Login/Register Pages
6. ❌ Mapas (Google Maps o Mapbox)

### ALTA (Funcionalidad clave)
7. ❌ Geocoding Service (Mapbox)
8. ❌ Firebase Storage (fotos)
9. ❌ FCM Notifications
10. ❌ Tracking en tiempo real (provider/client)

### MEDIA (Mejora UX)
11. ❌ Address Picker
12. ❌ Local Storage Service wrapper
13. ❌ Error handling global

### BAJA (Nice to have)
14. ❌ Analytics
15. ❌ Crashlytics
16. ❌ Deep linking

---

## 🚀 SIGUIENTE PASO RECOMENDADO

Implementar en este orden:

1. **Auth Service + Login/Register** (1-2 horas)
2. **Geolocation Service** (30 min)
3. **Socket.IO Service** (1 hora)
4. **Google Maps Widget** (1-2 horas)
5. **Geocoding Service** (30 min)
6. **Firebase Setup** (1 hora)
7. **Tracking Pages** (2-3 horas)

**Total estimado: 8-12 horas de desarrollo**

---

## 📦 PACKAGES COMPLETOS NECESARIOS

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Navigation
  go_router: ^13.0.0
  
  # Network
  dio: ^5.4.0
  socket_io_client: ^2.0.3
  http: ^1.1.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Location & Maps
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  google_maps_flutter: ^2.5.0
  
  # Barcode Scanner
  mobile_scanner: ^5.2.3
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.6
  firebase_storage: ^11.5.6
  
  # Images
  image_picker: ^1.0.5
  
  # Auth
  jwt_decoder: ^2.0.1
  
  # UI Components
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  
  # Utilities
  intl: ^0.19.0
  logger: ^2.0.2+1
  permission_handler: ^11.0.1
```
