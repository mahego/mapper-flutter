import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tipo de snackbar (paridad con Angular SnackbarService)
enum SnackbarType { success, error, warning, info }

/// Acción opcional del snackbar (ej. Reintentar, Copiar)
class SnackbarAction {
  final String label;
  final VoidCallback callback;
  const SnackbarAction({required this.label, required this.callback});
}

/// Opciones del snackbar (paridad con Angular SnackbarOptions)
class SnackbarOptions {
  final Duration duration;
  final SnackbarAction? action;
  const SnackbarOptions({
    this.duration = const Duration(seconds: 5),
    this.action,
  });
}

/// Snackbar unificado para gestión de errores y notificaciones.
/// Paridad con Angular: SnackbarService (success, error, warning, info, errorWithRetry).
class LiquidGlassSnackBar {
  static const _maxWidth = 512.0;
  static const _borderRadius = 12.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  /// Convierte [message] a String (si es Exception usa mensaje legible).
  static String _messageToString(dynamic message) {
    if (message is Exception) {
      final s = message.toString();
      if (s.startsWith('Exception: ')) return s.substring(11);
      return s;
    }
    return message?.toString() ?? 'Error desconocido';
  }

  static void _show(
    BuildContext context,
    SnackbarType type,
    String message, {
    required Duration duration,
    SnackbarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          type: type,
          message: message,
          actionLabel: action?.label,
          onAction: action == null
              ? null
              : () {
                  messenger.hideCurrentSnackBar();
                  action.callback();
                },
          onDismiss: () => messenger.hideCurrentSnackBar(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// Éxito (verde)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackbarAction? action,
  }) {
    _show(context, SnackbarType.success, message, duration: duration, action: action);
  }

  /// Error (rojo). [message] puede ser String o Exception.
  /// Si [showCopyButton] es true, se añade botón "Copiar" al portapapeles (no se usa si [action] está definido).
  static void showError(
    BuildContext context,
    dynamic message, {
    Duration duration = const Duration(seconds: 8),
    SnackbarAction? action,
    bool showCopyButton = true,
  }) {
    final text = _messageToString(message);
    final effectiveAction = action ??
        (showCopyButton
            ? SnackbarAction(
                label: 'Copiar',
                callback: () {
                  Clipboard.setData(ClipboardData(text: text));
                  showSuccess(context, 'Error copiado al portapapeles', duration: const Duration(seconds: 2));
                },
              )
            : null);
    _show(context, SnackbarType.error, text, duration: duration, action: effectiveAction);
  }

  /// Error con botón "Reintentar" (paridad Angular errorWithRetry).
  static void errorWithRetry(
    BuildContext context,
    dynamic message,
    VoidCallback retry, {
    Duration duration = const Duration(seconds: 8),
  }) {
    showError(
      context,
      message,
      duration: duration,
      action: SnackbarAction(label: 'Reintentar', callback: retry),
    );
  }

  /// Advertencia (naranja)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    SnackbarAction? action,
  }) {
    _show(context, SnackbarType.warning, message, duration: duration, action: action);
  }

  /// Información (azul)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackbarAction? action,
  }) {
    _show(context, SnackbarType.info, message, duration: duration, action: action);
  }

  /// Cierra el snackbar actual.
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

class _SnackbarContent extends StatelessWidget {
  final SnackbarType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const _SnackbarContent({
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  Color get _gradientStart {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF059669);
      case SnackbarType.error:
        return const Color(0xFFdc2626);
      case SnackbarType.warning:
        return const Color(0xFFd97706);
      case SnackbarType.info:
        return const Color(0xFF0284c7);
    }
  }

  Color get _gradientEnd {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF047857);
      case SnackbarType.error:
        return const Color(0xFFb91c1c);
      case SnackbarType.warning:
        return const Color(0xFFb45309);
      case SnackbarType.info:
        return const Color(0xFF0369a1);
    }
  }

  IconData get _icon {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_rounded;
      case SnackbarType.error:
        return Icons.error_rounded;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: LiquidGlassSnackBar._maxWidth),
      child: Container(
        padding: LiquidGlassSnackBar._padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_gradientStart, _gradientEnd],
          ),
          borderRadius: BorderRadius.circular(LiquidGlassSnackBar._borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
