# Firebase Configuration Setup

Este archivo documenta cómo configurar Firebase de forma segura sin exponer claves públicamente.

## ⚠️ IMPORTANTE - Nunca commits

Los siguientes archivos **NUNCA** deben ser commiteados a git:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Estos archivos están en el `.gitignore` y contienen claves API sensibles.

## Configurar Firebase Localmente

### Option 1: Manual Setup (Local Development)

1. **Descarga tus archivos Firebase** desde [Firebase Console](https://console.firebase.google.com/):
   - Para Android: `google-services.json`
   - Para iOS: `GoogleService-Info.plist`

2. **Coloca los archivos en las ubicaciones correctas**:
   ```bash
   # Android
   cp ~/Downloads/google-services.json android/app/
   
   # iOS
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

3. **Verifica que NO estén staged en git**:
   ```bash
   git status
   # Estos no deben aparecer en la lista
   ```

### Option 2: CI/CD Pipeline (Recommended for Production)

Para GitHub Actions o similar, almacena los archivos como secrets:

```yaml
- name: Setup Firebase Config
  env:
    GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON }}
    GOOGLE_SERVICE_INFO_PLIST: ${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}
  run: |
    echo "$GOOGLE_SERVICES_JSON" | base64 -d > android/app/google-services.json
    echo "$GOOGLE_SERVICE_INFO_PLIST" | base64 -d > ios/Runner/GoogleService-Info.plist
```

## Files de Ejemplo

- `android/app/google-services.json.example` - Estructura para Android
- `ios/Runner/GoogleService-Info.plist.example` - Estructura para iOS

## Referencias

- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Firebase Setup Docs](https://firebase.flutter.dev/docs/overview/)
