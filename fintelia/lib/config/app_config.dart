/// ============================================
/// FINTELIA — App Configuration
/// Environment-aware configuration management
/// ============================================
library;

/// Application environment enumeration.
enum AppEnvironment { development, staging, production }

/// Centralized app configuration based on the current environment.
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableLogging;

  /// Development configuration.
  static const AppConfig development = AppConfig._(
    environment: AppEnvironment.development,
    apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
    enableLogging: true,
  );

  /// Staging configuration.
  static const AppConfig staging = AppConfig._(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://staging-api.fintelia.com/api/v1',
    enableLogging: true,
  );

  /// Production configuration.
  static const AppConfig production = AppConfig._(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.fintelia.com/api/v1',
    enableLogging: false,
  );

  /// Whether the app is in development mode.
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Whether the app is in production mode.
  bool get isProduction => environment == AppEnvironment.production;

  /// Resolve config from environment name string.
  static AppConfig fromString(String env) {
    switch (env.toLowerCase()) {
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return development;
    }
  }
}
