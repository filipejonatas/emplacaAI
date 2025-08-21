class User {
  final String id;
  final String username;
  final String hashedPassword;
  final String salt;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool biometricEnabled;
  final String? securityQuestion;
  final String? securityAnswerHash;

  const User({
    required this.id,
    required this.username,
    required this.hashedPassword,
    required this.salt,
    required this.createdAt,
    required this.lastLoginAt,
    this.biometricEnabled = false,
    this.securityQuestion,
    this.securityAnswerHash,
  });

  User copyWith({
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
    return User(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
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
    return 'User(id: $id, username: $username, createdAt: $createdAt, lastLoginAt: $lastLoginAt, biometricEnabled: $biometricEnabled)';
  }
}
