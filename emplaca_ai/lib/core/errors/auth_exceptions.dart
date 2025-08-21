import '../constants/auth_constants.dart';

/// Base class for all authentication-related exceptions
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when user credentials are invalid
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message])
      : super(message ?? AuthConstants.invalidCredentialsError, code: 'INVALID_CREDENTIALS');
}

/// Exception thrown when user is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? message])
      : super(message ?? AuthConstants.userNotFoundError, code: 'USER_NOT_FOUND');
}

/// Exception thrown when user already exists
class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException([String? message])
      : super(message ?? AuthConstants.userAlreadyExistsError, code: 'USER_ALREADY_EXISTS');
}

/// Exception thrown when password doesn't meet requirements
class WeakPasswordException extends AuthException {
  const WeakPasswordException([String? message])
      : super(message ?? AuthConstants.weakPasswordError, code: 'WEAK_PASSWORD');
}

/// Exception thrown when account is locked
class AccountLockedException extends AuthException {
  final Duration lockoutDuration;
  final DateTime lockedUntil;

  const AccountLockedException(this.lockoutDuration, this.lockedUntil, [String? message])
      : super(message ?? AuthConstants.accountLockedError, code: 'ACCOUNT_LOCKED');

  /// Get remaining lockout time
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isBefore(lockedUntil)) {
      return lockedUntil.difference(now);
    }
    return Duration.zero;
  }

  /// Check if account is still locked
  bool get isStillLocked => DateTime.now().isBefore(lockedUntil);
}

/// Exception thrown when session has expired
class SessionExpiredException extends AuthException {
  final DateTime expiredAt;

  const SessionExpiredException(this.expiredAt, [String? message])
      : super(message ?? AuthConstants.sessionExpiredError, code: 'SESSION_EXPIRED');
}

/// Exception thrown when user is not authenticated
class UserNotAuthenticatedException extends AuthException {
  const UserNotAuthenticatedException([String? message])
      : super(message ?? AuthConstants.userNotAuthenticatedError, code: 'USER_NOT_AUTHENTICATED');
}

/// Exception thrown when biometric authentication fails
class BiometricAuthException extends AuthException {
  final BiometricFailureReason reason;

  const BiometricAuthException(this.reason, [String? message])
      : super(message ?? 'Biometric authentication failed', code: 'BIOMETRIC_AUTH_FAILED');

  factory BiometricAuthException.notAvailable([String? message]) {
    return BiometricAuthException(
      BiometricFailureReason.notAvailable,
      message ?? AuthConstants.biometricNotAvailableError,
    );
  }

  factory BiometricAuthException.notEnrolled([String? message]) {
    return BiometricAuthException(
      BiometricFailureReason.notEnrolled,
      message ?? AuthConstants.biometricNotEnrolledError,
    );
  }

  factory BiometricAuthException.cancelled([String? message]) {
    return BiometricAuthException(
      BiometricFailureReason.cancelled,
      message ?? 'Biometric authentication was cancelled',
    );
  }

  factory BiometricAuthException.failed([String? message]) {
    return BiometricAuthException(
      BiometricFailureReason.failed,
      message ?? 'Biometric authentication failed',
    );
  }

  factory BiometricAuthException.timeout([String? message]) {
    return BiometricAuthException(
      BiometricFailureReason.timeout,
      message ?? 'Biometric authentication timed out',
    );
  }
}

/// Enum for biometric failure reasons
enum BiometricFailureReason {
  notAvailable,
  notEnrolled,
  cancelled,
  failed,
  timeout,
}

/// Exception thrown when security answer is incorrect
class SecurityAnswerIncorrectException extends AuthException {
  const SecurityAnswerIncorrectException([String? message])
      : super(message ?? AuthConstants.securityAnswerIncorrectError, code: 'SECURITY_ANSWER_INCORRECT');
}

/// Exception thrown when current password is incorrect during password change
class CurrentPasswordIncorrectException extends AuthException {
  const CurrentPasswordIncorrectException([String? message])
      : super(message ?? AuthConstants.currentPasswordIncorrectError, code: 'CURRENT_PASSWORD_INCORRECT');
}

/// Exception thrown when secure storage operations fail
class SecureStorageException extends AuthException {
  const SecureStorageException(String message, {dynamic originalError})
      : super(message, code: 'SECURE_STORAGE_ERROR', originalError: originalError);
}

/// Exception thrown when cryptographic operations fail
class CryptoException extends AuthException {
  const CryptoException(String message, {dynamic originalError})
      : super(message, code: 'CRYPTO_ERROR', originalError: originalError);
}

