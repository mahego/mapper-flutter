import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import 'glass_surface.dart';

/// Card con efecto glass moderno (Material 3 + Glassmorphism)
/// Usa la librería `glass` para mejor rendimiento y consistencia cross-platform
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurAmount;
  final double opacity;
  final bool useModernGlass;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.blurAmount = 16.0,
    this.opacity = 0.15,
    this.useModernGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    final container = SizedBox(
      width: width,
      height: height,
      child: useModernGlass
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: content,
              ).asGlass(),
            )
          : GlassSurface(
              blur: blurAmount,
              borderRadius: BorderRadius.circular(borderRadius),
              padding: const EdgeInsets.all(0),
              opacity: opacity,
              child: content,
            ),
    );

    return container;
  }
}
