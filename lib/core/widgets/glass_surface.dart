import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass surface helper for custom liquid-style UI without external packages.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final double highlightOpacity;
  final double noiseOpacity;
  final double edgeHighlightOpacity;
  final BorderRadius borderRadius;
  final bool showNoise;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = 18,
    this.opacity = 0.08,
    this.borderOpacity = 0.24,
    this.highlightOpacity = 0.32,
    this.noiseOpacity = 0.05,
    this.edgeHighlightOpacity = 0.3,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.showNoise = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(highlightOpacity),
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(edgeHighlightOpacity),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              if (showNoise)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NoisePainter(opacity: noiseOpacity),
                  ),
                ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;

  _NoisePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    final random = Random(7);
    final density = (size.width * size.height / 900).clamp(20, 220).toInt();

    for (var i = 0; i < density; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.4 + random.nextDouble() * 0.8;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
