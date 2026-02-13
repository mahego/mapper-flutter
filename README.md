# Mapper - Delivery App

Una aplicación de delivery construida con Flutter siguiendo las mejores prácticas del mercado actual.

## 🚀 Características

- ✅ Arquitectura limpia por features
- ✅ Gestión de estado con BloC
- ✅ Navegación con GoRouter
- ✅ Temas claro y oscuro
- ✅ Material Design 3
- ✅ Compatible con iOS y Android
- ✅ Tipografía personalizada con Google Fonts

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/      # Constantes de la aplicación
│   ├── router/         # Configuración de navegación
│   └── theme/          # Temas y estilos
├── features/
│   ├── home/           # Pantalla principal
│   ├── orders/         # Gestión de pedidos
│   └── profile/        # Perfil de usuario
└── shared/
    └── widgets/        # Widgets compartidos
```

## 🛠️ Requisitos

- Flutter SDK: >=3.0.0 <4.0.0
- Dart: >=3.0.0 <4.0.0

## 📦 Dependencias Principales

- **flutter_bloc**: Gestión de estado
- **go_router**: Navegación declarativa
- **dio**: Cliente HTTP
- **shared_preferences**: Almacenamiento local
- **google_fonts**: Tipografías personalizadas
- **equatable**: Comparación de objetos

## 🚀 Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/mahego/mapper-flutter.git
cd mapper-flutter
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## 🏗️ Comandos Útiles

### Análisis de código
```bash
flutter analyze
```

### Formatear código
```bash
flutter format lib/
```

### Ejecutar tests
```bash
flutter test
```

### Generar build
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## 📱 Plataformas Soportadas

- ✅ Android (API 21+)
- ✅ iOS (12.0+)

## 🎨 Tema

La aplicación soporta temas claro y oscuro que se adaptan automáticamente a la preferencia del sistema.

## 🏛️ Arquitectura

El proyecto sigue una arquitectura por features:
- **core**: Funcionalidades compartidas (temas, navegación, constantes)
- **features**: Módulos independientes por funcionalidad
- **shared**: Componentes reutilizables

## 📝 Licencia

Este proyecto está bajo la licencia MIT.
