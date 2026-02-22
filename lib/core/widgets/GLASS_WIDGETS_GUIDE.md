# Material 3 + Glassmorphism Widgets Guide

Esta guía explica cómo usar los nuevos widgets que combinan **Material 3** con **Glassmorphism** usando la librería `glass`.

## 📦 Paquetes utilizados

- **glass**: ^0.2.0 - Glassmorphism nativo, cross-platform
- **flutter/material.dart** - Material 3 icons y theming

## 🎨 Widgets disponibles

### 1. `LiquidGlassCard` (Recomendado)

Reemplaza la versión anterior. Ahora usa la librería `glass` por defecto.

```dart
import 'package:mapper/core/widgets/liquid_glass_card.dart';

LiquidGlassCard(
  padding: const EdgeInsets.all(20),
  borderRadius: 16,
  blurAmount: 16,
  opacity: 0.15,
  child: Column(
    children: [
      Text('Mi contenido', style: TextStyle(color: Colors.white)),
    ],
  ),
)
```

**Parámetros:**
- `child` - Widget dentro de la tarjeta
- `padding` - Espaciado interno (default: 16)
- `width/height` - Dimensiones opcionales
- `borderRadius` - Radio de las esquinas (default: 16)
- `blurAmount` - Intensidad del blur (default: 16)
- `opacity` - Transparencia del tinte (default: 0.15)
- `useModernGlass` - Usa `glass` si es `true`, `GlassSurface` si es `false`

### 2. `ModernGlassCard`

Tarjeta con más opciones y mejor control.

```dart
import 'package:mapper/core/widgets/modern_glass_card.dart';

ModernGlassCard(
  padding: const EdgeInsets.all(16),
  opacity: 0.12,
  blurSigma: 14,
  onTap: () => Navigator.push(context, route),
  child: Row(
    children: [
      Icon(Icons.shopping_bag, color: Colors.white),
      SizedBox(width: 12),
      Text('Mi tarjeta', style: TextStyle(color: Colors.white70)),
    ],
  ),
)
```

**Parámetros extra:**
- `onTap` - Callback cuando se presiona
- `tintColor` - Color del tinte (default: Colors.white)
- `elevation` - Elevación (para futuro)

### 3. `ModernGlassButton`

Botón con efecto glass integrado.

```dart
ModernGlassButton(
  label: 'Crear solicitud',
  icon: Icons.add,
  blurSigma: 16,
  onPressed: () => _createRequest(),
)
```

**Parámetros:**
- `label` - Texto del botón
- `onPressed` - Callback
- `isLoading` - Muestra spinner si es true
- `icon` - IconData opcional
- `tintColor` - Color del glass
- `textColor` - Color del texto

### 4. `ModernGlassContainer`

Contenedor genérico con glass effect y constraints.

```dart
ModernGlassContainer(
  padding: const EdgeInsets.all(20),
  constraints: BoxConstraints(maxWidth: 400),
  child: Form(
    child: Column(children: [...]),
  ),
)
```

## 🔄 Migración desde líquido glass anterior

### Antes (GlassSurface directo):
```dart
GlassSurface(
  blur: 18,
  borderRadius: BorderRadius.circular(24),
  padding: const EdgeInsets.all(16),
  child: MyWidget(),
)
```

### Después (LiquidGlassCard actualizado):
```dart
LiquidGlassCard(
  borderRadius: 16,  // Cambió de 24 a 16 (Material 3)
  blurAmount: 16,    // Cambió de 18 a 16 (más peso performance)
  padding: const EdgeInsets.all(16),
  child: MyWidget(),
)
```

## 🎯 Comparación de rendimiento

| Widget | Blur | Noise | Gradient | CPU | Recomendación |
|--------|------|-------|----------|-----|---------------|
| GlassSurface | ✅ | ✅ | ✅ | Alto | Menú especiales |
| LiquidGlassCard (modern) | ✅ | ❌ | ❌ | Bajo | Uso general |
| ModernGlassCard | ✅ | ❌ | ❌ | Muy bajo | Tarjetas, lists |
| ModernGlassButton | ✅ | ❌ | ❌ | Muy bajo | Acciones |

## 🎨 Personalizaciones comunes

### Oscuro (`dark_mode`)
```dart
ModernGlassCard(
  tintColor: Colors.black.withOpacity(0.3),
  opacity: 0.2,
  child: Text('Oscuro', style: TextStyle(color: Colors.white)),
)
```

### Colorido (branded)
```dart
ModernGlassCard(
  tintColor: Colors.blue.withOpacity(0.5),
  opacity: 0.25,
  child: child,
)
```

### Minimalista
```dart
ModernGlassCard(
  opacity: 0.08,      // Menos tinte
  blurSigma: 8,       // Menos blur
  child: child,
)
```

## 📱 Compatibilidad

Todos los widgets soportan:
- ✅ iOS/Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## ⚡ Tips de optimización

1. **Para listas largas**: Usa `ModernGlassCard` (menos procesamiento)
2. **Para elementos únicos**: Usa `LiquidGlassCard` con `useModernGlass: true`
3. **Para fallback**: `useModernGlass: false` usa `GlassSurface`
4. **Blur moderado**: 12-16 es suficiente, >20 = performance hit

## 🐛 Troubleshooting

### ¿El glass effect no se ve?
Verifica que haya contenido detrás con blur. Si está sobre fondo sólido, no se nota.

```dart
// ❌ No funciona bien
Scaffold(
  backgroundColor: Colors.white,
  body: ModernGlassCard(child: Text('No se ve bien')),
)

// ✅ Funciona bien
LiquidGlassBackground(
  child: ModernGlassCard(child: Text('Se ve bien')),
)
```

### ¿Performance baja en web?
Reduce `blurSigma` de 16 a 10:
```dart
ModernGlassCard(blurSigma: 10, child: child)
```

## 📚 Ejemplos reales en el proyecto

- `client_dashboard_page.dart` - LiquidGlassCard para tarjetas
- `new_request_page.dart` - ModernGlassContainer para formularios
- `client_checkout_page.dart` - ModernGlassButton para acciones
