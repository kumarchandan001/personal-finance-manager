/// ============================================
/// FINTELIA — Base API Service
/// Generic CRUD operations for API resources
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';

/// Base API service providing generic CRUD operations.
///
/// Feature-specific services extend or compose this to interact
/// with backend endpoints in a consistent manner.
class ApiService {
  ApiService(this._client);

  final ApiClient _client;

  /// GET a list of resources.
  Future<List<Map<String, dynamic>>> getList(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data != null && data['items'] is List) {
      return List<Map<String, dynamic>>.from(
        data['items'] as List<dynamic>,
      );
    }
    return [];
  }

  /// GET a single resource by ID.
  Future<Map<String, dynamic>?> getById(String endpoint, String id) async {
    final response = await _client.get<Map<String, dynamic>>('$endpoint/$id');
    return response.data;
  }

  /// POST to create a new resource.
  Future<Map<String, dynamic>?> create(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      endpoint,
      data: data,
    );
    return response.data;
  }

  /// PUT to update an existing resource.
  Future<Map<String, dynamic>?> update(
    String endpoint,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put<Map<String, dynamic>>(
      '$endpoint/$id',
      data: data,
    );
    return response.data;
  }

  /// DELETE a resource by ID.
  Future<void> deleteResource(String endpoint, String id) async {
    await _client.delete<void>('$endpoint/$id');
  }
}
