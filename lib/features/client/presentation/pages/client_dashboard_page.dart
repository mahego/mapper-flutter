import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';

class ClientDashboardPage extends StatelessWidget {
  const ClientDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Dashboard Cliente',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Bienvenido a Mapper!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  onPressed: () => context.go('/auth/login'),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
