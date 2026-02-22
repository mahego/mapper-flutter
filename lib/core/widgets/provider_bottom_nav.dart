import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderBottomNav extends StatelessWidget {
  final int currentIndex;

  const ProviderBottomNav({
    super.key,
    required this.currentIndex,
  });

  // Bottom nav items matching Angular PRESTADOR_BOTTOM_NAV_ITEMS
  static const List<BottomNavItem> items = [
    BottomNavItem(
      label: 'Inicio',
      route: '/provider/dashboard',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    BottomNavItem(
      label: 'POS',
      route: '/provider/pos',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
    ),
    BottomNavItem(
      label: 'Bolsa',
      route: '/provider/bolsa-trabajo',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
    ),
    BottomNavItem(
      label: 'Subastas',
      route: '/auctions',
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel,
    ),
    BottomNavItem(
      label: 'Vehículos',
      route: '/vehicles',
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car,
    ),
    BottomNavItem(
      label: 'Perfil',
      route: '/profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    context.go(items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _BottomNavButton(
                item: items[index],
                isActive: currentIndex == index,
                onTap: () => _onItemTapped(context, index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;

  const BottomNavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });
}
