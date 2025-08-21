class RouteConstants {
  // Authentication Routes
  static const String splash = '/';
  static const String setup = '/setup';
  static const String login = '/login';
  static const String biometricSetup = '/biometric-setup';
  static const String securitySettings = '/security-settings';

  // Main App Routes
  static const String vehicles = '/vehicles';
  static const String addVehicle = '/vehicles/add';
  static const String editVehicle = '/vehicles/edit';
  static const String tripAssignment = '/trip-assignment';
  static const String dailyActivity = '/daily-activity';
  static const String history = '/history';
  static const String export = '/export';

  // Route Names for Navigation
  static const String splashName = 'splash';
  static const String setupName = 'setup';
  static const String loginName = 'login';
  static const String biometricSetupName = 'biometric-setup';
  static const String securitySettingsName = 'security-settings';
  static const String vehiclesName = 'vehicles';
  static const String addVehicleName = 'add-vehicle';
  static const String editVehicleName = 'edit-vehicle';
  static const String tripAssignmentName = 'trip-assignment';
  static const String dailyActivityName = 'daily-activity';
  static const String historyName = 'history';
  static const String exportName = 'export';

  // Protected Routes (require authentication)
  static const List<String> protectedRoutes = [
    vehicles,
    addVehicle,
    editVehicle,
    tripAssignment,
    dailyActivity,
    history,
    export,
    securitySettings,
  ];

  // Public Routes (no authentication required)
  static const List<String> publicRoutes = [
    splash,
    setup,
    login,
    biometricSetup,
  ];

  // Initial Routes based on app state
  static const String initialRoute = splash;
  static const String defaultAuthenticatedRoute = vehicles;
  static const String defaultUnauthenticatedRoute = login;
}