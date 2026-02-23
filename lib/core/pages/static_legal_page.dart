import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/liquid_glass_background.dart';

/// Pantalla estática reutilizable para aviso de privacidad, términos, etc. (paridad Angular).
class StaticLegalPage extends StatelessWidget {
  final String title;
  final String content;
  final String? routePath;

  const StaticLegalPage({
    super.key,
    required this.title,
    required this.content,
    this.routePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard/cliente'),
                ),
                title: Text(title, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
