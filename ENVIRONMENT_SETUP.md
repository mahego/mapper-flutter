# 🔐 Manejo de Secrets y Configuración

## Descripción

Este proyecto utiliza **flutter_dotenv** para manejar variables de entorno de forma segura. Los secretos (como el token de Mapbox) NO se commitean al repositorio.

## Configuración

### 1. Crear archivo `.env` local

Copia el archivo `.env.example` a `.env`:

```bash
cd mapper-flutter
cp .env.example .env
```

### 2. Obtener tu token de Mapbox

1. Ve a [Mapbox Account](https://account.mapbox.com/auth/signup/)
2. Crea una cuenta o inicia sesión
3. Ve a "Tokens" en el panel de control
4. Copia tu token público (empieza con `pk.`)
5. Pégalo en el archivo `.env`:

```env
MAPBOX_ACCESS_TOKEN=pk.your_actual_token_here
```

### 3. Variables de Entorno Disponibles

| Variable | Descripción | Requerida |
|----------|-------------|-----------|
| `MAPBOX_ACCESS_TOKEN` | Token de Mapbox para geocoding | ✅ Sí |
| `API_BASE_URL` | URL de la API (opcional si usas la default) | ❌ No |

### 4. Seguridad

⚠️ **IMPORTANTE:**
- El archivo `.env` **NUNCA** se commitea al repositorio (ya está en `.gitignore`)
- Usa `.env.example` como plantilla para el equipo
- En producción (Fly.io), configura variables de entorno en el panel de control

### 5. En Producción (Fly.io)

Para inyectar secrets en Fly.io:

```bash
# Ver secrets actuales
flyctl secrets list

# Configurar nuevo secret
flyctl secrets set MAPBOX_ACCESS_TOKEN=pk.your_production_token

# Remover secret
flyctl secrets unset MAPBOX_ACCESS_TOKEN
```

### 6. Verificación

La app imprime en consola:
- ✅ "Environment variables loaded successfully" - Variables cargadas
- ⚠️ ".env file not found" - Usando valores por defecto (desarrollo solo)
- 🔑 "Mapbox token loaded: pk.xxxx..." - Token configurado

## Implementación en Código

```dart
// En lib/core/constants/app_constants.dart
static late String mapboxAccessToken;

static void initialize() {
  mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'fallback_token';
}

// En lib/main.dart
void main() async {
  await dotenv.load(); // Carga .env
  AppConstants.initialize(); // Inicializa variables
  runApp(const MapperApp());
}
```

## Troubleshooting

### El token no se carga
1. Verifica que el archivo `.env` existe en `mapper-flutter/.env`
2. Asegúrate de que `pubspec.yaml` incluya `.env` en assets
3. Ejecuta `flutter clean && flutter pub get`

### Token no funciona para geocoding
1. Verifica que sea un token público (empieza con `pk.`)
2. Asegúrate de que Mapbox Geocoding esté habilitado en tu cuenta

### Error "LateInitializationError"
1. Verifica que `AppConstants.initialize()` se llama en `main()` antes de crear la app
2. Asegúrate de que `dotenv.load()` se llama antes de `AppConstants.initialize()`
