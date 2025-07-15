class ApiConstants {
  static const String baseUrl = 'https://baserow.kolaente.de';
  static const String apiVersion = 'v1';
  static const int databaseId = 307;
  static const int tableId = 1438;

  static const String baseApiUrl = '$baseUrl/api/database/rows/table/$tableId/';

  static const Map<String, String> fieldMapping = {
    'from': 'field_13808',
    'to': 'field_13811',
    'price': 'field_13812',
    'type': 'field_13813',
    'date': 'field_13814',
    'details': 'field_13815',
  };

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
