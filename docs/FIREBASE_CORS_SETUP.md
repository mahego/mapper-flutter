# Firebase Storage CORS Configuration

## Problema

Cuando Flutter Web intenta cargar imágenes desde Firebase Storage, pueden aparecer errores como:

```
NetworkImageLoadException: HTTP request failed, statusCode: 0
```

Esto ocurre por restricciones CORS (Cross-Origin Resource Sharing) en Firebase Storage.

## Solución Temporal

La aplicación ya maneja estos errores automáticamente:
- ✅ Muestra un icono de fallback cuando la imagen no carga
- ✅ Incluye un loading spinner mientras carga
- ✅ No afecta la funcionalidad del catálogo

## Solución Permanente: Configurar CORS

### Opción 1: Usar Google Cloud Shell (Recomendado)

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona tu proyecto Firebase
3. Abre Cloud Shell (icono `>_` en la esquina superior derecha)
4. Crea un archivo `cors.json`:

```bash
cat > cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
EOF
```

5. Aplica la configuración CORS:

```bash
gsutil cors set cors.json gs://envapp-7400e.firebasestorage.app
```

6. Verifica la configuración:

```bash
gsutil cors get gs://envapp-7400e.firebasestorage.app
```

### Opción 2: Instalar gsutil localmente

1. Instala [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Inicia sesión:

```bash
gcloud auth login
```

3. Configura el proyecto:

```bash
gcloud config set project envapp-7400e
```

4. Sigue los pasos 4-6 de la Opción 1

### Opción 3: CORS más restrictivo (Producción)

Para mayor seguridad, especifica solo los dominios permitidos:

```json
[
  {
    "origin": [
      "http://localhost:3000",
      "https://tu-dominio-produccion.com"
    ],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type"]
  }
]
```

## Verificación

Después de aplicar CORS:

1. Limpiar caché del navegador
2. Recargar la aplicación Flutter Web
3. Las imágenes deberían cargar correctamente
4. No deberían aparecer más errores de CORS en la consola

## Referencias

- [Firebase Storage CORS Documentation](https://firebase.google.com/docs/storage/web/download-files#cors_configuration)
- [gsutil CORS Configuration](https://cloud.google.com/storage/docs/gsutil/commands/cors)
- [Google Cloud SDK Installation](https://cloud.google.com/sdk/docs/install)

## Notas

- La configuración CORS solo es necesaria para **Flutter Web**
- **Flutter Mobile** (iOS/Android) no requiere configuración CORS
- El wildcard `"*"` permite cualquier origen (útil para desarrollo)
- Para producción, especifica dominios exactos
