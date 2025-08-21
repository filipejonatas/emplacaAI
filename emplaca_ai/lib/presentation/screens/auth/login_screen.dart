import 'package:emplaca_ai/presentation/routes/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/auth/biometric_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _loadRememberedCredentials();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _animationController.forward();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final biometricService = BiometricService();
      final isAvailable = await biometricService.isBiometricAvailable();
      final isEnabled = await biometricService.isBiometricEnabled();

      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable;
          _biometricEnabled = isEnabled;
        });
      }
    } catch (e) {
      // Handle biometric service errors gracefully
      debugPrint('Biometric check failed: $e');
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  Future<void> _loadRememberedCredentials() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rememberedUsername = await authProvider.getRememberedUsername();

      if (rememberedUsername != null && mounted) {
        _usernameController.text = rememberedUsername;
        setState(() {
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Handle credential loading errors gracefully
      debugPrint('Failed to load remembered credentials: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_failedAttempts >= _maxFailedAttempts) {
      _showErrorSnackBar('Too many failed attempts. Please try again later.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success) {
        if (mounted) {
          _showSuccessSnackBar('Login successful!');

          // Reset failed attempts on successful login
          _failedAttempts = 0;

          // Navigate to main app after a short delay
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            await AppRouter.navigateToMainApp(context);
          }
        }
      } else {
        if (mounted) {
          _failedAttempts++;
          _shakeController.forward().then((_) {
            _shakeController.reset();
          });

          final remainingAttempts = _maxFailedAttempts - _failedAttempts;
          if (remainingAttempts > 0) {
            _showErrorSnackBar(
              'Invalid credentials. $remainingAttempts attempts remaining.',
            );
          } else {
            _showErrorSnackBar(
              'Account temporarily locked due to too many failed attempts.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_biometricAvailable || !_biometricEnabled) {
      _showErrorSnackBar('Biometric authentication is not available');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final biometricService = BiometricService();
      final success = await biometricService.authenticateWithBiometric();

      if (success) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loginSuccess = await authProvider.loginWithBiometric();

        if (loginSuccess && mounted) {
          _showSuccessSnackBar('Biometric login successful!');
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            await AppRouter.navigateToMainApp(context);
          }
        } else if (mounted) {
          _showErrorSnackBar('Biometric login failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Biometric authentication failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
          'To reset your password, you\'ll need to reinstall the app and set up your account again. '
          'This will delete all local data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you might implement security question recovery here
              _showErrorSnackBar('Please contact support for password recovery');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // App Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // Login Form
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _shakeAnimation.value * 10 *
                          (1 - _shakeAnimation.value) *
                          ((_shakeController.value * 4).floor() % 2 == 0 ? 1 : -1),
                          0,
                        ),
                        child: _buildLoginForm(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 16),

                  // Biometric Login Button
                  if (_biometricAvailable && _biometricEnabled)
                    _buildBiometricButton(),

                  const SizedBox(height: 24),

                  // Forgot Password Link
                  _buildForgotPasswordLink(),

                  const SizedBox(height: 40),

                  // App Version
                  _buildVersionInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_car,
            size: 50,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // App Name
        const Text(
          'EmplacaAI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Welcome back!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Field
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            enabled: !_isLoading,
          ),

          const SizedBox(height: 16),

          // Remember Me Checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: _isLoading ? null : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text('Remember username'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildBiometricButton() {
    return BiometricButton(
      onPressed: _isLoading ? null : _handleBiometricLogin,
      isLoading: _isLoading,
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _isLoading ? null : _showForgotPasswordDialog,
      child: const Text('Forgot Password?'),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 1.0.0',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Temporary BiometricButton widget - will be implemented in later checkpoints
class BiometricButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const BiometricButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.fingerprint),
      label: const Text('Login with Biometric'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Temporary BiometricService - will be implemented in later checkpoints
class BiometricService {
  Future<bool> isBiometricAvailable() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Return false for now until implemented
  }

  Future<bool> isBiometricEnabled() async {
    // Simulate biometric enabled check
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // Return false for now until implemented
  }

  Future<bool> authenticateWithBiometric() async {
    // Simulate biometric authentication
    await Future.delayed(const Duration(milliseconds: 1000));
    return false; // Return false for now until implemented
  }
}