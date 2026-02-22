# Camera Permission Configuration

## iOS (Info.plist)

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para escanear códigos de barras de productos</string>
```

## Android (AndroidManifest.xml)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

## Platform-specific SDK requirements

### iOS
- Minimum version: iOS 11.0
- Update `ios/Podfile`:
  ```ruby
  platform :ios, '11.0'
  ```

### Android
- Minimum SDK: 21
- Compile SDK: 33+
- Update `android/app/build.gradle`:
  ```gradle
  android {
      compileSdk 33
      defaultConfig {
          minSdk 21
          targetSdk 33
      }
  }
  ```
