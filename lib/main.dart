import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'core/network/api_client.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Storage Service
  await StorageService().init();
  
  // Initialize API Client
  final apiClient = ApiClient();
  
  // Initialize Auth Repository
  final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
  
  // Initialize Auth Service
  AuthService().initialize(authRepository, apiClient);
  
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
