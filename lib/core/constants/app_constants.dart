class AppConstants {
  // API
  static const String apiBaseUrl = 'https://jsonplaceholder.typicode.com/';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstRun = 'first_run';

  // App Info
  static const String appName = 'CloseShare';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Network
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 50;

  // Image
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
  static const String appLogoPath = 'assets/images/app_logo.png';
}
