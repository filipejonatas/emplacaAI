import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device));

// Storage keys
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _hashedPasswordKey = 'hashed_password';
  static const String _saltKey = 'salt';
  static const String _sessionTokenKey = 'session_token';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginKey = 'last_login';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockoutUntilKey = 'lockout_until';

// Store user credentials securely
  Future<void> storeUserCredentials({
    required String userId,
    required String username,
    required String hashedPassword,
    required String salt,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _usernameKey, value: username),
      _storage.write(key: _hashedPasswordKey, value: hashedPassword),
      _storage.write(key: _saltKey, value: salt),
    ]);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get stored username (never returns null)
  Future<String> getUserName() async {
    return (await _storage.read(key: _usernameKey)) ?? '';
  }

  /// Get stored hashed password
  Future<String?> getHashedPassword() async {
    return await _storage.read(key: _hashedPasswordKey);
  }

  /// Get stored salt
  Future<String?> getSalt() async {
    return await _storage.read(key: _saltKey);
  }

  /// Store session token
  Future<void> storeSessionToken(String token) async {
    await _storage.write(key: _sessionTokenKey, value: token);
  }

  /// Get session token
  Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionTokenKey);
  }

  /// Clear session token
  Future<void> clearSessionToken() async {
    await _storage.delete(key: _sessionTokenKey);
  }

  /// Store biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Get biometric enabled status
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Store last login timestamp
  Future<void> storeLastLogin(DateTime dateTime) async {
    await _storage.write(key: _lastLoginKey, value: dateTime.toIso8601String());
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLogin() async {
    final value = await _storage.read(key: _lastLoginKey);
    if (value != null) {
      return DateTime.parse(value);
    }
    return null;
  }

  /// Store failed login attempts count
  Future<void> storeFailedAttempts(int count) async {
    await _storage.write(key: _failedAttemptsKey, value: count.toString());
  }

  /// Get failed login attempts count
  Future<int> getFailedAttempts() async {
    final value = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  /// Clear failed login attempts
  Future<void> clearFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
  }

  /// Store lockout timestamp
  Future<void> storeLockoutUntil(DateTime dateTime) async {
    await _storage.write(
        key: _lockoutUntilKey, value: dateTime.toIso8601String());
  }

  /// Get lockout timestamp
  Future<DateTime?> getLockoutUntil() async {
    final value = await _storage.read(key: _lockoutUntilKey);
    if (value != null) {
      return DateTime.parse(value);
    }
    return null;
  }

  /// Clear lockout timestamp
  Future<void> clearLockout() async {
    await _storage.delete(key: _lockoutUntilKey);
  }

  /// Check if user credentials exist
  Future<bool> hasUserCredentials() async {
    final userId = await getUserId();
    final username = await getUserName();
    final hashedPassword = await getHashedPassword();
    final salt = await getSalt();

    return userId != null &&
        username.isNotEmpty &&
        hashedPassword != null &&
        salt != null;
  }

  /// Clear all stored data (for logout or reset)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear only session-related data (for logout)
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _sessionTokenKey),
      _storage.delete(key: _failedAttemptsKey),
      _storage.delete(key: _lockoutUntilKey),
    ]);
  }

  /// Store generic secure data
  Future<void> storeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Get generic secure data
  Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete specific secure data
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  /// Store complex object as JSON
  Future<void> storeSecureObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  /// Get complex object from JSON
  Future<Map<String, dynamic>?> getSecureObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        // Handle JSON decode error
        return null;
      }
    }
    return null;
  }

  Future hasCredentials() async {}

  Future<void> write(String s, String t) async {}
}
