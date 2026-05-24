/// ============================================
/// FINTELIA — API Client
/// Dio-based HTTP client with auth interceptors
/// ============================================
library;

import 'package:dio/dio.dart';
import 'package:fintelia/config/env_config.dart';
import 'package:fintelia/core/constants/app_constants.dart';
import 'package:fintelia/core/network/api_interceptors.dart';
import 'package:fintelia/services/storage_service.dart';

/// Centralized HTTP client built on [Dio].
///
/// Provides configured timeouts, interceptors for auth/logging/error
/// handling, and convenience methods for common HTTP operations.
class ApiClient {
  ApiClient({String? baseUrl, StorageService? storageService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? EnvConfig.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.apiTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.apiReceiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final storage = storageService ?? StorageService();

    _dio.interceptors.addAll([
      AuthInterceptor(storageService: storage, dio: _dio),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  late final Dio _dio;

  /// Access the raw [Dio] instance for advanced use cases.
  Dio get dio => _dio;

  /// Set the authorization bearer token.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove the authorization token.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Perform a GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
