import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientBottomNav extends StatelessWidget {
  final int currentIndex;

  const ClientBottomNav({
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
            context.go('/client/dashboard');
            break;
          case 1:
            context.go('/requests');
            break;
          case 2:
            context.go('/cliente/tracking');
            break;
          case 3:
            context.go('/auctions');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Solicitudes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Tracking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Subastas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
