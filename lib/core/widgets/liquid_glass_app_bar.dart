import 'package:flutter/material.dart';

/// Top bar with notification and menu buttons in Liquid Glass style
/// Positioned at top-right corner with transparent buttons
class LiquidGlassAppBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final int unreadCount;
  final bool showNotificationButton;
  final bool showMenuButton;

  const LiquidGlassAppBar({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
    this.unreadCount = 0,
    this.showNotificationButton = true,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Positioned(
        top: 16,
        right: 16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showNotificationButton) ...[
              _IconButton(
                icon: Icons.notifications_outlined,
                onTap: onNotificationTap,
                badge: unreadCount > 0 ? unreadCount : null,
              ),
              const SizedBox(width: 4),
            ],
            if (showMenuButton)
              _IconButton(
                icon: Icons.menu,
                onTap: onMenuTap,
              ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int? badge;

  const _IconButton({
    required this.icon,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFef4444),
                borderRadius: BorderRadius.circular(9999),
              ),
              alignment: Alignment.center,
              child: Text(
                badge! > 99 ? '99+' : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
