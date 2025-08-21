import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// A reusable biometric authentication button widget
/// Provides a consistent UI for biometric login across the app
class BiometricButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? label;
  final IconData? icon;
  final bool enabled;

  const BiometricButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.label,
    this.icon,
    this.enabled = true,
  });

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _biometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable;
          _availableBiometrics = availableBiometrics;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
          _availableBiometrics = [];
        });
      }
    }
  }

  IconData _getBiometricIcon() {
    if (widget.icon != null) return widget.icon!;

    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility;
    } else {
      return Icons.security;
    }
  }

  String _getBiometricLabel() {
    if (widget.label != null) return widget.label!;

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Login with Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Login with Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Login with Iris';
    } else {
      return 'Login with Biometric';
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.enabled &&
        _biometricAvailable &&
        _availableBiometrics.isNotEmpty &&
        !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            child: OutlinedButton.icon(
              onPressed: isEnabled ? widget.onPressed : null,
              icon: widget.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      _getBiometricIcon(),
                      size: 20,
                    ),
              label: Text(
                widget.isLoading ? 'Authenticating...' : _getBiometricLabel(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: isEnabled
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                  width: 1.5,
                ),
                foregroundColor:
                    isEnabled ? theme.colorScheme.primary : theme.disabledColor,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}
