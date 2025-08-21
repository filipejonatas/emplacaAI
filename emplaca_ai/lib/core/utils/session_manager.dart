import 'dart:async';
import 'package:flutter/services.dart';
import '../../../data/models/session_model.dart';
import '../../../data/datasources/local/secure_storage_service.dart';

/// Manages user sessions with timeout and security features
class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();

  SessionManager._();

  final SecureStorageService _secureStorage = SecureStorageService();

  SessionModel? _currentSession;
  Timer? _sessionTimer;
  Timer? _activityTimer;

  // Session configuration
  static const Duration defaultTimeout = Duration(hours: 8);
  static const Duration activityCheckInterval = Duration(minutes: 1);
  static const Duration warningBeforeExpiry = Duration(minutes: 5);

  // Callbacks
  Function()? onSessionExpired;
  Function()? onSessionWarning;
  Function(SessionModel session)? onSessionUpdated;

  /// Initialize session manager
  Future<void> initialize() async {
    await _loadExistingSession();
    _startActivityTimer();
    _setupAppLifecycleListener();
  }

  /// Create a new session
  Future<SessionModel> createSession(String userId, {Duration? timeout}) async {
    // Clear any existing session
    await clearSession();

    // Create new session
    _currentSession = SessionModel.create(
      userId: userId,
      timeoutDuration: timeout ?? defaultTimeout,
    );

    // Store session token
    await _secureStorage.storeSessionToken(_currentSession!.sessionToken);

    // Start session timer
    _startSessionTimer();

    // Notify listeners
    onSessionUpdated?.call(_currentSession!);

    return _currentSession!;
  }

  /// Load existing session from storage
  Future<SessionModel?> _loadExistingSession() async {
    try {
      final sessionToken = await _secureStorage.getSessionToken();
      if (sessionToken == null) return null;

      final userId = await _secureStorage.getUserId();
      if (userId == null) return null;

      // For simplicity, we'll create a session with default timeout
      // In a real app, you'd store the full session data
      _currentSession = SessionModel.create(userId: userId);

      // Check if session is still valid
      if (_currentSession!.isValid) {
        _startSessionTimer();
        return _currentSession;
      } else {
        await clearSession();
        return null;
      }
    } catch (e) {
      await clearSession();
      return null;
    }
  }

  /// Get current session
  SessionModel? get currentSession => _currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentSession?.isValid ?? false;

  /// Update session activity
  Future<void> updateActivity() async {
    if (_currentSession == null || !_currentSession!.isValid) return;

    _currentSession = _currentSession!.updateActivity();

    // Restart session timer with new expiration
    _startSessionTimer();

    // Notify listeners
    onSessionUpdated?.call(_currentSession!);
  }

  /// Extend current session
  Future<void> extendSession() async {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.extend();
    _startSessionTimer();

    // Notify listeners
    onSessionUpdated?.call(_currentSession!);
  }

  /// Clear current session
  Future<void> clearSession() async {
    _currentSession = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;

    await _secureStorage.clearSession();
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();

    if (_currentSession == null || !_currentSession!.isValid) return;

    final remainingTime = _currentSession!.remainingTime;

    // Set warning timer
    final warningTime = remainingTime - warningBeforeExpiry;
    if (warningTime.isNegative == false) {
      Timer(warningTime, () {
        onSessionWarning?.call();
      });
    }

    // Set expiration timer
    _sessionTimer = Timer(remainingTime, () {
      _handleSessionExpiry();
    });
  }

  /// Handle session expiry
  void _handleSessionExpiry() {
    clearSession();
    onSessionExpired?.call();
  }

  /// Start activity monitoring timer
  void _startActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(activityCheckInterval, (timer) {
      _checkSessionValidity();
    });
  }

  /// Check if session is still valid
  void _checkSessionValidity() {
    if (_currentSession != null && _currentSession!.isExpired) {
      _handleSessionExpiry();
    }
  }

  /// Setup app lifecycle listener for security
  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      switch (message) {
        case 'AppLifecycleState.paused':
          await _handleAppPaused();
          break;
        case 'AppLifecycleState.resumed':
          await _handleAppResumed();
          break;
        case 'AppLifecycleState.detached':
          await _handleAppDetached();
          break;
      }
      return null;
    });
  }

  /// Handle app being paused (backgrounded)
  Future<void> _handleAppPaused() async {
    // Store the time when app was paused
    await _secureStorage.storeSecureData(
      'app_paused_at',
      DateTime.now().toIso8601String(),
    );
  }

  /// Handle app being resumed (foregrounded)
  Future<void> _handleAppResumed() async {
    final pausedAtString = await _secureStorage.getSecureData('app_paused_at');
    if (pausedAtString != null) {
      final pausedAt = DateTime.parse(pausedAtString);
      final backgroundDuration = DateTime.now().difference(pausedAt);

      // If app was in background for too long, expire session
      if (backgroundDuration > const Duration(minutes: 15)) {
        _handleSessionExpiry();
        return;
      }
    }

    // Clean up pause timestamp
    await _secureStorage.deleteSecureData('app_paused_at');

    // Check session validity
    _checkSessionValidity();
  }

  /// Handle app being detached
  Future<void> _handleAppDetached() async {
    // Clear sensitive data when app is being terminated
    await _secureStorage.deleteSecureData('app_paused_at');
  }

  /// Get session info for debugging
  Map<String, dynamic> getSessionInfo() {
    if (_currentSession == null) {
      return {'status': 'No active session'};
    }

    return {
      'userId': _currentSession!.userId,
      'isValid': _currentSession!.isValid,
      'isExpired': _currentSession!.isExpired,
      'remainingTime': _currentSession!.remainingTime.toString(),
      'timeSinceLastActivity':
          _currentSession!.timeSinceLastActivity.toString(),
      'needsRefresh': _currentSession!.needsRefresh,
    };
  }

  /// Refresh session token for security
  Future<void> refreshSessionToken() async {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.refreshToken();
    await _secureStorage.storeSessionToken(_currentSession!.sessionToken);

    // Notify listeners
    onSessionUpdated?.call(_currentSession!);
  }

  /// Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _activityTimer?.cancel();
    _sessionTimer = null;
    _activityTimer = null;
    onSessionExpired = null;
    onSessionWarning = null;
    onSessionUpdated = null;
  }

  /// Force logout (clear session and notify)
  Future<void> forceLogout() async {
    await clearSession();
    onSessionExpired?.call();
  }

  /// Check if session needs refresh
  bool get needsRefresh => _currentSession?.needsRefresh ?? false;

  /// Get remaining session time
  Duration get remainingTime => _currentSession?.remainingTime ?? Duration.zero;

  /// Get time until warning
  Duration get timeUntilWarning {
    if (_currentSession == null) return Duration.zero;
    final warningTime = _currentSession!.remainingTime - warningBeforeExpiry;
    return warningTime.isNegative ? Duration.zero : warningTime;
  }

  Future isSessionValid() async {}

  Future<void> updateLastActivity() async {}
}
