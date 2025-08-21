import 'package:flutter/material.dart';
import '../../core/constants/route_constants.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/setup_screen.dart';
import '../screens/auth/login_screen.dart';
import 'auth_guard.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? RouteConstants.splash;
    final Map<String, dynamic> arguments = 
        settings.arguments as Map<String, dynamic>? ?? {};

    switch (routeName) {
      // Authentication Routes
      case RouteConstants.splash:
        return _buildRoute(
          const SplashScreen(),
          settings,
          isProtected: false,
        );

      case RouteConstants.setup:
        return _buildRoute(
          const SetupScreen(),
          settings,
          isProtected: false,
        );

      case RouteConstants.login:
        return _buildRoute(
          const LoginScreen(),
          settings,
          isProtected: false,
        );

      case RouteConstants.biometricSetup:
        return _buildRoute(
          const BiometricSetupScreen(),
          settings,
          isProtected: false,
        );

      case RouteConstants.securitySettings:
        return _buildRoute(
          const SecuritySettingsScreen(),
          settings,
          isProtected: true,
        );

      // Vehicle Management Routes
      case RouteConstants.vehicles:
        return _buildRoute(
          const VehiclesScreen(),
          settings,
          isProtected: true,
        );

      case RouteConstants.addVehicle:
        return _buildRoute(
          const AddVehicleScreen(),
          settings,
          isProtected: true,
        );

      case RouteConstants.editVehicle:
        final String? vehicleId = arguments['vehicleId'] as String?;
        return _buildRoute(
          EditVehicleScreen(vehicleId: vehicleId),
          settings,
          isProtected: true,
        );

      // Trip Management Routes
      case RouteConstants.tripAssignment:
        return _buildRoute(
          const TripAssignmentScreen(),
          settings,
          isProtected: true,
        );

      case RouteConstants.dailyActivity:
        return _buildRoute(
          const DailyActivityScreen(),
          settings,
          isProtected: true,
        );

      // History and Export Routes
      case RouteConstants.history:
        return _buildRoute(
          const HistoryScreen(),
          settings,
          isProtected: true,
        );

      case RouteConstants.export:
        final DateTime? selectedDate = arguments['selectedDate'] as DateTime?;
        return _buildRoute(
          ExportScreen(selectedDate: selectedDate),
          settings,
          isProtected: true,
        );

      // Default Route (404)
      default:
        return _buildRoute(
          const NotFoundScreen(),
          settings,
          isProtected: false,
        );
    }
  }

  static PageRoute<dynamic> _buildRoute(
    Widget screen,
    RouteSettings settings, {
    bool isProtected = false,
  }) {
    Widget finalScreen = screen;

    // Wrap protected routes with AuthGuard
    if (isProtected) {
      finalScreen = AuthGuardWrapper(
        route: settings.name ?? RouteConstants.splash,
        child: screen,
      );
    }

    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => finalScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          animation,
          secondaryAnimation,
          child,
          settings.name ?? RouteConstants.splash,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Widget _buildPageTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    String routeName,
  ) {
    // Different transitions for different route types
    if (_isAuthRoute(routeName)) {
      // Fade transition for auth screens
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    } else {
      // Slide transition for main app screens
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    }
  }

  static bool _isAuthRoute(String routeName) {
    return [
      RouteConstants.splash,
      RouteConstants.setup,
      RouteConstants.login,
      RouteConstants.biometricSetup,
    ].contains(routeName);
  }

  // Navigation helper methods
  static Future<void> navigateToSetup(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.setup,
      (route) => false,
    );
  }

  static Future<void> navigateToLogin(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.login,
      (route) => false,
    );
  }

  static Future<void> navigateToMainApp(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.vehicles,
      (route) => false,
    );
  }

  static Future<void> navigateToVehicleEdit(
    BuildContext context,
    String vehicleId,
  ) {
    return Navigator.of(context).pushNamed(
      RouteConstants.editVehicle,
      arguments: {'vehicleId': vehicleId},
    );
  }

  static Future<void> navigateToExport(
    BuildContext context, {
    DateTime? selectedDate,
  }) {
    return Navigator.of(context).pushNamed(
      RouteConstants.export,
      arguments: {'selectedDate': selectedDate},
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

// Temporary placeholder screens - these will be implemented in later checkpoints
class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Setup'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Biometric Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #9',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #10',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Vehicles Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #4',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Add Vehicle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #4',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EditVehicleScreen extends StatelessWidget {
  final String? vehicleId;

  const EditVehicleScreen({super.key, this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.edit,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Vehicle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vehicleId != null 
                  ? 'Editing Vehicle ID: $vehicleId'
                  : 'No vehicle ID provided',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature will be implemented in Checkpoint #4',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TripAssignmentScreen extends StatelessWidget {
  const TripAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Assignment'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Trip Assignment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #5',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DailyActivityScreen extends StatelessWidget {
  const DailyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Activity'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.today,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Daily Activity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #5',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Trip History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be implemented in Checkpoint #8',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ExportScreen extends StatelessWidget {
  final DateTime? selectedDate;

  const ExportScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.file_download,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'PDF Export',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedDate != null
                  ? 'Export for: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'No date selected',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature will be implemented in Checkpoint #7',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 404 Not Found Screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The requested page could not be found.',
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
                  RouteConstants.splash,
                  (route) => false,
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}