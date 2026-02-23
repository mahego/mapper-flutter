import 'package:flutter/material.dart';

/// Skeleton de carga con estilo glass (shimmer) para listas y cards.
/// Paridad con Angular animate-pulse / loading unificado.
class LiquidGlassSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LiquidGlassSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Skeleton tipo línea de texto
  static Widget line({
    double? width,
    double height = 12,
    double borderRadius = 4,
  }) {
    return LiquidGlassSkeleton(
      width: width ?? 120,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Skeleton tipo avatar circular
  static Widget avatar({double size = 40}) {
    return LiquidGlassSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  /// Skeleton tipo card (rectángulo con bordes redondeados)
  static Widget card({
    double width = double.infinity,
    double height = 120,
    double borderRadius = 16,
  }) {
    return LiquidGlassSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  @override
  State<LiquidGlassSkeleton> createState() => _LiquidGlassSkeletonState();
}

class _LiquidGlassSkeletonState extends State<LiquidGlassSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width == double.infinity ? null : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.white.withOpacity(_animation.value * 0.12),
          ),
        );
      },
    );
  }
}

/// Lista de skeletons para una card de solicitud/pedido
class LiquidGlassSkeletonCard extends StatelessWidget {
  final bool showAvatar;
  final int lineCount;

  const LiquidGlassSkeletonCard({
    super.key,
    this.showAvatar = false,
    this.lineCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                LiquidGlassSkeleton.avatar(size: 40),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LiquidGlassSkeleton.line(width: 140, height: 14),
                    const SizedBox(height: 6),
                    LiquidGlassSkeleton.line(width: 100, height: 10),
                  ],
                ),
              ),
            ],
          ),
          ...List.generate(
            lineCount,
            (i) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: LiquidGlassSkeleton.line(
                width: i == lineCount - 1 ? 80 : null,
                height: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
