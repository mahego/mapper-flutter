# 🎨 Material 3 + Glassmorphism - Quick Start

## Instalación

✅ Ya configurado en `pubspec.yaml`:
```yaml
glass: ^2.0.0+2
```

## Importes

```dart
// Opción 1: Todos los widgets
import 'package:mapper/core/widgets/glass_widgets.dart';

// Opción 2: Widgets individuales
import 'package:mapper/core/widgets/liquid_glass_card.dart';
import 'package:mapper/core/widgets/modern_glass_card.dart';
```

## Uso rápido

### Tarjeta simple
```dart
LiquidGlassCard(
  child: Text('Contenido'),
)
```

### Tarjeta con acción
```dart
ModernGlassCard(
  onTap: () => print('Presionado'),
  child: Row(children: [...]),
)
```

### Botón
```dart
ModernGlassButton(
  label: 'Crear',
  icon: Icons.add,
  onPressed: () => _create(),
  isLoading: false,
)
```

### Contenedor con formulario
```dart
ModernGlassContainer(
  child: Form(
    child: Column(children: [...]),
  ),
)
```

## Customización común

### Más transparente
```dart
LiquidGlassCard(
  opacity: 0.08,      // Default: 0.15
  blurAmount: 10,     // Default: 16
  child: child,
)
```

### Más opaco
```dart
ModernGlassCard(
  opacity: 0.25,      // Default: 0.12
  blurSigma: 20,      // Default: 16
  child: child,
)
```

### Color personalizado
```dart
ModernGlassCard(
  tintColor: Colors.blue.withOpacity(0.5),
  child: child,
)
```

## Performance

✨ **Recomendaciones por contexto:**

| Contexto | Widget | Blur | Razón |
|----------|--------|------|-------|
| Listas largas | ModernGlassCard | 10-12 | ↓ CPU |
| Elementos únicos | LiquidGlassCard | 16 | Balance |
| Formularios | ModernGlassContainer | 14 | Equilibrio |
| Botones | ModernGlassButton | 16 | Responsivo |

## ⚠️ Gotchas

### ❌ Doesn't work
```dart
// Glass necesita fondo detrás
Scaffold(
  backgroundColor: Colors.white,
  body: ModernGlassCard(child: child),  // ❌ No se ve bien
)
```

### ✅ Works
```dart
// Necesita algo detrás para que se vea el blur
LiquidGlassBackground(
  child: ModernGlassCard(child: child),  // ✅ Se ve bien
)
```

## Página demo

Para ver todos los widgets en acción:

```dart
import 'package:mapper/features/demonstration/glass_widgets_demo.dart';

// En tu router o navegación
GlassWidgetsDemo()
```

## Compatibilidad

✅ iOS, Android, Web, macOS, Windows, Linux

## Próximos pasos

1. Reemplazar `GlassSurface` directo con `LiquidGlassCard`
2. Usar `ModernGlassCard` en listas y tarjetas
3. Usar `ModernGlassButton` para acciones principales
4. Mantener `GlassSurface` para elementos especiales (menús, etc)

## Documentación completa

Ver: `lib/core/widgets/GLASS_WIDGETS_GUIDE.md`
