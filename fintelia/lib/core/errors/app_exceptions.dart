/// ============================================
/// FINTELIA — Custom App Exceptions
/// Clean error hierarchy for the application
/// ============================================
library;

/// Base exception for all application-specific errors.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    this.statusCode,
    super.code = 'NETWORK_ERROR',
    super.stackTrace,
  });

  final int? statusCode;

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

/// Thrown when authentication fails or a session expires.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.stackTrace,
  });
}

/// Thrown when local cache operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when input validation fails.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    this.field,
    super.code = 'VALIDATION_ERROR',
    super.stackTrace,
  });

  final String? field;
}

/// Thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.stackTrace,
  });
}

/// Thrown when the server returns an unexpected error.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    this.statusCode,
    super.code = 'SERVER_ERROR',
    super.stackTrace,
  });

  final int? statusCode;
}
