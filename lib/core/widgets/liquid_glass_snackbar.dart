import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helpers para mostrar SnackBars con estilo Liquid Glass
class LiquidGlassSnackBar {
  /// Muestra un SnackBar de error con texto seleccionable y botón de copiar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 8),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
        action: SnackBarAction(
          label: 'Copiar',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: message));
            showSuccess(context, 'Error copiado al portapapeles');
          },
        ),
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
      ),
    );
  }

  /// Muestra un SnackBar de información
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
      ),
    );
  }

  /// Muestra un SnackBar de advertencia
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: duration,
      ),
    );
  }
}
