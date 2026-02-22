# Configuración de Firebase para Mapper Flutter

## Resumen de cambios implementados

Se ha implementado la autenticación social (Google y Facebook) en la aplicación Flutter, homologando el comportamiento con la aplicación Angular.

### Archivos nuevos creados:

1. **`lib/core/services/firebase_auth_service.dart`** - Servicio para autenticación con Firebase
2. **`lib/core/widgets/social_login_button.dart`** - Componente reutilizable para botones sociales con diseño Liquid Glass

### Archivos modificados:

1. **`pubspec.yaml`** - Añadidas dependencias de Firebase
2. **`lib/features/auth/presentation/pages/login_page.dart`** - Añadidos botones de Google y Facebook
3. **`lib/features/auth/presentation/pages/register_page.dart`** - Añadidos botones de Google y Facebook
4. **`lib/features/auth/domain/entities/user.dart`** - Añadido campo `needsCompleteProfile`
5. **`lib/core/network/api_endpoints.dart`** - Añadido endpoint `/auth/firebase-login`
6. **`lib/features/auth/domain/repositories/auth_repository.dart`** - Añadido método `loginWithFirebase`
7. **`lib/features/auth/data/repositories/auth_repository_impl.dart`** - Implementado `loginWithFirebase`
8. **`lib/core/services/auth_service.dart`** - Añadido método `loginWithSocial`

## Pasos para completar la configuración

### 1. Instalar dependencias

```bash
cd mapper-flutter
flutter pub get
```

### 2. Configurar Firebase en la consola

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto existente o crea uno nuevo
3. En **Authentication → Sign-in method**, habilita:
   - Google (ya debe estar habilitado)
   - Facebook (si aún no está configurado)

### 3. Configurar Firebase para Android

#### 3.1 Descargar google-services.json

1. En Firebase Console, ve a **Project Settings**
2. En la sección **Your apps**, selecciona tu app Android
3. Descarga el archivo `google-services.json`
4. Copia el archivo a `mapper-flutter/android/app/`

#### 3.2 Actualizar android/build.gradle

Asegúrate de que el archivo `android/build.gradle` contenga:

```gradle
buildscript {
    dependencies {
        // ... otras dependencias
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 3.3 Actualizar android/app/build.gradle

Al final del archivo `android/app/build.gradle`, añade:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Configurar Firebase para iOS

#### 4.1 Descargar GoogleService-Info.plist

1. En Firebase Console, ve a **Project Settings**
2. En la sección **Your apps**, selecciona tu app iOS
3. Descarga el archivo `GoogleService-Info.plist`
4. Abre `mapper-flutter/ios/Runner.xcworkspace` en Xcode
5. Arrastra el archivo `GoogleService-Info.plist` al proyecto en Xcode, dentro de la carpeta `Runner`

### 5. Configurar Google Sign In

#### 5.1 Android

El archivo `google-services.json` ya contiene toda la configuración necesaria.

#### 5.2 iOS

1. Abre `mapper-flutter/ios/Runner/Info.plist`
2. Añade el siguiente código antes del tag `</dict>`:

```xml
<!-- Google Sign In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplaza con tu REVERSED_CLIENT_ID de GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**Nota:** Encuentra tu `REVERSED_CLIENT_ID` en el archivo `GoogleService-Info.plist` que descargaste.

### 6. Configurar Facebook Login

#### 6.1 Crear app en Facebook Developers

1. Ve a [Facebook Developers](https://developers.facebook.com/)
2. Crea una nueva app o usa una existente
3. En **Settings → Basic**, obtén tu **App ID** y **App Secret**
4. En Firebase Console, ve a **Authentication → Sign-in method → Facebook**
5. Habilita Facebook y pega tu **App ID** y **App Secret**
6. Copia la **OAuth redirect URI** que te proporciona Firebase
7. De vuelta en Facebook Developers, ve a **Facebook Login → Settings**
8. Pega la **OAuth redirect URI** en **Valid OAuth Redirect URIs**

#### 6.2 Android

1. Abre `mapper-flutter/android/app/src/main/res/values/strings.xml` (créalo si no existe)
2. Añade:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Mapper</string>
    <string name="facebook_app_id">TU_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbTU_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">TU_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

3. Abre `mapper-flutter/android/app/src/main/AndroidManifest.xml`
4. Dentro de `<application>`, añade:

```xml
<meta-data 
    android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>

<meta-data 
    android:name="com.facebook.sdk.ClientToken" 
    android:value="@string/facebook_client_token"/>

<activity 
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />

<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

#### 6.3 iOS

1. Abre `mapper-flutter/ios/Runner/Info.plist`
2. Añade antes del tag `</dict>`:

```xml
<!-- Facebook Login -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbTU_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>
<key>FacebookAppID</key>
<string>TU_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>TU_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Mapper</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
</array>
```

### 7. Inicializar Firebase en la app

Crea el archivo `lib/main.dart` o actualízalo para inicializar Firebase:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ... otros imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'TU_API_KEY',
      appId: 'TU_APP_ID',
      messagingSenderId: 'TU_MESSAGING_SENDER_ID',
      projectId: 'TU_PROJECT_ID',
      // Android
      androidGoogleAppId: 'TU_ANDROID_APP_ID',
      // iOS
      iosGoogleAppId: 'TU_IOS_APP_ID',
      iosBundleId: 'com.tu.bundleid',
    ),
  );
  
  runApp(const MyApp());
}
```

**Nota:** Obtén estos valores de los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).

