import 'dart:ui';
import 'package:flutter/material.dart';

/// Tipo de modal (paridad con Angular ModalComponent)
enum LiquidGlassModalType {
  info,
  success,
  warning,
  error,
  confirm,
}

/// Modal reutilizable con estilo Liquid Glass.
/// Sustituye AlertDialog para mensajes y confirmaciones.
class LiquidGlassModal extends StatelessWidget {
  final LiquidGlassModalType type;
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;

  const LiquidGlassModal({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  });

  Color get _iconColor {
    switch (type) {
      case LiquidGlassModalType.info:
        return const Color(0xFF06b6d4);
      case LiquidGlassModalType.success:
        return const Color(0xFF22c55e);
      case LiquidGlassModalType.warning:
        return const Color(0xFFf59e0b);
      case LiquidGlassModalType.error:
        return const Color(0xFFef4444);
      case LiquidGlassModalType.confirm:
        return const Color(0xFF06b6d4);
    }
  }

  IconData get _icon {
    switch (type) {
      case LiquidGlassModalType.info:
        return Icons.info_outline;
      case LiquidGlassModalType.success:
        return Icons.check_circle_outline;
      case LiquidGlassModalType.warning:
        return Icons.warning_amber_outlined;
      case LiquidGlassModalType.error:
        return Icons.error_outline;
      case LiquidGlassModalType.confirm:
        return Icons.help_outline;
    }
  }

  String get _defaultConfirmLabel {
    switch (type) {
      case LiquidGlassModalType.confirm:
        return 'Aceptar';
      case LiquidGlassModalType.error:
        return 'Entendido';
      default:
        return 'Aceptar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: barrierDismissible ? () => Navigator.of(context).pop() : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icon, size: 48, color: _iconColor),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (cancelLabel != null && onCancel != null) ...[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                                onCancel?.call();
                              },
                              child: Text(
                                cancelLabel!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              onConfirm?.call();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _iconColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              confirmLabel ?? _defaultConfirmLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helpers estáticos para mostrar modales (paridad con Angular)
class LiquidGlassModalShow {
  /// Muestra un modal de confirmación. Retorna true si el usuario acepta, false si cancela.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.confirm,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
        barrierDismissible: barrierDismissible,
      ),
    );
    return result == true;
  }

  /// Modal de error (solo Aceptar)
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Entendido',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.error,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(ctx).pop(),
        barrierDismissible: true,
      ),
    );
  }

  /// Modal informativo
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.info,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(ctx).pop(),
        barrierDismissible: true,
      ),
    );
  }

  /// Modal de advertencia
  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.warning,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(ctx).pop(),
        barrierDismissible: true,
      ),
    );
  }

  /// Modal de éxito
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.success,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(ctx).pop(),
        barrierDismissible: true,
      ),
    );
  }
}
