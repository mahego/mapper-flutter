import 'package:flutter/material.dart';
import 'liquid_glass_background.dart';
import 'liquid_glass_app_bar.dart';
import 'liquid_glass_drawer.dart';
import 'liquid_glass_bottom_nav.dart';

/// Complete scaffold with Liquid Glass design system
/// Combines background, app bar, drawer, and bottom navigation
/// Matches Angular's dashboard layout structure
class LiquidGlassScaffold extends StatefulWidget {
  final Widget body;
  final List<BottomNavItem>? bottomNavItems;
  final int? currentBottomNavIndex;
  final ValueChanged<int>? onBottomNavTap;
  final List<DrawerMenuItem>? drawerMenuItems;
  final String? userName;
  final String? userRole;
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final bool showAppBar;
  final bool showDrawer;
  final bool showBottomNav;
  final bool showOrbs;
  final EdgeInsets? padding;

  const LiquidGlassScaffold({
    super.key,
    required this.body,
    this.bottomNavItems,
    this.currentBottomNavIndex,
    this.onBottomNavTap,
    this.drawerMenuItems,
    this.userName,
    this.userRole,
    this.unreadNotifications = 0,
    this.onNotificationTap,
    this.showAppBar = true,
    this.showDrawer = true,
    this.showBottomNav = true,
    this.showOrbs = true,
    this.padding,
  });

  @override
  State<LiquidGlassScaffold> createState() => _LiquidGlassScaffoldState();
}

class _LiquidGlassScaffoldState extends State<LiquidGlassScaffold> {
  bool _drawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
    });
  }

  void _closeDrawer() {
    setState(() {
      _drawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasBottomNav = widget.showBottomNav && 
                          widget.bottomNavItems != null && 
                          widget.bottomNavItems!.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Background with orbs
          LiquidGlassBackground(
            showOrbs: widget.showOrbs,
            child: SafeArea(
              bottom: hasBottomNav,
              child: Padding(
                padding: widget.padding ?? EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: widget.showAppBar ? 60 : 24,
                  bottom: hasBottomNav ? 80 : 24,
                ),
                child: widget.body,
              ),
            ),
          ),

          // Top App Bar (notifications + menu)
          if (widget.showAppBar)
            LiquidGlassAppBar(
              onNotificationTap: widget.onNotificationTap,
              onMenuTap: widget.showDrawer ? _toggleDrawer : null,
              unreadCount: widget.unreadNotifications,
              showMenuButton: widget.showDrawer,
            ),

          // Drawer
          if (widget.showDrawer && widget.drawerMenuItems != null)
            LiquidGlassDrawer(
              isOpen: _drawerOpen,
              onClose: _closeDrawer,
              menuItems: widget.drawerMenuItems!,
              userName: widget.userName,
              userRole: widget.userRole,
            ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: hasBottomNav
          ? LiquidGlassBottomNav(
              items: widget.bottomNavItems!,
              currentIndex: widget.currentBottomNavIndex ?? 0,
              onTap: widget.onBottomNavTap,
            )
          : null,
    );
  }
}
