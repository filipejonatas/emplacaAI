class UserSession {
  final String userId;
  final String sessionToken;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;
  final Duration timeoutDuration;

  const UserSession({
    required this.userId,
    required this.sessionToken,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
    required this.timeoutDuration,
  });

  UserSession copyWith({
    String? userId,
    String? sessionToken,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool? isActive,
    Duration? timeoutDuration,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      sessionToken: sessionToken ?? this.sessionToken,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
    );
  }

  /// Check if the session has expired based on timeout duration
  bool get isExpired {
    final now = DateTime.now();
    final expirationTime = lastActivity.add(timeoutDuration);
    return now.isAfter(expirationTime);
  }

  /// Check if the session is valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  /// Get remaining time before session expires
  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    final now = DateTime.now();
    final expirationTime = lastActivity.add(timeoutDuration);
    return expirationTime.difference(now);
  }

  /// Update last activity to current time
  UserSession updateActivity() {
    return copyWith(
      lastActivity: DateTime.now(),
    );
  }

  /// Deactivate the session
  UserSession deactivate() {
    return copyWith(isActive: false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSession &&
        other.userId == userId &&
        other.sessionToken == sessionToken &&
        other.createdAt == createdAt &&
        other.lastActivity == lastActivity &&
        other.isActive == isActive &&
        other.timeoutDuration == timeoutDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      sessionToken,
      createdAt,
      lastActivity,
      isActive,
      timeoutDuration,
    );
  }

  @override
  String toString() {
    return 'UserSession(userId: $userId, sessionToken: $sessionToken, createdAt: $createdAt, lastActivity: $lastActivity, isActive: $isActive, isExpired: $isExpired)';
  }
}
