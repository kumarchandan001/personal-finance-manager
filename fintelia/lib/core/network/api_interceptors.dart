/// ============================================
/// FINTELIA — Dio Interceptors
/// Auth token injection, logging, error handling
/// ============================================
library;

import 'package:dio/dio.dart';
import 'package:fintelia/services/storage_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// Interceptor that reads the stored JWT token and attaches it
/// to every outgoing request. Handles 401 by attempting token refresh.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storageService, required this.dio});

  final StorageService storageService;
  final Dio dio;
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for auth endpoints (login, register, refresh)
    final path = options.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Attach stored token
    final token = await storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          // Retry original request with new token
          final newToken = await storageService.getAccessToken();
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(options);
          _isRefreshing = false;
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // Refresh failed
      }
      _isRefreshing = false;
      // Clear tokens — user must re-login
      await storageService.clearTokens();
    }
    handler.next(err);
  }

  Future<bool> _attemptRefresh() async {
    final refreshToken = await storageService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      )).post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await storageService.saveAccessToken(data['access_token'] as String);
      await storageService.saveRefreshToken(data['refresh_token'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Interceptor that logs HTTP requests and responses for debugging.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${options.uri}\n'
      '  Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      '  Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✕ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '  Error: ${err.message}\n'
      '  Response: ${err.response?.data}',
    );
    handler.next(err);
  }
}

/// Interceptor that provides user-friendly error context.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _logger.w('Network timeout: ${err.requestOptions.uri}');
        message = 'Connection timed out. Please check your internet connection and try again.';
        break;
      case DioExceptionType.connectionError:
        _logger.w('Connection error — server may be unreachable');
        message = 'No internet connection. Please connect to a network to use FINTELIA.';
        break;
      case DioExceptionType.badResponse:
        message = err.response?.data?['detail'] ?? 'An unexpected error occurred.';
        break;
      default:
        message = 'Something went wrong. Please try again later.';
        break;
    }
    
    // We can attach the friendly message to the error so the UI can catch it.
    err = err.copyWith(error: message);
    handler.next(err);
  }
}
