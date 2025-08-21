import 'dart:async';
import '../data/models/user_model.dart';
import '../data/datasources/local/secure_storage_service.dart';
import '../core/utils/crypto_utils.dart';
import '../core/utils/session_manager.dart';

/// Authentication service for managing user authentication
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  final SecureStorageService _secureStorage = SecureStorageService();
  final SessionManager _sessionManager = SessionManager.instance;

  // Failed login attempt tracking
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  UserModel? _currentUser;

  /// Initialize the auth service
  Future<void> initialize() async {
    await _sessionManager.initialize();
    await _loadCurrentUser();
  }

  /// Register a new user (first-time setup)
  Future<AuthResult> registerUser({
    required String username,
    required String password,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    try {
      // Check if user already exists
      if (await _secureStorage.hasUserCredentials()) {
        return AuthResult.failure('User already exists. Please login instead.');
      }

      // Validate password strength
      if (!CryptoUtils.meetsMinimumRequirements(password)) {
        return AuthResult.failure(
            'Password does not meet minimum requirements.');
      }

      // Generate salt and hash password
      final salt = CryptoUtils.generateSalt();
      final hashedPassword = CryptoUtils.hashPassword(password, salt);

      // Hash security answer if provided
      String? hashedSecurityAnswer;
      if (securityAnswer != null && securityAnswer.isNotEmpty) {
        hashedSecurityAnswer =
            CryptoUtils.hashSecurityAnswer(securityAnswer, salt);
      }

      // Create user model
      final user = UserModel.create(
        username: username,
        hashedPassword: hashedPassword,
        salt: salt,
        securityQuestion: securityQuestion,
        securityAnswerHash: hashedSecurityAnswer,
      );

      // Store user credentials
      await _secureStorage.storeUserCredentials(
        userId: user.id,
        username: user.username,
        hashedPassword: user.hashedPassword,
        salt: user.salt,
      );

      // Store additional user data
      if (securityQuestion != null) {
        await _secureStorage.storeSecureData(
            'security_question', securityQuestion);
      }
      if (hashedSecurityAnswer != null) {
        await _secureStorage.storeSecureData(
            'security_answer_hash', hashedSecurityAnswer);
      }

      _currentUser = user;

      // Create session
      await _sessionManager.createSession(user.id);

      return AuthResult.success('User registered successfully.');
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  /// Login user with username and password
  Future<AuthResult> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      // Check if account is locked
      final lockoutResult = await _checkAccountLockout();
      if (!lockoutResult.isSuccess) {
        return lockoutResult;
      }

      // Get stored credentials
      final storedUsername = await _secureStorage.getUserName();
      final storedHashedPassword = await _secureStorage.getHashedPassword();
      final storedSalt = await _secureStorage.getSalt();
      final userId = await _secureStorage.getUserId();

      if (storedHashedPassword == null ||
          storedSalt == null ||
          userId == null) {
        return AuthResult.failure('No user found. Please register first.');
      }

      // Verify username
      if (storedUsername != username) {
        await _recordFailedAttempt();
        return AuthResult.failure('Invalid username or password.');
      }

      // Verify password
      if (!CryptoUtils.verifyPassword(
          password, storedHashedPassword, storedSalt)) {
        await _recordFailedAttempt();
        return AuthResult.failure('Invalid username or password.');
      }

      // Clear failed attempts on successful login
      await _secureStorage.clearFailedAttempts();
      await _secureStorage.clearLockout();

      // Load user data
      await _loadCurrentUser();

      // Update last login
      await _secureStorage.storeLastLogin(DateTime.now());

      // Create session
      await _sessionManager.createSession(userId);

      return AuthResult.success('Login successful.');
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
    await _sessionManager.clearSession();
  }

  /// Check if user is authenticated
  bool get isAuthenticated =>
      _sessionManager.isAuthenticated && _currentUser != null;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Change user password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!isAuthenticated) {
        return AuthResult.failure('User not authenticated.');
      }

      // Validate new password strength
      if (!CryptoUtils.meetsMinimumRequirements(newPassword)) {
        return AuthResult.failure(
            'New password does not meet minimum requirements.');
      }

      // Verify current password
      final storedHashedPassword = await _secureStorage.getHashedPassword();
      final storedSalt = await _secureStorage.getSalt();

      if (storedHashedPassword == null || storedSalt == null) {
        return AuthResult.failure('Unable to verify current password.');
      }

      if (!CryptoUtils.verifyPassword(
          currentPassword, storedHashedPassword, storedSalt)) {
        return AuthResult.failure('Current password is incorrect.');
      }

      // Generate new salt and hash new password
      final newSalt = CryptoUtils.generateSalt();
      final newHashedPassword = CryptoUtils.hashPassword(newPassword, newSalt);

      // Update stored credentials
      await _secureStorage.storeUserCredentials(
        userId: _currentUser!.id,
        username: _currentUser!.username,
        hashedPassword: newHashedPassword,
        salt: newSalt,
      );

      // Update current user model
      _currentUser = _currentUser!.updatePassword(newHashedPassword, newSalt);

      // Refresh session for security
      await _sessionManager.refreshSessionToken();

      return AuthResult.success('Password changed successfully.');
    } catch (e) {
      return AuthResult.failure('Password change failed: ${e.toString()}');
    }
  }

  /// Enable/disable biometric authentication
  Future<AuthResult> setBiometricEnabled(bool enabled) async {
    try {
      if (!isAuthenticated) {
        return AuthResult.failure('User not authenticated.');
      }

      await _secureStorage.setBiometricEnabled(enabled);
      _currentUser = _currentUser!.updateBiometric(enabled);

      return AuthResult.success(enabled
          ? 'Biometric authentication enabled.'
          : 'Biometric authentication disabled.');
    } catch (e) {
      return AuthResult.failure(
          'Failed to update biometric setting: ${e.toString()}');
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    return await _secureStorage.isBiometricEnabled();
  }

  /// Verify security answer
  Future<bool> verifySecurityAnswer(String answer) async {
    try {
      final storedAnswerHash =
          await _secureStorage.getSecureData('security_answer_hash');
      final salt = await _secureStorage.getSalt();

      if (storedAnswerHash == null || salt == null) {
        return false;
      }

      return CryptoUtils.verifySecurityAnswer(answer, storedAnswerHash, salt);
    } catch (e) {
      return false;
    }
  }

  /// Get security question
  Future<String?> getSecurityQuestion() async {
    return await _secureStorage.getSecureData('security_question');
  }

  /// Reset password using security answer
  Future<AuthResult> resetPasswordWithSecurityAnswer({
    required String securityAnswer,
    required String newPassword,
  }) async {
    try {
      // Verify security answer
      if (!await verifySecurityAnswer(securityAnswer)) {
        return AuthResult.failure('Security answer is incorrect.');
      }

      // Validate new password
      if (!CryptoUtils.meetsMinimumRequirements(newPassword)) {
        return AuthResult.failure(
            'New password does not meet minimum requirements.');
      }

      // Generate new salt and hash new password
      final newSalt = CryptoUtils.generateSalt();
      final newHashedPassword = CryptoUtils.hashPassword(newPassword, newSalt);
      final userId = await _secureStorage.getUserId();
      final username = await _secureStorage.getUserName();

      if (userId == null) {
        return AuthResult.failure('User data not found.');
      }

      // Update stored credentials
      await _secureStorage.storeUserCredentials(
        userId: userId,
        username: username,
        hashedPassword: newHashedPassword,
        salt: newSalt,
      );

      // Clear failed attempts and lockout
      await _secureStorage.clearFailedAttempts();
      await _secureStorage.clearLockout();

      return AuthResult.success('Password reset successfully.');
    } catch (e) {
      return AuthResult.failure('Password reset failed: ${e.toString()}');
    }
  }

  /// Load current user from storage
  Future<void> _loadCurrentUser() async {
    try {
      final userId = await _secureStorage.getUserId();
      final username = await _secureStorage.getUserName();
      final hashedPassword = await _secureStorage.getHashedPassword();
      final salt = await _secureStorage.getSalt();
      final lastLogin = await _secureStorage.getLastLogin();
      final biometricEnabled = await _secureStorage.isBiometricEnabled();

      if (userId != null &&
          hashedPassword != null &&
          salt != null) {
        _currentUser = UserModel(
          id: userId,
          username: username,
          hashedPassword: hashedPassword,
          salt: salt,
          createdAt: DateTime.now(), // We don't store creation date separately
          lastLoginAt: lastLogin ?? DateTime.now(),
          biometricEnabled: biometricEnabled,
        );
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  /// Check account lockout status
  Future<AuthResult> _checkAccountLockout() async {
    final lockoutUntil = await _secureStorage.getLockoutUntil();
    if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
      final remainingTime = lockoutUntil.difference(DateTime.now());
      final minutes = remainingTime.inMinutes;
      return AuthResult.failure(
          'Account is locked. Try again in $minutes minute${minutes != 1 ? 's' : ''}.');
    }
    return AuthResult.success('Account not locked.');
  }

  /// Record failed login attempt
  Future<void> _recordFailedAttempt() async {
    final currentAttempts = await _secureStorage.getFailedAttempts();
    final newAttempts = currentAttempts + 1;

    await _secureStorage.storeFailedAttempts(newAttempts);

    if (newAttempts >= maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(lockoutDuration);
      await _secureStorage.storeLockoutUntil(lockoutUntil);
    }
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    return await _secureStorage.getFailedAttempts();
  }

  /// Check if account is locked
  Future<bool> isAccountLocked() async {
    final result = await _checkAccountLockout();
    return !result.isSuccess;
  }

  /// Get lockout remaining time
  Future<Duration?> getLockoutRemainingTime() async {
    final lockoutUntil = await _secureStorage.getLockoutUntil();
    if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
      return lockoutUntil.difference(DateTime.now());
    }
    return null;
  }

  /// Clear all user data (for app reset)
  Future<void> clearAllData() async {
    _currentUser = null;
    await _sessionManager.clearSession();
    await _secureStorage.clearAll();
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String message;

  const AuthResult._(this.isSuccess, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.failure(String message) => AuthResult._(false, message);

  @override
  String toString() => 'AuthResult(isSuccess: $isSuccess, message: $message)';
}
