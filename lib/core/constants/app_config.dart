class AppConfig {
  // API Configuration
  static const String apiUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // App Information
  static const String appName = 'Mapper';
  static const String version = '1.0.0';
  
  // Mapbox Configuration
  static const String mapboxAccessToken = 
      'pk.eyJ1IjoibWFoZWdvdHMiLCJhIjoiY21rdml0ejNrMDZuMDNlb3d1YXE1eTJiciJ9.Q9oV0srILSJaKR2qXPuDXQ';
  
  // Map Defaults
  static const double defaultLatitude = 19.4326; // Ciudad de México
  static const double defaultLongitude = -99.1332;
  static const double defaultZoom = 13.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // Auth
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Notifications
  static const int notificationDuration = 5000; // milliseconds
  
  // Features
  static const bool enableDevTools = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
}
