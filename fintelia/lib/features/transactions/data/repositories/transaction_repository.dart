/// ============================================
/// FINTELIA — Transaction Repository
/// API data layer for transaction CRUD
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';
import 'package:fintelia/shared/models/transaction_model.dart';

/// Repository that maps API calls to [TransactionModel] objects.
class TransactionRepository {
  TransactionRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Create a new transaction.
  Future<TransactionModel> create(Map<String, dynamic> data) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/transactions/',
      data: data,
    );
    return TransactionModel.fromJson(response.data!);
  }

  /// Fetch paginated transaction list with optional filters.
  Future<List<TransactionModel>> list({
    int limit = 20,
    int offset = 0,
    String? category,
    String? transactionType,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (category != null) queryParams['category'] = category;
    if (transactionType != null) queryParams['transaction_type'] = transactionType;

    final response = await apiClient.get<List<dynamic>>(
      '/transactions/',
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single transaction by ID.
  Future<TransactionModel> getById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/transactions/$id',
    );
    return TransactionModel.fromJson(response.data!);
  }

  /// Update a transaction.
  Future<TransactionModel> update(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/transactions/$id',
      data: data,
    );
    return TransactionModel.fromJson(response.data!);
  }

  /// Delete a transaction.
  Future<void> delete(String id) async {
    await apiClient.delete('/transactions/$id');
  }

  /// Get income/expense summary.
  Future<Map<String, dynamic>> getSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/transactions/summary',
    );
    return response.data!;
  }

  /// Get distinct categories.
  Future<List<String>> getCategories() async {
    final response = await apiClient.get<List<dynamic>>(
      '/transactions/categories',
    );
    return (response.data ?? []).map((e) => e.toString()).toList();
  }
}
