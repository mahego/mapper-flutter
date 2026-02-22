import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

/// Card con efecto de lente líquida avanzado usando liquid_glass_easy
/// Crea efectos de distorsión, refracción y aberración cromática
/// 
/// Este widget es más complejo que LiquidGlassCard y está diseñado
/// para efectos decorativos llamativos, no para uso general en UI.
class LiquidGlassLensCard extends StatelessWidget {
  final Widget backgroundWidget;
  final Widget? lensChild;
  final double lensWidth;
  final double lensHeight;
  final double cornerRadius;
  final double distortion;
  final double distortionWidth;
  final double magnification;
  final double blur;
  final bool draggable;
  final Alignment lensAlignment;

  const LiquidGlassLensCard({
    super.key,
    required this.backgroundWidget,
    this.lensChild,
    this.lensWidth = 280,
    this.lensHeight = 60,
    this.cornerRadius = 30,
    this.distortion = 0.1,
    this.distortionWidth = 33,
    this.magnification = 1.0,
    this.blur = 0,
    this.draggable = false,
    this.lensAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassView(
      pixelRatio: 1.0,
      realTimeCapture: true,
      refreshRate: LiquidGlassRefreshRate.deviceRefreshRate,
      useSync: true,
      children: [
        LiquidGlass(
          position: LiquidGlassAlignPosition(
            alignment: lensAlignment,
            margin: const EdgeInsets.all(20),
          ),
          width: lensWidth,
          height: lensHeight,
          magnification: magnification,
          refractionMode: LiquidGlassRefractionMode.shapeRefraction,
          distortion: distortion,
          distortionWidth: distortionWidth,
          chromaticAberration: 0.003,
          saturation: 1.0,
          draggable: draggable,
          blur: LiquidGlassBlur(sigmaX: blur, sigmaY: blur),
          shape: RoundedRectangleShape(
            cornerRadius: cornerRadius,
            borderWidth: 1.0,
            borderSoftness: 1.0,
            lightIntensity: 1.0,
            oneSideLightIntensity: 0.0,
            lightDirection: 0,
            lightMode: LiquidGlassLightMode.edge,
          ),
          visibility: true,
          child: lensChild,
        ),
      ],
      backgroundWidget: backgroundWidget,
    );
  }
}

/// Ejemplo de uso de efectos de lente líquida
/// Muestra cómo crear efectos avanzados con liquid_glass_easy
class LiquidGlassLensExample extends StatelessWidget {
  const LiquidGlassLensExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Glass Lens Effect'),
        backgroundColor: const Color(0xFF0f172a),
      ),
      body: LiquidGlassLensCard(
        lensWidth: 300,
        lensHeight: 80,
        cornerRadius: 40,
        distortion: 0.15,
        distortionWidth: 35,
        blur: 5,
        draggable: true,
        lensAlignment: Alignment.center,
        backgroundWidget: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0f172a),
                Color(0xFF1e293b),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 100,
                  color: Color(0xFF06b6d4),
                ),
                const SizedBox(height: 20),
                Text(
                  'Liquid Glass Effect',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Toca y arrastra la lente para ver el efecto',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        lensChild: const Center(
          child: Icon(
            Icons.touch_app,
            color: Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }
}
