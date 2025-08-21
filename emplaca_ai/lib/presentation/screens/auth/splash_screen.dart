// lib/presentation/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/utils/session_manager.dart';
import '../../../data/datasources/local/secure_storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../routes/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _textSlideAnimation;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAppState();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text fade animation
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  Future<void> _checkAppState() async {
    try {
      // Minimum splash screen display time
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted || _isNavigating) return;

      // Get required services
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final secureStorage = SecureStorageService();
      final sessionManager = SessionManager.instance;

      // Check if this is the first time opening the app
      final isFirstTime = await _isFirstTimeUser(secureStorage);

      if (isFirstTime) {
        await _navigateToSetup();
        return;
      }

      // Check if user has stored credentials
      final hasStoredCredentials = await _checkStoredCredentials(secureStorage);

      if (!hasStoredCredentials) {
        await _navigateToLogin();
        return;
      }

      // Check session validity and restore if possible
      await _handleSessionValidation(authProvider, sessionManager);

    } catch (e) {
      // Error occurred, go to login as fallback
      debugPrint('Splash screen error: $e');
      if (mounted && !_isNavigating) {
        await _navigateToLogin();
      }
    }
  }

  Future<bool> _isFirstTimeUser(SecureStorageService secureStorage) async {
    try {
      final hasBeenSetup = await secureStorage.read('app_setup_completed');
      return hasBeenSetup == null;
    } catch (e) {
      debugPrint('Error checking first time user: $e');
      // If we can't check, assume it's first time for safety
      return true;
    }
  }

  Future<bool> _checkStoredCredentials(SecureStorageService secureStorage) async {
    try {
      return await secureStorage.hasCredentials();
    } catch (e) {
      debugPrint('Error checking stored credentials: $e');
      return false;
    }
  }

  Future<void> _handleSessionValidation(
    AuthProvider authProvider,
    SessionManager sessionManager,
  ) async {
    try {
      final isSessionValid = await sessionManager.isSessionValid();

      if (isSessionValid) {
        // Valid session exists, try to restore authentication state
        final success = await authProvider.restoreSession();
        
        if (success) {
          await _navigateToMainApp();
        } else {
          await _navigateToLogin();
        }
      } else {
        await _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Error during session validation: $e');
      await _navigateToLogin();
    }
  }

  Future<void> _navigateToSetup() async {
    if (!mounted || _isNavigating) return;
    
    _isNavigating = true;
    try {
      await AppRouter.navigateToSetup(context);
    } catch (e) {
      debugPrint('Navigation to setup failed: $e');
      if (mounted) {
        await _navigateToLogin();
      }
    }
  }

  Future<void> _navigateToLogin() async {
    if (!mounted || _isNavigating) return;
    
    _isNavigating = true;
    try {
      await AppRouter.navigateToLogin(context);
    } catch (e) {
      debugPrint('Navigation to login failed: $e');
      // Last resort - show error dialog
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  Future<void> _navigateToMainApp() async {
    if (!mounted || _isNavigating) return;
    
    _isNavigating = true;
    try {
      await AppRouter.navigateToMainApp(context);
    } catch (e) {
      debugPrint('Navigation to main app failed: $e');
      if (mounted) {
        await _navigateToLogin();
      }
    }
  }

  void _showErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
          'An error occurred while starting the app. Please restart the application.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try to navigate to login again
              _navigateToLogin();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_car,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // App Name and Tagline Section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Name
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textAnimation,
                        child: const Text(
                          'EmplacaAI',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textAnimation,
                        child: const Text(
                          'Vehicle & Driver Tracking',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Loading Text
                    FadeTransition(
                      opacity: _textAnimation,
                      child: const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Version Info
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FadeTransition(
                  opacity: _textAnimation,
                  child: const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Temporary implementations for missing dependencies
// These will be replaced with actual implementations in later checkpoints

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  static SessionManager get instance => _instance;
  
  SessionManager._internal();

  Future<bool> isSessionValid() async {
    // Simulate session validation
    await Future.delayed(const Duration(milliseconds: 300));
    // For now, always return false to force login
    return false;
  }

  Future<void> updateLastActivity() async {
    // Simulate updating last activity
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> clearSession() async {
    // Simulate clearing session
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class SecureStorageService {
  Future<String?> read(String key) async {
    // Simulate reading from secure storage
    await Future.delayed(const Duration(milliseconds: 200));
    // For now, return null to simulate no stored data
    return null;
  }

  Future<void> write(String key, String value) async {
    // Simulate writing to secure storage
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> delete(String key) async {
    // Simulate deleting from secure storage
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<bool> hasCredentials() async {
    // Simulate checking for stored credentials
    await Future.delayed(const Duration(milliseconds: 200));
    // For now, return false to force setup/login
    return false;
  }

  Future<void> clear() async {
    // Simulate clearing all secure storage
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// Temporary AuthProvider extension methods
extension AuthProviderExtension on AuthProvider {
  Future<String?> getRememberedUsername() async {
    // Simulate getting remembered username
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  Future<bool> restoreSession() async {
    // Simulate session restoration
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  Future<bool> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    // Simulate login
    await Future.delayed(const Duration(milliseconds: 1000));
    return false;
  }

  Future<bool> loginWithBiometric() async {
    // Simulate biometric login
    await Future.delayed(const Duration(milliseconds: 1000));
    return false;
  }

  Future<void> logout() async {
    // Simulate logout
    await Future.delayed(const Duration(milliseconds: 500));
  }

  bool? get isAuthenticated => null;
}