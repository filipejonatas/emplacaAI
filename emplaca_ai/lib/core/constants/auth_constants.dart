/// Authentication-related constants
class AuthConstants {
  // Private constructor to prevent instantiation
  AuthConstants._();

  // Session Configuration
  static const Duration defaultSessionTimeout = Duration(hours: 8);
  static const Duration sessionWarningTime = Duration(minutes: 5);
  static const Duration activityCheckInterval = Duration(minutes: 1);
  static const Duration maxBackgroundTime = Duration(minutes: 15);

  // Security Configuration
  static const int maxFailedLoginAttempts = 5;
  static const Duration accountLockoutDuration = Duration(minutes: 15);
  static const int passwordHashIterations = 10000;
  static const int saltLength = 32;
  static const int sessionTokenLength = 32;

  // Password Requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  // Biometric Configuration
  static const String biometricReason = 'Please authenticate to access EmplacaAI';
  static const Duration biometricTimeout = Duration(seconds: 30);

  // Storage Keys (used internally by SecureStorageService)
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String hashedPasswordKey = 'hashed_password';
  static const String saltKey = 'salt';
  static const String sessionTokenKey = 'session_token';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String lastLoginKey = 'last_login';
  static const String failedAttemptsKey = 'failed_attempts';
  static const String lockoutUntilKey = 'lockout_until';
  static const String securityQuestionKey = 'security_question';
  static const String securityAnswerHashKey = 'security_answer_hash';
  static const String appPausedAtKey = 'app_paused_at';

  // Error Messages
  static const String userNotFoundError = 'No user found. Please register first.';
  static const String invalidCredentialsError = 'Invalid username or password.';
  static const String userAlreadyExistsError = 'User already exists. Please login instead.';
  static const String weakPasswordError = 'Password does not meet minimum requirements.';
  static const String accountLockedError = 'Account is locked due to too many failed attempts.';
  static const String sessionExpiredError = 'Your session has expired. Please login again.';
  static const String biometricNotAvailableError = 'Biometric authentication is not available.';
  static const String biometricNotEnrolledError = 'No biometric credentials are enrolled.';
  static const String securityAnswerIncorrectError = 'Security answer is incorrect.';
  static const String currentPasswordIncorrectError = 'Current password is incorrect.';
  static const String userNotAuthenticatedError = 'User not authenticated.';

  // Success Messages
  static const String registrationSuccessMessage = 'User registered successfully.';
  static const String loginSuccessMessage = 'Login successful.';
  static const String logoutSuccessMessage = 'Logout successful.';
  static const String passwordChangedSuccessMessage = 'Password changed successfully.';
  static const String passwordResetSuccessMessage = 'Password reset successfully.';
  static const String biometricEnabledSuccessMessage = 'Biometric authentication enabled.';
  static const String biometricDisabledSuccessMessage = 'Biometric authentication disabled.';
  static const String sessionExtendedSuccessMessage = 'Session extended successfully.';

  // Validation Messages
  static const String usernameRequiredMessage = 'Username is required.';
  static const String passwordRequiredMessage = 'Password is required.';
  static const String usernameTooShortMessage = 'Username must be at least $minUsernameLength characters.';
  static const String usernameTooLongMessage = 'Username must be no more than $maxUsernameLength characters.';
  static const String passwordTooShortMessage = 'Password must be at least $minPasswordLength characters.';
  static const String passwordTooLongMessage = 'Password must be no more than $maxPasswordLength characters.';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match.';
  static const String securityQuestionRequiredMessage = 'Security question is required.';
  static const String securityAnswerRequiredMessage = 'Security answer is required.';

  // Password Strength Requirements
  static const List<String> passwordRequirements = [
    'At least $minPasswordLength characters long',
    'Contains uppercase letters (A-Z)',
    'Contains lowercase letters (a-z)',
    'Contains numbers (0-9)',
    'Contains special characters (!@#\$%^&*)',
  ];

  // Session Warning Messages
  static const String sessionWarningTitle = 'Session Expiring Soon';
  static const String sessionWarningMessage = 'Your session will expire in 5 minutes. Would you like to extend it?';
  static const String sessionExpiredTitle = 'Session Expired';
  static const String sessionExpiredMessage = 'Your session has expired for security reasons. Please login again.';

  // Biometric Messages
  static const String biometricSetupTitle = 'Setup Biometric Authentication';
  static const String biometricSetupMessage = 'Would you like to enable biometric authentication for faster login?';
  static const String biometricLoginTitle = 'Biometric Login';
  static const String biometricLoginMessage = 'Use your fingerprint or face to login quickly and securely.';

  // Account Lockout Messages
  static const String accountLockoutTitle = 'Account Locked';
  static String getAccountLockoutMessage(int minutes) {
    return 'Your account has been locked due to too many failed login attempts. '
           'Please try again in $minutes minute${minutes != 1 ? 's' : ''}.';
  }

  static String getFailedAttemptsMessage(int attempts, int maxAttempts) {
    final remaining = maxAttempts - attempts;
    return 'Invalid credentials. You have $remaining attempt${remaining != 1 ? 's' : ''} remaining '
           'before your account is locked.';
  }

  // Regular Expressions for Validation
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final RegExp uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp digitRegex = RegExp(r'[0-9]');
  static final RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  // App Lifecycle States
  static const String appStateResumed = 'AppLifecycleState.resumed';
  static const String appStatePaused = 'AppLifecycleState.paused';
  static const String appStateDetached = 'AppLifecycleState.detached';
  static const String appStateInactive = 'AppLifecycleState.inactive';

  // Debug Messages
  static const String debugSessionCreated = 'Session created successfully';
  static const String debugSessionExpired = 'Session expired';
  static const String debugSessionExtended = 'Session extended';
  static const String debugActivityUpdated = 'Session activity updated';
  static const String debugAppPaused = 'App paused - storing timestamp';
  static const String debugAppResumed = 'App resumed - checking session validity';
  static const String debugBiometricEnabled = 'Biometric authentication enabled';
  static const String debugBiometricDisabled = 'Biometric authentication disabled';

  // Feature Flags (for future use)
  static const bool enableBiometricAuth = true;
  static const bool enableSecurityQuestions = true;
  static const bool enableSessionWarnings = true;
  static const bool enableAccountLockout = true;
  static const bool enableDebugLogging = false; // Set to false in production

  // Timeouts and Delays
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration biometricPromptTimeout = Duration(seconds: 60);
  static const Duration splashScreenMinDuration = Duration(seconds: 2);
  static const Duration loadingIndicatorDelay = Duration(milliseconds: 500);

  // UI Constants
  static const double passwordStrengthIndicatorHeight = 4.0;
  static const int maxRecentUsers = 5; // For future multi-user support
  static const int sessionWarningCountdown = 300; // 5 minutes in seconds
}