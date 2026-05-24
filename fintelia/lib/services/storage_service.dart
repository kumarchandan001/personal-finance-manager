/// ============================================
/// FINTELIA — Storage Service
/// Wrapper for SharedPreferences (Web safe)
/// ============================================
library;

import 'package:fintelia/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing data (Web compatible).
class StorageService {
  StorageService();

  // ---- Token Management ----

  /// Save the access token.
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, token);
  }

  /// Retrieve the access token.
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAccessToken);
  }

  /// Save the refresh token.
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyRefreshToken, token);
  }

  /// Retrieve the refresh token.
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyRefreshToken);
  }

  /// Delete all stored tokens (used during logout).
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
  }

  // ---- Generic Key-Value ----

  /// Write a value securely.
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Read a securely stored value.
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Delete a stored value.
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all securely stored data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
