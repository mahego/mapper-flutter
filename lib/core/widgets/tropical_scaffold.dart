import 'package:flutter/material.dart';
import 'package:mapper/core/theme/app_theme.dart';
import 'dart:ui';

/// A Scaffold wrapper that applies the "Liquid Aurora" background effect
/// homologated from the Angular web app.
class TropicalScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Color? backgroundColor;

  const TropicalScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.slate950,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      drawer: drawer,
      body: Stack(
        children: [
          // Background Gradient Orbs (The "Tropical" Liquid Effect)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF60A5FA).withOpacity(0.2), // Blue 400
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFC084FC).withOpacity(0.15), // Purple
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
             top: 300,
             right: 50,
             child: Container(
               width: 200,
               height: 200,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 gradient: RadialGradient(
                   colors: [
                     Color(0xFFF472B6).withOpacity(0.15), // Pink
                     Colors.transparent,
                   ],
                 ),
               ),
             ),
           ),
          
          // Blur Filter to merge the orbs
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Content
          SafeArea(child: body ?? const SizedBox()),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
