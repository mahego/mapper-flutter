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
    // Paridad con Angular .liquid-aurora-bg
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.7, 0.5),
          end: Alignment(-0.5, 0.5),
          stops: [0.0, 0.35, 0.7, 1.0],
          colors: [
            Color(0xFF0b1020),
            Color(0xFF0e1a32),
            Color(0xFF0c1326),
            Color(0xFF050a14),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Radial gradients (paridad Angular liquid-aurora: 10% 20%, 80% 0%, 25% 80%)
          if (widget.showOrbs) ...[
            Positioned(
              left: -40,
              top: 80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 0,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 80,
              bottom: 120,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFEC4899).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
          widget.child,
        ],
      ),
    );
  }
}
