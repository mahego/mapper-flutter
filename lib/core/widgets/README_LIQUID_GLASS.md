# Liquid Glass Effects

Este proyecto usa efectos de glassmorphism con dos enfoques:

## 1. Glassmorphism Simple (Uso General)

**Widget:** `LiquidGlassCard`, `LiquidGlassAppBar`, `LiquidGlassDrawer`, `LiquidGlassBottomNav`

**Características:**
- Backdrop blur (ImageFilter)
- Fondo translúcido con gradiente
- Bordes semi-transparentes
- Ligereza y rendimiento óptimo
- **Uso:** UI general, cards, navigation, overlays

**Ejemplo:**
```dart
LiquidGlassCard(
  borderRadius: 24,
  blurAmount: 20,
  child: Text('Contenido'),
);
```

## 2. Efectos de Lente Líquida Avanzados (Decorativo)

**Paquete:** `liquid_glass_easy` (v1.1.1)  
**Widget:** `LiquidGlassLensCard`, `LiquidGlassView`

**Características:**
- Distorsión y refracción de luz
- Aberración cromática
- Efectos de lente magnética
- Animaciones de lente arrastrables
- Múltiples modos de refracción (shape, radial)
- **Uso:** Efectos decorativos llamativos, demos, hero sections

**Ejemplo:**
```dart
LiquidGlassLensCard(
  lensWidth: 300,
  lensHeight: 80,
  distortion: 0.15,
  draggable: true,
  backgroundWidget: yourBackground,
);
```

## Comparación

| Característica | GlassmorphismSimple | Liquid Lens Effects |
|---------------|---------------------|---------------------|
| Rendimiento | ⚡ Excelente | 🔋 Moderado (requiere GPU) |
| Uso | UI general | Decorativo |
| Complejidad | Simple | Avanzado |
| Efectos | Blur + Translucidez | Refracción + Distorsión |
| Ejemplos Web | Angular Material Glass | Efectos 3D/WebGL |

## Cuándo Usar Cada Uno

### Usa Glassmorphism Simple cuando:
- Necesitas UI consistente y rápida
- Cards, navigation, overlays
- Compatibilidad con diseño Angular
- Prioridad: Rendimiento y legibilidad

### Usa Liquid Lens Effects cuando:
- Quieres efectos "wow" decorativos
- Hero sections, landing pages
- Elementos interactivos especiales
- Prioridad: Impacto visual

## Integración Actual

**Implementado:**
- ✅ LiquidGlassCard (simple glassmorphism)
- ✅ LiquidGlassAppBar (top nav)
- ✅ LiquidGlassDrawer (side menu)
- ✅ LiquidGlassBottomNav (bottom nav)
- ✅ LiquidGlassLensCard (efectos avanzados - nuevo)
- ✅ LiquidGlassLensExample (demo)

**Archivos:**
- `lib/core/widgets/liquid_glass_card.dart` - Glassmorphism simple
- `lib/core/widgets/liquid_glass_lens_card.dart` - Efectos de lente

## Ejemplo de Uso (Demo de Lentes)

Para ver los efectos de lente líquida en acción:

```dart
import 'package:mapper/core/widgets/liquid_glass_lens_card.dart';

// En tu router o navegación:
GoRoute(
  path: '/lens-demo',
  builder: (context, state) => const LiquidGlassLensExample(),
);
```

## Performance Tips

**Para efectos de lente:**
- Usa `pixelRatio` < 1.0 para mejor rendimiento
- `realTimeCapture: false` para contenido estático
- `refreshRate: LiquidGlassRefreshRate.low` para ahorrar batería
- Limita el número de lentes simultáneas (max 2-3)

**Para glassmorphism simple:**
- Ya está optimizado, no requiere ajustes
- Soporta múltiples cards sin impacto

## Referencias

- **liquid_glass_easy:** https://pub.dev/packages/liquid_glass_easy
- **Glassmorphism Design:** https://glassmorphism.com/
- **Angular Glass Effects:** Ver `fletapp-angular` styles.scss
