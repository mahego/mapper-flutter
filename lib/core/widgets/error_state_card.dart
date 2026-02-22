import 'package:flutter/material.dart';
import '../widgets/liquid_glass_card.dart';

/// Widget reutilizable para mostrar errores en estado del UI
/// Proporciona estructura consistente para mostrar errores con iconografía
class ErrorStateCard extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showIcon;

  const ErrorStateCard({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.backgroundColor,
    this.textColor,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Icon(
                icon,
                size: 48,
                color: textColor ?? Colors.red.withOpacity(0.8),
              ),
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title!,
                style: TextStyle(
                  color: textColor ?? Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Text(
            message,
            style: TextStyle(
              color: textColor ?? Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para mostrar error inline (debajo de campos)
class InlineErrorText extends StatelessWidget {
  final String message;
  final bool show;
  final EdgeInsets padding;

  const InlineErrorText(
    this.message, {
    super.key,
    this.show = true,
    this.padding = const EdgeInsets.only(top: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget para mostrar notificación de error temporal
class ErrorSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}

/// Widget para mostrar un banner de error persistente
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;
  final bool showCloseButton;

  const ErrorBanner(
    this.message, {
    super.key,
    this.onClose,
    this.onRetry,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (onRetry != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: onRetry,
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showCloseButton)
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.6),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
