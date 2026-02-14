class AppConstants {
  // App Info
  static const String appName = 'Mapper';
  static const String appVersion = '1.0.0';

  /// API base URL (incluye /api). Mismo backend que Angular (environment.prod).
  /// Local: http://10.0.2.2:3000/api (Android) o http://localhost:3000/api (iOS).
  static const String baseUrl = 'https://flet-app-mahegots.fly.dev/api';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  
  // Delivery Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusDelivered = 'delivered';
  static const String statusCanceled = 'canceled';
}
