class ApiConstants {
  // Override saat run:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8085/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8085/v1',
  );

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';
  static const String refreshToken = '/auth/refresh';
  static const String fcmToken = '/auth/fcm-token';

  // Product endpoints
  static const String products = '/products';

  // Cart endpoints
  static const String cart = '/cart';

  // Order endpoints
  static const String orders = '/orders';
  static const String checkout = '/orders/checkout';

  // Timeouts
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000;
}
