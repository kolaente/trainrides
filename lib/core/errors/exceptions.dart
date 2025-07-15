class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class ApiException extends AppException {
  final int? statusCode;

  const ApiException(
    String message, {
    this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}

class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class SyncException extends AppException {
  const SyncException(String message, {String? code, dynamic originalError})
    : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    String message, {
    this.fieldErrors,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}
