import 'package:uuid/uuid.dart';

/// Session model for managing user authentication sessions
class SessionModel {
  final String userId;
  final String sessionToken;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;
  final Duration timeoutDuration;
  final DateTime expiresAt;

  const SessionModel({
    required this.userId,
    required this.sessionToken,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
    required this.timeoutDuration,
    required this.expiresAt,
  });

  /// Create a new session
  factory SessionModel.create({
    required String userId,
    Duration? timeoutDuration,
  }) {
    final now = DateTime.now();
    final timeout = timeoutDuration ?? const Duration(hours: 8); // Default 8 hours
    final sessionToken = const Uuid().v4();
    
    return SessionModel(
      userId: userId,
      sessionToken: sessionToken,
      createdAt: now,
      lastActivity: now,
      isActive: true,
      timeoutDuration: timeout,
      expiresAt: now.add(timeout),
    );
  }

  /// Create SessionModel from JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      userId: json['userId'] as String,
      sessionToken: json['sessionToken'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isActive: json['isActive'] as bool,
      timeoutDuration: Duration(milliseconds: json['timeoutDurationMs'] as int),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// Convert SessionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionToken': sessionToken,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
      'timeoutDurationMs': timeoutDuration.inMilliseconds,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SessionModel copyWith({
    String? userId,
    String? sessionToken,
    DateTime? createdAt,
    DateTime? lastActivity,
    bool? isActive,
    Duration? timeoutDuration,
    DateTime? expiresAt,
  }) {
    return SessionModel(
      userId: userId ?? this.userId,
      sessionToken: sessionToken ?? this.sessionToken,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Update last activity timestamp and extend expiration
  SessionModel updateActivity() {
    final now = DateTime.now();
    return copyWith(
      lastActivity: now,
      expiresAt: now.add(timeoutDuration),
    );
  }

  /// Deactivate the session
  SessionModel deactivate() {
    return copyWith(isActive: false);
  }

  /// Check if session is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if session is valid (active and not expired)
  bool get isValid {
    return isActive && !isExpired;
  }

  /// Get remaining time until expiration
  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  /// Get time since last activity
  Duration get timeSinceLastActivity {
    return DateTime.now().difference(lastActivity);
  }

  /// Check if session needs refresh (within 1 hour of expiration)
  bool get needsRefresh {
    return remainingTime.inHours <= 1;
  }

  /// Extend session by the timeout duration
  SessionModel extend() {
    final now = DateTime.now();
    return copyWith(
      lastActivity: now,
      expiresAt: now.add(timeoutDuration),
    );
  }

  /// Create a new session token (for security refresh)
  SessionModel refreshToken() {
    return copyWith(
      sessionToken: const Uuid().v4(),
      lastActivity: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel &&
        other.userId == userId &&
        other.sessionToken == sessionToken &&
        other.createdAt == createdAt &&
        other.lastActivity == lastActivity &&
        other.isActive == isActive &&
        other.timeoutDuration == timeoutDuration &&
        other.expiresAt == expiresAt;
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
      expiresAt,
    );
  }

  @override
  String toString() {
    return 'SessionModel(userId: $userId, sessionToken: ${sessionToken.substring(0, 8)}..., '
           'isActive: $isActive, isExpired: $isExpired, remainingTime: $remainingTime)';
  }
}