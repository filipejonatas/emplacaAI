// lib/core/errors/exceptions.dart

/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when vehicle operations fail
class VehicleException extends AppException {
  const VehicleException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'VehicleException: $message';
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when server operations fail
class ServerException extends AppException {
  const ServerException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when permissions are insufficient
class PermissionException extends AppException {
  const PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when data is not found
class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when data conflicts occur
class ConflictException extends AppException {
  const ConflictException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);

  @override
  String toString() => 'ConflictException: $message';
}
