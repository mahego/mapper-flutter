import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'core/network/api_client.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale para DateFormat con 'es' (evita LocaleDataException)
  try {
    await initializeDateFormatting('es', null);
  } catch (e) {
    debugPrint('⚠️ initializeDateFormatting(es): $e');
  }

  // Load environment variables from .env file
  try {
    await dotenv.load();
    debugPrint('✅ Environment variables loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Warning: .env file not found or could not be loaded: $e');
    debugPrint('ℹ️ Using default values');
  }
  
  // Initialize AppConstants with loaded environment variables
  AppConstants.initialize();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    // Firebase already initialized or initialization failed
    debugPrint('⚠️ Firebase initialization: $e');
  }
  
  // Initialize Storage Service
  await StorageService().init();
  
  // Initialize API Client
  final apiClient = ApiClient();
  
  // Initialize Auth Repository
  final AuthRepository authRepository = AuthRepositoryImpl(apiClient: apiClient);
  
  // Initialize Auth Service
  AuthService().initialize(authRepository, apiClient);

  // 401: intentar refresh token; si falla, redirigir a login
  ApiClient.onUnauthorized = () => AppRouter.router.go('/auth/login?expired=1');
  ApiClient.onTryRefreshToken = () => AuthService().tryRefreshAccessToken();

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
