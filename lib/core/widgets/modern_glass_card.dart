import 'package:flutter/material.dart';
import 'package:glass/glass.dart';

/// Material 3 + Glassmorphism card widget using the `glass` package.
/// Lightweight, cross-platform, and modern looking.
class ModernGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double blurSigma;
  final double elevation;
  final Color tintColor;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const ModernGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.opacity = 0.15,
    this.blurSigma = 16,
    this.elevation = 8,
    this.tintColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: child,
    );

    final card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: content.asGlass(),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Simplified glass button for Material 3 + Glass aesthetic
class ModernGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double blurSigma;
  final Color? tintColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;

  const ModernGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.blurSigma = 16,
    this.tintColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = Colors.white;

    final content = Padding(
      padding: padding,
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(textColor ?? defaultTextColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor ?? defaultTextColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? defaultTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: content.asGlass(),
        ),
      ),
    );
  }
}

/// Glass container for generic content with Material 3 aesthetics
class ModernGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double blurSigma;
  final BorderRadius borderRadius;
  final BoxConstraints? constraints;
  final Color? backgroundColor;

  const ModernGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.opacity = 0.12,
    this.blurSigma = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.constraints,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: child,
    );

    final container = Container(
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: content.asGlass(),
      ),
    );

    return container;
  }
}
