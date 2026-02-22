import 'dart:ui';
import 'package:flutter/material.dart';

/// Menu item for the drawer
class DrawerMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final String? route;
  final bool isLogout;

  const DrawerMenuItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.route,
    this.isLogout = false,
  });
}

/// Right-side drawer with Liquid Glass design
/// Similar to Angular's dashboard-nav drawer
class LiquidGlassDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final List<DrawerMenuItem> menuItems;
  final String? userName;
  final String? userRole;

  const LiquidGlassDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.menuItems,
    this.userName,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        if (isOpen)
          GestureDetector(
            onTap: onClose,
            child: AnimatedOpacity(
              opacity: isOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

        // Drawer
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: isOpen ? Offset.zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: SafeArea(
              left: false,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: _DrawerContent(
                      menuItems: menuItems,
                      userName: userName,
                      userRole: userRole,
                      onClose: onClose,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawerContent extends StatelessWidget {
  final List<DrawerMenuItem> menuItems;
  final String? userName;
  final String? userRole;
  final VoidCallback onClose;

  const _DrawerContent({
    required this.menuItems,
    required this.userName,
    required this.userRole,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MENÚ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              if (userName != null)
                Text(
                  'Hola, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Menu Items
        ...menuItems.map((item) {
          if (item.isLogout) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _DrawerLink(
                label: item.label,
                icon: item.icon,
                isLogout: true,
                onTap: () {
                  onClose();
                  item.onTap?.call();
                },
              ),
            );
          }

          return _DrawerLink(
            label: item.label,
            icon: item.icon,
            onTap: () {
              onClose();
              if (item.route != null) {
                Navigator.pushNamed(context, item.route!);
              }
              item.onTap?.call();
            },
          );
        }),
      ],
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLogout;

  const _DrawerLink({
    required this.label,
    required this.icon,
    this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isLogout
                      ? const Color(0xFFfca5a5)
                      : Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isLogout
                        ? const Color(0xFFfca5a5)
                        : Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
