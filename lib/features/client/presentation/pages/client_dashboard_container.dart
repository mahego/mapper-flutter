import 'package:flutter/material.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import 'client_dashboard_page.dart';
import 'requests_page.dart';
import 'client_tracking_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

/// Client Dashboard Container
/// Uses IndexedStack to maintain state of all pages.
/// [initialTabIndex] permite abrir una pestaña concreta al volver (ej. desde detalle de solicitud).
class ClientDashboardContainer extends StatefulWidget {
  /// 0=Inicio, 1=Solicitudes, 2=Tracking, 3=Perfil. Null = mantener índice actual o 0.
  final int? initialTabIndex;

  const ClientDashboardContainer({super.key, this.initialTabIndex});

  @override
  State<ClientDashboardContainer> createState() => _ClientDashboardContainerState();
}

class _ClientDashboardContainerState extends State<ClientDashboardContainer> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex != null && widget.initialTabIndex! >= 0 && widget.initialTabIndex! < 4) {
      _selectedIndex = widget.initialTabIndex!;
    }
  }

  @override
  void didUpdateWidget(ClientDashboardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null && widget.initialTabIndex != oldWidget.initialTabIndex) {
      final tab = widget.initialTabIndex!;
      if (tab >= 0 && tab < 4 && tab != _selectedIndex) {
        setState(() => _selectedIndex = tab);
      }
    }
  }

  // Pages to display based on index
  late final List<Widget> _pages = [
    const ClientDashboardPage(),     // Index 0 - Dashboard/Home
    const RequestsPage(),             // Index 1 - Solicitudes
    const ClientTrackingPage(),       // Index 2 - Tracking
    const ProfilePage(),              // Index 3 - Perfil
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: width < 768 ? _buildBottomNav() : null,
    );
  }

  Widget _buildBottomNav() {
    return LiquidGlassBottomNav(
      items: const [
        BottomNavItem(label: 'Inicio', icon: Icons.home_outlined, route: '/dashboard'),
        BottomNavItem(label: 'Solicitudes', icon: Icons.assignment_outlined, route: '/requests'),
        BottomNavItem(label: 'Tracking', icon: Icons.location_on_outlined, route: '/tracking'),
        BottomNavItem(label: 'Perfil', icon: Icons.person_outline, route: '/profile'),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}
