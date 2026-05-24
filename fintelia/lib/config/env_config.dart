/// ============================================
/// FINTELIA — Environment Variable Loader
/// ============================================
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads and provides typed access to environment variables.
class EnvConfig {
  EnvConfig._();

  /// Load the .env file. Call this before accessing any values.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    // Web uses 127.0.0.1, Android emulator uses 10.0.2.2
    return kIsWeb
        ? 'http://127.0.0.1:8000/api/v1'
        : 'http://10.0.2.2:8000/api/v1';
  }

  /// API request timeout in milliseconds.
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;

  /// Gemini API key for AI features.
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Current app environment name.
  static String get appEnv =>
      dotenv.env['APP_ENV'] ?? 'development';

  /// Whether logging is enabled.
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
}
