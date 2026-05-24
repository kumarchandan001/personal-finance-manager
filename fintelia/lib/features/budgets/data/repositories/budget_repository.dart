/// ============================================
/// FINTELIA — Budget Repository
/// API data layer for budgets
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';

class BudgetRepository {
  BudgetRepository({required this.apiClient});
  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> list() async {
    final r = await apiClient.get<List<dynamic>>('/budgets/');
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final r = await apiClient.post<Map<String, dynamic>>('/budgets/', data: data);
    return r.data!;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final r = await apiClient.put<Map<String, dynamic>>('/budgets/$id', data: data);
    return r.data!;
  }

  Future<void> delete(String id) async {
    await apiClient.delete('/budgets/$id');
  }

  Future<Map<String, dynamic>> getOverview() async {
    final r = await apiClient.get<Map<String, dynamic>>('/budgets/overview');
    return r.data!;
  }

  Future<List<Map<String, dynamic>>> getProgress() async {
    final r = await apiClient.get<List<dynamic>>('/budgets/progress');
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }
}
