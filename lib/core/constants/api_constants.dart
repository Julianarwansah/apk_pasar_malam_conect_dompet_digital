import 'package:flutter/foundation.dart';

class ApiConstants {
  // Override saat run:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8085/v1
  // iOS simulator:
  // flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8085/v1
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    if (kIsWeb) return 'http://localhost:8080/v1';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8085/v1',
      TargetPlatform.iOS => 'http://127.0.0.1:8085/v1',
      _ => 'http://127.0.0.1:8085/v1',
    };
  }

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
