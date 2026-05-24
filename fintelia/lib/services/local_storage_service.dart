/// ============================================
/// FINTELIA — Local Storage Service
/// SharedPreferences wrapper for non-sensitive data
/// ============================================
library;

import 'package:fintelia/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing non-sensitive app preferences locally.
///
/// Uses [SharedPreferences] for simple key-value persistence
/// such as theme mode, language, and onboarding state.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  /// Create an instance asynchronously.
  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // ---- Theme ----

  /// Get stored theme mode: 'light', 'dark', or 'system'.
  String get themeMode =>
      _prefs.getString(AppConstants.keyThemeMode) ?? 'system';

  /// Save the selected theme mode.
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.keyThemeMode, mode);

  // ---- Onboarding ----

  /// Whether the user has completed onboarding.
  bool get isOnboardingComplete =>
      _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

  /// Mark onboarding as complete.
  Future<bool> setOnboardingComplete() =>
      _prefs.setBool(AppConstants.keyOnboardingComplete, true);

  // ---- Currency ----

  /// Get the preferred currency code.
  String get currency =>
      _prefs.getString(AppConstants.keyCurrency) ?? AppConstants.defaultCurrency;

  /// Set the preferred currency code.
  Future<bool> setCurrency(String currency) =>
      _prefs.setString(AppConstants.keyCurrency, currency);

  // ---- Language ----

  /// Get the preferred language code.
  String get language =>
      _prefs.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;

  /// Set the preferred language code.
  Future<bool> setLanguage(String language) =>
      _prefs.setString(AppConstants.keyLanguage, language);

  // ---- User ID (for quick access without secure storage) ----

  /// Get the stored user ID.
  String? get userId => _prefs.getString(AppConstants.keyUserId);

  /// Set the user ID.
  Future<bool> setUserId(String id) =>
      _prefs.setString(AppConstants.keyUserId, id);

  /// Clear the user ID.
  Future<bool> clearUserId() => _prefs.remove(AppConstants.keyUserId);

  // ---- Generic ----

  /// Clear all local preferences.
  Future<bool> clearAll() => _prefs.clear();
}
