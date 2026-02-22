class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String firebaseLogin = '/auth/firebase-login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/profile';

  // Stores
  static const String myStore = '/stores/my-store';
  static const String stores = '/stores';
  static const String storeMetrics = '/stores/metrics';
  static const String storeProducts = '/products'; // Base for updates
  static const String storeOrders = '/store-orders';

  // Products
  static const String products = '/products';
  static String storeProductsList(String storeId) => '/stores/$storeId/products';
  static const String productLookup = '/products/lookup';
  static String productLookupByBarcode(String barcode) => '/products/lookup?barcode=$barcode';

  // Services & Requests
  static const String services = '/services';
  static const String requests = '/requests';
  static const String myRequests = '/requests/my-requests';
  static const String expressRequest = '/requests/express';
  static const String providerLocation = '/providers/location';
  static const String incomingRequests = '/requests/incoming';
  static String requestAccept(String requestId) => '/requests/$requestId/accept';
  static String requestDetail(String requestId) => '/requests/$requestId';

  // Provider
  static const String providerStats = '/providers/stats';
  static const String providerEarnings = '/providers/earnings';
  static const String providerStatus = '/providers/status';
  static const String providerOnlineStatus = '/providers/online-status';
  static const String myServices = '/services/my-services';

  // Subscriptions
  static const String subscriptions = '/subscriptions';
  static const String currentSubscription = '/subscriptions/current';
  static const String subscriptionPayment = '/subscriptions/payment';

  // Shifts (Bolsa de trabajo)
  static const String shifts = '/shifts';
  static const String shiftsOpen = '/shifts/open';
  static const String myShifts = '/shifts/my-shifts';
  static const String myApplications = '/shifts/my-applications';
  static String applyToShift(String shiftId) => '/shifts/$shiftId/apply';
  static String shiftDetail(String shiftId) => '/shifts/$shiftId';
  static String confirmArrival(String shiftId) => '/shifts/$shiftId/confirm-arrival';

  // POS
  static String storeForPOS(String storeId) => '/stores/$storeId';
  static const String posSale = '/store-orders';

  // Pricing
  static const String estimatePrice = '/pricing/estimate';
  
  // Addresses
  static const String addresses = '/addresses';

  // Express Requests
  static const String expressRequestsOpen = '/requests/express/open';

  // Client
  static const String clientRequests = '/requests'; // GET returns filtered by client_id automatically
  static const String createRequest = '/requests';
  static String updateRequest(String requestId) => '/requests/$requestId';
  
  // Tracking
  static String trackRequest(String requestId) => '/requests/$requestId/tracking';
}
