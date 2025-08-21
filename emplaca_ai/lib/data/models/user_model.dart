// lib/data/models/user_model.dart

import 'package:uuid/uuid.dart';

/// User model for data layer with serialization capabilities
class UserModel {
  final String id;
  final String username;
  final String hashedPassword;
  final String salt;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool biometricEnabled;
  final String? securityQuestion;
  final String? securityAnswerHash;

  const UserModel({
    required this.id,
    required this.username,
    required this.hashedPassword,
    required this.salt,
    required this.createdAt,
    required this.lastLoginAt,
    required this.biometricEnabled,
    this.securityQuestion,
    this.securityAnswerHash,
  });

  /// Create a new user with generated ID
  factory UserModel.create({
    required String username,
    required String hashedPassword,
    required String salt,
    bool biometricEnabled = false,
    String? securityQuestion,
    String? securityAnswerHash,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: const Uuid().v4(),
      username: username,
      hashedPassword: hashedPassword,
      salt: salt,
      createdAt: now,
      lastLoginAt: now,
      biometricEnabled: biometricEnabled,
      securityQuestion: securityQuestion,
      securityAnswerHash: securityAnswerHash,
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      hashedPassword: json['hashedPassword'] as String,
      salt: json['salt'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      securityQuestion: json['securityQuestion'] as String?,
      securityAnswerHash: json['securityAnswerHash'] as String?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'hashedPassword': hashedPassword,
      'salt': salt,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'biometricEnabled': biometricEnabled,
      'securityQuestion': securityQuestion,
      'securityAnswerHash': securityAnswerHash,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? hashedPassword,
    String? salt,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? biometricEnabled,
    String? securityQuestion,
    String? securityAnswerHash,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
    );
  }

  /// Update last login timestamp
  UserModel updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Enable/disable biometric authentication
  UserModel updateBiometric(bool enabled) {
    return copyWith(biometricEnabled: enabled);
  }

  /// Update password (with new hash and salt)
  UserModel updatePassword(String newHashedPassword, String newSalt) {
    return copyWith(
      hashedPassword: newHashedPassword,
      salt: newSalt,
    );
  }

  /// Update security question and answer
  UserModel updateSecurityQuestion(String? question, String? answerHash) {
    return copyWith(
      securityQuestion: question,
      securityAnswerHash: answerHash,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.hashedPassword == hashedPassword &&
        other.salt == salt &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.biometricEnabled == biometricEnabled &&
        other.securityQuestion == securityQuestion &&
        other.securityAnswerHash == securityAnswerHash;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      hashedPassword,
      salt,
      createdAt,
      lastLoginAt,
      biometricEnabled,
      securityQuestion,
      securityAnswerHash,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, createdAt: $createdAt, '
           'lastLoginAt: $lastLoginAt, biometricEnabled: $biometricEnabled)';
  }
}