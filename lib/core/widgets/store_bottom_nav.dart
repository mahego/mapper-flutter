import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoreBottomNav extends StatelessWidget {
  final int currentIndex;

  const StoreBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0f172a),
      selectedItemColor: const Color(0xFF06b6d4),
      unselectedItemColor: Colors.white.withOpacity(0.6),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/store/pos');
            break;
          case 1:
            context.go('/store/catalog');
            break;
          case 2:
            context.go('/store/orders');
            break;
          case 3:
            context.go('/store/more');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'POS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Catálogo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Más',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
