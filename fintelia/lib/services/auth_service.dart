/// ============================================
/// FINTELIA — Auth Service
/// Real API authentication + optional Firebase
/// ============================================
library;

import 'package:dio/dio.dart';
import 'package:fintelia/core/network/api_client.dart';
import 'package:fintelia/services/storage_service.dart';

/// Authentication service connecting to FastAPI backend.
///
/// Supports email/password login via API and optional Firebase auth.
/// Manages JWT token lifecycle (access + refresh).
class AuthService {
  AuthService({
    required this.apiClient,
    required this.storageService,
  });

  final ApiClient apiClient;
  final StorageService storageService;

  // ---- Email/Password Auth (API-only) ----

  /// Register a new account. Returns user data from /auth/register.
  /// Tokens are auto-saved to secure storage.
  Future<AuthResult> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );
    final data = response.data!;
    await _saveTokens(data);
    return AuthResult(
      accessToken: data['access_token'] as String,
      isNewUser: true,
    );
  }

  /// Sign in with email and password via /auth/login.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    await _saveTokens(data);
    return AuthResult(
      accessToken: data['access_token'] as String,
      isNewUser: false,
    );
  }

  /// Sign out — clear all stored tokens.
  Future<void> signOut() async {
    await storageService.clearTokens();
    apiClient.clearAuthToken();
  }

  /// Get current user profile from /auth/me.
  /// Returns null if no valid token exists.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await storageService.getAccessToken();
    if (token == null) return null;

    apiClient.setAuthToken(token);
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/auth/me');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Try refresh
        final refreshed = await refreshToken();
        if (refreshed) {
          final response = await apiClient.get<Map<String, dynamic>>('/auth/me');
          return response.data;
        }
      }
      return null;
    }
  }

  /// Refresh the access token using stored refresh token.
  /// Returns true if refresh succeeded.
  Future<bool> refreshToken() async {
    final refreshTk = await storageService.getRefreshToken();
    if (refreshTk == null) return false;

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshTk},
      );
      final data = response.data!;
      await _saveTokens(data);
      return true;
    } catch (_) {
      // Refresh failed — clear tokens
      await storageService.clearTokens();
      apiClient.clearAuthToken();
      return false;
    }
  }

  /// Send password reset email (stub for Phase 2).
  Future<void> sendPasswordResetEmail(String email) async {
    // TODO(phase2): Implement via backend API
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  // ---- Token Management ----

  Future<void> _saveTokens(Map<String, dynamic> tokenData) async {
    final accessToken = tokenData['access_token'] as String;
    final refreshTk = tokenData['refresh_token'] as String;
    await storageService.saveAccessToken(accessToken);
    await storageService.saveRefreshToken(refreshTk);
    apiClient.setAuthToken(accessToken);
  }

  /// Check if we have a stored token (quick check without API call).
  Future<bool> hasStoredToken() async {
    final token = await storageService.getAccessToken();
    return token != null;
  }
}

/// Result of an authentication operation.
class AuthResult {
  const AuthResult({
    required this.accessToken,
    this.isNewUser = false,
  });

  final String accessToken;
  final bool isNewUser;
}
