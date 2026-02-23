import 'package:flutter/material.dart';

/// Variante visual del botón (paridad con Angular)
enum GradientButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Botón con gradiente estilo Liquid Glass (naranja → cyan)
/// Variantes: primary (gradiente), secondary (cyan sólido), outline, text.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final GradientButtonVariant variant;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.variant = GradientButtonVariant.primary,
  });

  static const Color _primaryStart = Color(0xFFf97316);
  static const Color _primaryEnd = Color(0xFF06b6d4);
  static const Color _secondaryBg = Color(0xFF0891b2);

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == GradientButtonVariant.primary;
    final isSecondary = variant == GradientButtonVariant.secondary;
    final isOutline = variant == GradientButtonVariant.outline;
    final isText = variant == GradientButtonVariant.text;

    final foregroundColor = isOutline || isText
        ? const Color(0xFF06b6d4)
        : Colors.white;

    BoxDecoration? decoration;
    if (isPrimary) {
      decoration = BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryStart, _primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: _primaryEnd.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
    } else if (isSecondary) {
      decoration = BoxDecoration(
        color: _secondaryBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      );
    } else if (isOutline) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFF06b6d4),
          width: 2,
        ),
      );
    }
    // text: no decoration

    Widget content = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foregroundColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );

    if (isText) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: content,
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(child: content),
        ),
      ),
    );
  }
}
