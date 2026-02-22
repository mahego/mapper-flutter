import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass/liquid_glass.dart';

/// Card con efecto Liquid Glass (backdrop blur + border)
/// Usa el paquete liquid_glass para efectos mejorados
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurAmount;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.blurAmount = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: LiquidGlass(
        blur: blurAmount,
        opacity: 0.08,
        borderRadius: BorderRadius.circular(borderRadius),
        tint: Colors.white,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(32),
          child: child,
        ),
      ),
    );
  }
}