### 8. Flujo de autenticación implementado

#### Login/Register con Google o Facebook:

1. Usuario hace clic en botón "Google" o "Facebook"
2. Se abre el flujo de autenticación nativo (popup/redirect)
3. Usuario autoriza la aplicación
4. Firebase retorna un `User` con un ID token
5. La app envía el ID token al backend (`POST /auth/firebase-login`)
6. El backend:
   - Verifica el token con Firebase Admin SDK
   - Crea o encuentra el usuario en la base de datos
   - Retorna un JWT propio + flag `needsCompleteProfile`
7. Si `needsCompleteProfile === true`, redirige a `/auth/complete-profile`
8. Si no, redirige al dashboard según el rol del usuario

### 9. Página Complete Profile (pendiente)

Similar a Angular, necesitarás crear una página para completar el perfil cuando el usuario se registra con Google/Facebook por primera vez. Esta página debe:

- Permitir seleccionar el rol (cliente, prestador, tienda)
- Solicitar información adicional según el rol (dirección, teléfono, vehículo, etc.)
- Enviar la información al backend para completar el perfil

### 10. Testing

#### Probar Google Sign In:

```bash
flutter run -d chrome
```

1. Haz clic en "Google" en Login o Register
2. Selecciona una cuenta de Google
3. Autoriza la aplicación
4. Verifica que se redirige correctamente

#### Probar Facebook Login:

1. Asegúrate de tener la app en modo de desarrollo en Facebook Developers
2. Añade tu cuenta de prueba en Facebook Developers → Roles → Test Users
3. Haz clic en "Facebook" en Login o Register
4. Autoriza la aplicación

### 11. Notas importantes

- **Web:** Google Sign In funciona out-of-the-box en web. Facebook requiere configurar el SDK de JavaScript.
- **SHA-1:** Para Android, necesitas generar y añadir tu SHA-1 fingerprint en Firebase Console.
- **Bundle ID:** Para iOS, asegúrate de que el Bundle ID en Xcode coincida con el configurado en Firebase.
- **Testing devices:** Añade las huellas digitales de tus dispositivos de prueba en Firebase Console.

### 12. Troubleshooting

#### Error: "PlatformException(sign_in_failed)"
- Verifica que `google-services.json` (Android) o `GoogleService-Info.plist` (iOS) estén correctamente configurados
- Verifica el SHA-1 fingerprint en Firebase Console

#### Error: "Facebook login failed"
- Verifica el Facebook App ID y Client Token
- Asegúrate de que la app esté en modo de desarrollo o que el usuario sea tester
- Verifica las OAuth Redirect URIs en Facebook Developers

#### Error: "needsCompleteProfile is always true"
- El backend marca `needsCompleteProfile = true` si:
  - Es un usuario nuevo (`isNewUser = true`)
  - El usuario tiene contraseña placeholder y nunca completó perfil (`oauth_profile_completed = false`)
- Implementa la página de complete-profile para resolver esto

### 13. Próximos pasos

1. ✅ Ejecutar `flutter pub get`
2. ⬜ Configurar Firebase en la consola
3. ⬜ Descargar y añadir archivos de configuración (google-services.json, GoogleService-Info.plist)
4. ⬜ Configurar Google Sign In (URL schemes en iOS)
5. ⬜ Configurar Facebook Login (App ID, strings.xml, Info.plist)
6. ⬜ Inicializar Firebase en main.dart
7. ⬜ Crear página de complete-profile
8. ⬜ Probar en dispositivos/emuladores

## Recursos adicionales

- [Firebase Console](https://console.firebase.google.com/)
- [Google Sign In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Flutter Facebook Auth Package](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
