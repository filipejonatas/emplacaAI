import 'package:emplaca_ai/core/utils/crypto_utils.dart';
import 'package:emplaca_ai/presentation/routes/auth_guard.dart' as AuthGuard;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/local/secure_storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/auth/setup_form.dart';
import '../../widgets/auth/password_strength_indicator.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityQuestionController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureSecurityAnswer = true;
  String _selectedSecurityQuestion = 'What was the name of your first pet?';
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  final List<String> _securityQuestions = [
    'What was the name of your first pet?',
    'What city were you born in?',
    'What was your first car model?',
    'What is your mother\'s maiden name?',
    'What was the name of your elementary school?',
  ];

  get validators => null;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupPasswordListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _animationController.forward();
  }

  void _setupPasswordListener() {
    _passwordController.addListener(() {
      final strength = Validators.getPasswordStrength(_passwordController.text);
      if (strength != _passwordStrength) {
        setState(() {
          _passwordStrength = strength;
        });
      }
    });
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordStrength == PasswordStrength.weak) {
      _showErrorSnackBar('Please choose a stronger password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        securityQuestion: _selectedSecurityQuestion,
        securityAnswer: _securityAnswerController.text.trim(),
      );

      if (success) {
        // Mark app as setup completed
        final secureStorage = SecureStorageService();
        await secureStorage.write('app_setup_completed', 'true');

        if (mounted) {
          _showSuccessSnackBar('Account created successfully!');

          // Navigate to main app after a short delay
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            await AppRouter.navigateToMainApp(context);
          }
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Failed to create account. Please try again.');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityQuestionController.dispose();
    _securityAnswerController.dispose();
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
                  const SizedBox(height: 40),

                  // Welcome Header
                  _buildWelcomeHeader(),

                  const SizedBox(height: 40),

                  // Setup Form
                  _buildSetupForm(),

                  const SizedBox(height: 32),

                  // Setup Button
                  _buildSetupButton(),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  _buildTermsAndPrivacy(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        const Text(
          'Welcome to EmplacaAI',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Let\'s set up your account to get started',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSetupForm() {
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
            validator: Validators.validateUsername,
            textInputAction: TextInputAction.next,
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
            validator: Validators.validatePassword,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 8),

          // Password Strength Indicator
          PasswordStrengthIndicator(strength: _passwordStrength),

          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 24),

          // Security Question Section
          const Text(
            'Security Question (for password recovery)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Security Question Dropdown
          DropdownButtonFormField<String>(
            value: _selectedSecurityQuestion,
            decoration: const InputDecoration(
              labelText: 'Select a security question',
              prefixIcon: Icon(Icons.help_outline),
              border: OutlineInputBorder(),
            ),
            items: _securityQuestions.map((question) {
              return DropdownMenuItem(
                value: question,
                child: Text(
                  question,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSecurityQuestion = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Security Answer Field
          TextFormField(
            controller: _securityAnswerController,
            obscureText: _obscureSecurityAnswer,
            decoration: InputDecoration(
              labelText: 'Your answer',
              prefixIcon: const Icon(Icons.key),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSecurityAnswer
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureSecurityAnswer = !_obscureSecurityAnswer;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide an answer';
              }
              if (value.trim().length < 3) {
                return 'Answer must be at least 3 characters';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSetup(),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSetup,
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
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Text(
      'By creating an account, you agree to our Terms of Service and Privacy Policy',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({Key? key, required this.strength})
      : super(key: key);

  Color _getColor() {
    switch (strength) {
      case PasswordStrength.strong:
        return Colors.green;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.weak:
        return Colors.red;
    }
  }

  String _getText() {
    switch (strength) {
      case PasswordStrength.strong:
        return 'Strong password';
      case PasswordStrength.medium:
        return 'Medium password';
      case PasswordStrength.weak:
        return 'Weak password';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: strength == PasswordStrength.strong
                ? 1.0
                : strength == PasswordStrength.medium
                    ? 0.6
                    : 0.3,
            backgroundColor: Colors.grey[300],
            color: _getColor(),
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _getText(),
          style: TextStyle(
            color: _getColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
