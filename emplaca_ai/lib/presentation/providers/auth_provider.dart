import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../core/utils/session_manager.dart';

/// Provider for managing authentication state and operations
/// Handles user login, logout, registration, and session management
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final SessionManager _sessionManager = SessionManager.instance;

  // Current state
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasUser => _currentUser != null;

  /// Initialize the provider and check for existing session
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      _currentUser = _authService.currentUser;
      _isAuthenticated = _authService.isAuthenticated;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user (first-time setup)
  Future<bool> register({
    required String username,
    required String password,
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.registerUser(
        username: username,
        password: password,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );

      if (result.isSuccess) {
        _currentUser = _authService.currentUser;
        _isAuthenticated = _authService.isAuthenticated;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Login with username and password
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.loginUser(
        username: username,
        password: password,
      );

      if (result.isSuccess) {
        _currentUser = _authService.currentUser;
        _isAuthenticated = _authService.isAuthenticated;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Login with biometric authentication
  Future<bool> loginWithBiometric() async {
    if (_currentUser == null) {
      _setError('No user configured for biometric login');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check if biometric is enabled
      final biometricEnabled = await _authService.isBiometricEnabled();
      if (!biometricEnabled) {
        _setError('Biometric authentication not enabled');
        _setLoading(false);
        return false;
      }

      // For biometric login, we would need to implement this in AuthService
      // For now, we'll return false and suggest enabling it first
      _setError('Biometric login not yet implemented in AuthService');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Biometric login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
    } catch (e) {
      // Log error but don't prevent logout
      debugPrint('Error during logout: $e');
    } finally {
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
      _setLoading(false);
    }
  }

  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _currentUser = _authService.currentUser;
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Setup biometric authentication
  Future<bool> setupBiometric() async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.setBiometricEnabled(true);
      if (result.isSuccess) {
        _currentUser = _authService.currentUser;
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Biometric setup failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.setBiometricEnabled(false);
      if (result.isSuccess) {
        _currentUser = _authService.currentUser;
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Biometric disable failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _authService.isBiometricEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Validate session and refresh if needed
  Future<bool> validateSession() async {
    try {
      final isValid = _sessionManager.isAuthenticated;
      if (!isValid) {
        await logout();
        return false;
      }

      // Refresh user data
      _currentUser = _authService.currentUser;
      _isAuthenticated = _authService.isAuthenticated;
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  /// Check if user setup is required (first time launch)
  Future<bool> isSetupRequired() async {
    try {
      // Check if user credentials exist
      return !await _authService.isAuthenticated;
    } catch (e) {
      return true; // Default to requiring setup if we can't determine
    }
  }

  /// Reset password with security answer
  Future<bool> resetPassword({
    required String securityAnswer,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.resetPasswordWithSecurityAnswer(
        securityAnswer: securityAnswer,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _clearError();
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Get security question
  Future<String?> getSecurityQuestion() async {
    try {
      return await _authService.getSecurityQuestion();
    } catch (e) {
      return null;
    }
  }

  /// Check if account is locked
  Future<bool> isAccountLocked() async {
    try {
      return await _authService.isAccountLocked();
    } catch (e) {
      return false;
    }
  }

  /// Get failed attempts count
  Future<int> getFailedAttempts() async {
    try {
      return await _authService.getFailedAttempts();
    } catch (e) {
      return 0;
    }
  }

  /// Get lockout remaining time
  Future<Duration?> getLockoutRemainingTime() async {
    try {
      return await _authService.getLockoutRemainingTime();
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
