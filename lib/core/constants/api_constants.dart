class ApiConstants {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
