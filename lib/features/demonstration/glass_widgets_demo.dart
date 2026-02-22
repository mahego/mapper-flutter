import 'package:flutter/material.dart';
import 'package:mapper/core/widgets/glass_widgets.dart';

/// Página demo que muestra todos los widgets de Glass + Material 3
/// Sirve como visual reference para el equipo de diseño
class GlassWidgetsDemo extends StatefulWidget {
  const GlassWidgetsDemo({super.key});

  @override
  State<GlassWidgetsDemo> createState() => _GlassWidgetsDemoState();
}

class _GlassWidgetsDemoState extends State<GlassWidgetsDemo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glass Widgets Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: LiquidGlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Material 3 + Glassmorphism\nWidget Collection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // LiquidGlassCard Example
                const Text(
                  '1️⃣ LiquidGlassCard',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                LiquidGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Standard Glass Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Uso general: tarjetas, secciones, contenedores.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ModernGlassCard Example
                const Text(
                  '2️⃣ ModernGlassCard',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ModernGlassCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Tarjeta presionada!')),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Presionable',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tap para ver el efecto',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ModernGlassContainer Example
                const Text(
                  '3️⃣ ModernGlassContainer',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ModernGlassContainer(
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const Text(
                        'Con constraints',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Para formularios y layouts controlados.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.heart,
                                color: Colors.pink,
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.thumb_up,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ModernGlassButton Examples
                const Text(
                  '4️⃣ ModernGlassButton',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ModernGlassButton(
                        label: 'Action',
                        icon: Icons.check,
                        isLoading: _isLoading,
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Listo!')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernGlassButton(
                        label: 'Delete',
                        icon: Icons.delete,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🗑️ Eliminado')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Info Box
                ModernGlassContainer(
                  opacity: 0.08,
                  blurSigma: 10,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '💡 Recomendaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Para listas: ModernGlassCard\n'
                        '• Para formularios: ModernGlassContainer\n'
                        '• Para acciones: ModernGlassButton\n'
                        '• General: LiquidGlassCard',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
