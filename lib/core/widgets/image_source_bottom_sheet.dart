import 'package:flutter/material.dart';

/// Origen de imagen (paridad con Angular ImageSourceBottomSheetComponent)
enum ImageSourceOption {
  gallery,
  camera,
}

/// Bottom sheet para elegir Galería o Cámara (y Cancelar).
/// Uso: final option = await ImageSourceBottomSheet.show(context);
class ImageSourceBottomSheet extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<ImageSourceOption>? onSelected;
  final VoidCallback? onClose;

  const ImageSourceBottomSheet({
    super.key,
    required this.isOpen,
    this.onSelected,
    this.onClose,
  });

  /// Muestra el bottom sheet y retorna la opción elegida o null si cancela.
  static Future<ImageSourceOption?> show(BuildContext context) async {
    return showModalBottomSheet<ImageSourceOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _ImageSourceBottomSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: _buildSheetContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecciona una opción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            label: 'Importar de Galería',
            icon: Icons.photo_library_outlined,
            onTap: () {
              onSelected?.call(ImageSourceOption.gallery);
              onClose?.call();
            },
          ),
          const SizedBox(height: 8),
          _OptionButton(
            label: 'Tomar fotografía',
            icon: Icons.camera_alt_outlined,
            onTap: () {
              onSelected?.call(ImageSourceOption.camera);
              onClose?.call();
            },
          ),
          const SizedBox(height: 8),
          _OptionButton(
            label: 'Cancelar',
            icon: Icons.close,
            onTap: onClose,
            isSecondary: true,
          ),
        ],
      ),
    );
  }
}

class _ImageSourceBottomSheetContent extends StatelessWidget {
  const _ImageSourceBottomSheetContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecciona una opción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            label: 'Importar de Galería',
            icon: Icons.photo_library_outlined,
            onTap: () => Navigator.of(context).pop(ImageSourceOption.gallery),
          ),
          const SizedBox(height: 8),
          _OptionButton(
            label: 'Tomar fotografía',
            icon: Icons.camera_alt_outlined,
            onTap: () => Navigator.of(context).pop(ImageSourceOption.camera),
          ),
          const SizedBox(height: 8),
          _OptionButton(
            label: 'Cancelar',
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
            isSecondary: true,
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSecondary;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSecondary
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.15),
            ),
            color: Colors.white.withOpacity(isSecondary ? 0.05 : 0.08),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSecondary
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSecondary
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
