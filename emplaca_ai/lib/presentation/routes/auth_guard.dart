import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../core/utils/session_manager.dart';

class AuthGuard {
  static final SessionManager _sessionManager = SessionManager.instance;

  static bool isProtectedRoute(String route) {
    return RouteConstants.protectedRoutes.contains(route);
  }

  static bool isPublicRoute(String route) {
    return RouteConstants.publicRoutes.contains(route);
  }

  /// Checks if user can access the requested route
  static Future<bool> canAccess(BuildContext context, String route) async {
    // Get the provider reference before any async operations
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionManager = _sessionManager;

    // Public routes are always accessible
    if (isPublicRoute(route)) {
      return true;
    }

    // Protected routes require authentication
    if (isProtectedRoute(route)) {
      // Check if user is authenticated
      if (!(authProvider.isAuthenticated ?? false)) {
        return false;
      }

      // Check if session is still valid
      final isSessionValid = await sessionManager.isSessionValid();
      if (!isSessionValid) {
        // Session expired, logout user (no context needed for logout)
        await authProvider.logout();
        return false;
      }

      // Update last activity
      await sessionManager.updateLastActivity();
      return true;
    }

    // Default: allow access
    return true;
  }

  /// Redirects to appropriate route based on authentication state
  /// This method is synchronous and safe to use with BuildContext
  static String getRedirectRoute(BuildContext context, String requestedRoute) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // If user is authenticated but trying to access auth screens
    if ((authProvider.isAuthenticated ?? false) && isPublicRoute(requestedRoute)) {
      // Redirect to main app unless it's splash screen
      if (requestedRoute != RouteConstants.splash) {
        return RouteConstants.defaultAuthenticatedRoute;
      }
    }

    // If user is not authenticated and trying to access protected routes
    if (!(authProvider.isAuthenticated ?? false) && isProtectedRoute(requestedRoute)) {
      return RouteConstants.defaultUnauthenticatedRoute;
    }

    // Return original route if no redirect needed
    return requestedRoute;
  }

  /// Middleware function to be called before navigation
  static Future<String?> beforeNavigation(
    BuildContext context,
    String route,
  ) async {
    final canAccessRoute = await canAccess(context, route);
    
    if (!canAccessRoute) {
      // Only call getRedirectRoute if context is still valid
      if (context.mounted) {
        final redirectRoute = getRedirectRoute(context, route);
        return redirectRoute != route ? redirectRoute : null;
      }
    }

    return null; // No redirect needed
  }

  /// Handles session timeout - accepts a callback to avoid context issues
  static Future<void> handleSessionTimeout(
    AuthProvider authProvider,
    VoidCallback? onSessionExpired,
  ) async {
    // Logout user
    await authProvider.logout();
    
    // Call the callback to handle UI updates
    onSessionExpired?.call();
  }

  /// Checks authentication state and redirects if necessary
  static Future<void> checkAuthAndRedirect(
    BuildContext context,
    VoidCallback? onSessionExpired,
  ) async {
    // Get provider reference before async operations
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionManager = _sessionManager;

    if (authProvider.isAuthenticated ?? false) {
      final isSessionValid = await sessionManager.isSessionValid();
      
      if (!isSessionValid) {
        await handleSessionTimeout(authProvider, onSessionExpired);
      } else {
        await sessionManager.updateLastActivity();
      }
    }
  }
}

class AuthProvider {
  get isAuthenticated => null;
  
  Future<void> logout() async {}

  Future getRememberedUsername() async {}

  Future login({required String username, required String password, required bool rememberMe}) async {}

  Future loginWithBiometric() async {}

  Future register({required String username, required String password, required String securityQuestion, required String securityAnswer}) async {}
}

/// Widget wrapper that provides authentication guard functionality
class AuthGuardWrapper extends StatefulWidget {
  final Widget child;
  final String route;

  const AuthGuardWrapper({
    super.key,
    required this.child,
    required this.route,
  });

  @override
  State<AuthGuardWrapper> createState() => _AuthGuardWrapperState();
}

class _AuthGuardWrapperState extends State<AuthGuardWrapper> {
  bool _isChecking = true;
  bool _canAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final canAccess = await AuthGuard.canAccess(context, widget.route);
      
      // Always check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _canAccess = canAccess;
          _isChecking = false;
        });

        // Handle redirect if access is denied
        if (!canAccess) {
          _handleAccessDenied();
        }
      }
    } catch (e) {
      // Handle any errors during access check
      if (mounted) {
        setState(() {
          _canAccess = false;
          _isChecking = false;
        });
      }
    }
  }

  void _handleAccessDenied() {
    // Use a post-frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final redirectRoute = AuthGuard.getRedirectRoute(context, widget.route);
        if (redirectRoute != widget.route) {
          Navigator.of(context).pushReplacementNamed(redirectRoute);
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_canAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You don\'t have permission to access this page.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteConstants.login,
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}