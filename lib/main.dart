import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MapperApp());
}

class MapperApp extends StatelessWidget {
  const MapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mapper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Forced to dark to match the "Tropical" web style
      themeMode: ThemeMode.dark, 
      routerConfig: AppRouter.router,
    );
  }
}
