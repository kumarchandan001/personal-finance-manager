/// ============================================
/// FINTELIA — Application Constants
/// Centralized configuration values
/// ============================================
library;

/// Core application constants used throughout the app.
class AppConstants {
  AppConstants._();

  // ---- App Info ----
  static const String appName = 'FINTELIA';
  static const String appVersion = '0.1.0';
  static const String appBuildNumber = '1';
  static const String appDescription =
      'AI-Powered Behavioral Personal Finance Management';

  // ---- API Configuration ----
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const int apiTimeoutMs = 30000;
  static const int apiReceiveTimeoutMs = 30000;

  // ---- Pagination ----
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ---- Animation Durations (milliseconds) ----
  static const int animDurationFast = 200;
  static const int animDurationNormal = 300;
  static const int animDurationSlow = 500;
  static const int animDurationSplash = 2000;

  // ---- Local Storage Keys ----
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyCurrency = 'currency';
  static const String keyLanguage = 'language';

  // ---- Default Values ----
  static const String defaultCurrency = 'INR';
  static const String defaultLanguage = 'en';
  static const String defaultRiskTolerance = 'moderate';

  // ---- Validation ----
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 255;
  static const int maxDescriptionLength = 1000;
  static const int maxTransactionAmountDigits = 12;
}
