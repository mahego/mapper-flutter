import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Info
  static const String appName = 'Mapper';
  static const String appVersion = '1.0.0';

  /// API base URL (incluye /api). Backend en producción (Fly.io).
  static const String baseUrl = 'https://flet-app-mahegots.fly.dev/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  /// Mapbox access token - loaded from .env file
  static late String mapboxAccessToken;
  
  /// Google Places API Key - loaded from .env file
  static late String googlePlacesApiKey;
  
  // Storage Keys
  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  
  // Delivery Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusDelivered = 'delivered';
  static const String statusCanceled = 'canceled';
  
  /// Initialize AppConstants with environment variables
  static void initialize() {
    // Mapbox token: set MAPBOX_ACCESS_TOKEN in .env (never commit real tokens)
    mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    if (mapboxAccessToken.isNotEmpty) {
      print('🔑 Mapbox token loaded: ${mapboxAccessToken.substring(0, 20)}...');
    } else {
      print('⚠️ MAPBOX_ACCESS_TOKEN not set - maps may not work. Add it to .env');
    }
    
    // Load Google Places API key from environment
    googlePlacesApiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    if (googlePlacesApiKey.isEmpty) {
      print('⚠️ Google Places API key not configured - reverse geocoding will use fallback');
    } else {
      print('🔑 Google Places API key loaded: ${googlePlacesApiKey.substring(0, 20)}...');
    }
  }
}
