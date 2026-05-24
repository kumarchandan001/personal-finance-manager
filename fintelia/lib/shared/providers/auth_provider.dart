/// ============================================
/// FINTELIA — Auth Provider
/// Authentication state management with real API
/// ============================================
library;

import 'package:dio/dio.dart';
import 'package:fintelia/core/network/api_client.dart';
import 'package:fintelia/services/auth_service.dart';
import 'package:fintelia/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Dependency Providers
// ---------------------------------------------------------------------------

/// Secure storage provider (singleton).
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// API client provider (singleton).
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Auth service provider, depends on apiClient + storageService.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    apiClient: ref.read(apiClientProvider),
    storageService: ref.read(storageServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------

/// Authentication status enum.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Authentication state holding user info and status.
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// ---------------------------------------------------------------------------
// Auth Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState());

  final AuthService _authService;

  /// Sign in with email and password via API.
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signInWithEmail(email, password);
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user?['id']?.toString(),
        email: user?['email']?.toString() ?? email,
        displayName: user?['full_name']?.toString(),
      );
    } on DioException catch (e) {
      final detail = _extractError(e);
      state = state.copyWith(status: AuthStatus.error, errorMessage: detail);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// Sign up with email, password, and full name.
  Future<void> signUp(String email, String password, String fullName) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signUpWithEmail(email, password, fullName);
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user?['id']?.toString(),
        email: user?['email']?.toString() ?? email,
        displayName: user?['full_name']?.toString() ?? fullName,
      );
    } on DioException catch (e) {
      final detail = _extractError(e);
      state = state.copyWith(status: AuthStatus.error, errorMessage: detail);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Check existing authentication state on app start.
  Future<void> checkAuthState() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasToken = await _authService.hasStoredToken();
      if (!hasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user['id']?.toString(),
          email: user['email']?.toString(),
          displayName: user['full_name']?.toString(),
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Extract user-friendly error from DioException.
  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['detail']?.toString() ?? 'An error occurred';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot connect to server. Check your connection.';
    }
    return 'An unexpected error occurred';
  }
}

/// Global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
