class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Stores
  static const String myStore = '/stores/my-store';
  static const String stores = '/stores';
  static const String storeMetrics = '/stores/metrics';
  static const String storeProducts = '/products'; // Base for updates
  static const String storeOrders = '/store-orders';

  // Products
  static String storeProductsList(String storeId) => '/stores/$storeId/products';
  static const String productLookup = '/products/lookup';

  // Services & Requests
  static const String services = '/services';
  static const String requests = '/requests';
  static const String myRequests = '/requests/my-requests';
  static const String expressRequest = '/requests/express';
  static const String providerLocation = '/providers/location';
  static const String incomingRequests = '/requests/incoming';

  // Pricing
  static const String estimatePrice = '/pricing/estimate';
  
  // Addresses
  static const String addresses = '/addresses';
}
