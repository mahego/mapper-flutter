import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/liquid_glass_background.dart';

/// Página 404 – "No encontrado" (paridad mensaje unificado).
class NotFoundPage extends StatelessWidget {
  final String? path;

  const NotFoundPage({super.key, this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Página no encontrada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    path != null && path!.isNotEmpty
                        ? 'La ruta "$path" no existe.'
                        : 'La página que buscas no existe o fue movida.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Ir a Iniciar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06b6d4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/dashboard/cliente'),
                        icon: const Icon(Icons.home),
                        label: const Text('Inicio'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.4)),
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
    );
  }
}
