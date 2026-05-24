/// ============================================
/// FINTELIA — Failure Classes
/// Functional error handling for use cases
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// Base failure class for clean architecture error handling.
///
/// Failures represent expected error states that are passed
/// through the domain layer without throwing exceptions.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure caused by a network or API error.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, this.statusCode})
      : super(code: 'NETWORK_FAILURE');

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure caused by authentication issues.
class AuthFailure extends Failure {
  const AuthFailure({required super.message}) : super(code: 'AUTH_FAILURE');
}

/// Failure caused by local cache issues.
class CacheFailure extends Failure {
  const CacheFailure({required super.message}) : super(code: 'CACHE_FAILURE');
}

/// Failure caused by validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, this.field})
      : super(code: 'VALIDATION_FAILURE');

  final String? field;

  @override
  List<Object?> get props => [message, field];
}

/// Failure when a resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message})
      : super(code: 'NOT_FOUND_FAILURE');
}

/// Unknown or unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'})
      : super(code: 'UNKNOWN_FAILURE');
}
