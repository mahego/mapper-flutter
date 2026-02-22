import 'package:flutter/material.dart';

/// Background con gradiente y orbs animados estilo Liquid Glass Tropical
class LiquidGlassBackground extends StatefulWidget {
  final Widget child;
  final bool showOrbs;

  const LiquidGlassBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  @override
  State<LiquidGlassBackground> createState() => _LiquidGlassBackgroundState();
}

class _LiquidGlassBackgroundState extends State<LiquidGlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0b1020),
            Color(0xFF0f172a),
            Color(0xFF111827),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated gradient orbs
          if (widget.showOrbs) ...[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  left: 50 + (100 * _animationController.value),
                  top: 50 + (80 * _animationController.value),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF06b6d4).withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  right: 50 + (80 * (1 - _animationController.value)),
                  top: 100 + (60 * _animationController.value),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFf97316).withOpacity(0.20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          // Content
          widget.child,
        ],
      ),
    );
  }
}