/// Exception thrown when session operations fail
class SessionException extends AuthException {
  const SessionException(String message, {dynamic originalError})
      : super(message, code: 'SESSION_ERROR', originalError: originalError);
}

/// Exception thrown when validation fails
class ValidationException extends AuthException {
  final Map<String, String> fieldErrors;

  const ValidationException(String message, this.fieldErrors)
      : super(message, code: 'VALIDATION_ERROR');

  /// Check if a specific field has an error
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  /// Get error message for a specific field
  String? getFieldError(String field) => fieldErrors[field];

  /// Get all field errors as a formatted string
  String get formattedErrors {
    return fieldErrors.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

/// Exception thrown when network operations fail (for future use)
class NetworkException extends AuthException {
  final int? statusCode;

  const NetworkException(String message, {this.statusCode, dynamic originalError})
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}

/// Exception thrown when initialization fails
class InitializationException extends AuthException {
  const InitializationException(String message, {dynamic originalError})
      : super(message, code: 'INITIALIZATION_ERROR', originalError: originalError);
}

/// Utility class for creating common auth exceptions
class AuthExceptions {
  AuthExceptions._();

  /// Create validation exception for username
  static ValidationException invalidUsername(String message) {
    return ValidationException('Username validation failed', {'username': message});
  }

  /// Create validation exception for password
  static ValidationException invalidPassword(String message) {
    return ValidationException('Password validation failed', {'password': message});
  }

  /// Create validation exception for multiple fields
  static ValidationException multipleFields(Map<String, String> errors) {
    return ValidationException('Multiple validation errors', errors);
  }

  /// Create account locked exception with remaining time
  static AccountLockedException accountLocked(Duration remaining) {
    final lockedUntil = DateTime.now().add(remaining);
    final minutes = remaining.inMinutes;
    final message = AuthConstants.getAccountLockoutMessage(minutes);
    return AccountLockedException(remaining, lockedUntil, message);
  }

  /// Create session expired exception
  static SessionExpiredException sessionExpired() {
    return SessionExpiredException(DateTime.now());
  }

  /// Create failed attempts exception
  static InvalidCredentialsException failedAttempts(int attempts, int maxAttempts) {
    final message = AuthConstants.getFailedAttemptsMessage(attempts, maxAttempts);
    return InvalidCredentialsException(message);
  }
}

/// Extension for handling auth exceptions in UI
extension AuthExceptionExtension on AuthException {
  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'The username or password you entered is incorrect.';
      case 'USER_NOT_FOUND':
        return 'No account found. Please register first.';
      case 'USER_ALREADY_EXISTS':
        return 'An account already exists. Please login instead.';
      case 'WEAK_PASSWORD':
        return 'Please choose a stronger password.';
      case 'ACCOUNT_LOCKED':
        return 'Account temporarily locked for security.';
      case 'SESSION_EXPIRED':
        return 'Your session has expired. Please login again.';
      case 'USER_NOT_AUTHENTICATED':
        return 'Please login to continue.';
      case 'BIOMETRIC_AUTH_FAILED':
        return 'Biometric authentication failed.';
      case 'SECURITY_ANSWER_INCORRECT':
        return 'Security answer is incorrect.';
      case 'CURRENT_PASSWORD_INCORRECT':
        return 'Current password is incorrect.';
      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      case 'SECURE_STORAGE_ERROR':
        return 'Unable to access secure storage.';
      case 'CRYPTO_ERROR':
        return 'Security operation failed.';
      case 'SESSION_ERROR':
        return 'Session management error.';
      case 'INITIALIZATION_ERROR':
        return 'App initialization failed.';
      default:
        return message;
    }
  }

  /// Check if exception is recoverable
  bool get isRecoverable {
    switch (code) {
      case 'INVALID_CREDENTIALS':
      case 'SECURITY_ANSWER_INCORRECT':
      case 'CURRENT_PASSWORD_INCORRECT':
      case 'WEAK_PASSWORD':
      case 'VALIDATION_ERROR':
      case 'BIOMETRIC_AUTH_FAILED':
        return true;
      case 'ACCOUNT_LOCKED':
        if (this is AccountLockedException) {
          return !(this as AccountLockedException).isStillLocked;
        }
        return false;
      case 'SESSION_EXPIRED':
      case 'USER_NOT_AUTHENTICATED':
        return true;
      default:
        return false;
    }
  }

  /// Check if exception requires immediate logout
  bool get requiresLogout {
    switch (code) {
      case 'SESSION_EXPIRED':
      case 'USER_NOT_AUTHENTICATED':
        return true;
      default:
        return false;
    }
  }
}