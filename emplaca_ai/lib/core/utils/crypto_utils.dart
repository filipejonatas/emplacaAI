import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Utility class for cryptographic operations
class CryptoUtils {
  static const int _saltLength = 32;
  static const int _hashIterations = 10000;

  /// Generate a random salt for password hashing
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = Uint8List(_saltLength);
    
    for (int i = 0; i < _saltLength; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    
    return base64Encode(saltBytes);
  }

  /// Hash a password with salt using PBKDF2-like approach with SHA-256
  static String hashPassword(String password, String salt) {
    final saltBytes = base64Decode(salt);
    final passwordBytes = utf8.encode(password);
    
    // Combine password and salt
    final combined = Uint8List.fromList([...passwordBytes, ...saltBytes]);
    
    // Perform multiple iterations of hashing for security
    var hash = combined;
    for (int i = 0; i < _hashIterations; i++) {
      hash = Uint8List.fromList(sha256.convert(hash).bytes);
    }
    
    return base64Encode(hash);
  }

  /// Verify a password against a stored hash
  static bool verifyPassword(String password, String storedHash, String salt) {
    final computedHash = hashPassword(password, salt);
    return _constantTimeEquals(computedHash, storedHash);
  }

  /// Generate a secure random session token
  static String generateSessionToken() {
    final random = Random.secure();
    final tokenBytes = Uint8List(32);
    
    for (int i = 0; i < 32; i++) {
      tokenBytes[i] = random.nextInt(256);
    }
    
    return base64Encode(tokenBytes);
  }

  /// Generate a secure random ID
  static String generateSecureId() {
    final random = Random.secure();
    final idBytes = Uint8List(16);
    
    for (int i = 0; i < 16; i++) {
      idBytes[i] = random.nextInt(256);
    }
    
    return base64Encode(idBytes).replaceAll('/', '_').replaceAll('+', '-');
  }

  /// Hash security answer for storage
  static String hashSecurityAnswer(String answer, String salt) {
    // Normalize the answer (lowercase, trim whitespace)
    final normalizedAnswer = answer.toLowerCase().trim();
    return hashPassword(normalizedAnswer, salt);
  }

  /// Verify security answer
  static bool verifySecurityAnswer(String answer, String storedHash, String salt) {
    final normalizedAnswer = answer.toLowerCase().trim();
    return verifyPassword(normalizedAnswer, storedHash, salt);
  }

  /// Generate a PIN hash
  static String hashPin(String pin, String salt) {
    return hashPassword(pin, salt);
  }

  /// Verify PIN
  static bool verifyPin(String pin, String storedHash, String salt) {
    return verifyPassword(pin, storedHash, salt);
  }

  /// Constant-time string comparison to prevent timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    
    return result == 0;
  }

  /// Generate a random numeric code (for 2FA, etc.)
  static String generateNumericCode(int length) {
    final random = Random.secure();
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }
    
    return buffer.toString();
  }

  /// Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int criteriaCount = 0;
    if (hasUppercase) criteriaCount++;
    if (hasLowercase) criteriaCount++;
    if (hasDigits) criteriaCount++;
    if (hasSpecialChars) criteriaCount++;
    
    if (password.length >= 12 && criteriaCount >= 3) {
      return PasswordStrength.strong;
    } else if (password.length >= 8 && criteriaCount >= 2) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// Get password strength requirements text
  static List<String> getPasswordRequirements() {
    return [
      'At least 8 characters long',
      'Contains uppercase letters (A-Z)',
      'Contains lowercase letters (a-z)',
      'Contains numbers (0-9)',
      'Contains special characters (!@#\$%^&*)',
    ];
  }

  /// Check if password meets minimum requirements
  static bool meetsMinimumRequirements(String password) {
    return validatePasswordStrength(password) != PasswordStrength.weak;
  }

  /// Generate a secure backup code
  static String generateBackupCode() {
    final random = Random.secure();
    final parts = <String>[];
    
    for (int i = 0; i < 4; i++) {
      final part = random.nextInt(10000).toString().padLeft(4, '0');
      parts.add(part);
    }
    
    return parts.join('-');
  }

  /// Encrypt sensitive data (simple XOR encryption for demonstration)
  /// Note: In production, use proper encryption libraries like encrypt package
  static String encryptData(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Encode(encrypted);
  }

  /// Decrypt sensitive data
  static String decryptData(String encryptedData, String key) {
    final encryptedBytes = base64Decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];
    
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
}

/// Enum for password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Extension for PasswordStrength enum
extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get strengthValue {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}