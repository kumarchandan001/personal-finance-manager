/// ============================================
/// FINTELIA — Goal Repository
/// API data layer for goals
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';

class GoalRepository {
  GoalRepository({required this.apiClient});
  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> list() async {
    final r = await apiClient.get<List<dynamic>>('/goals/');
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listWithDetails() async {
    final r = await apiClient.get<List<dynamic>>('/goals/details');
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final r = await apiClient.post<Map<String, dynamic>>('/goals/', data: data);
    return r.data!;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final r = await apiClient.put<Map<String, dynamic>>('/goals/$id', data: data);
    return r.data!;
  }

  Future<Map<String, dynamic>> updateProgress(String id, double amount) async {
    final r = await apiClient.patch<Map<String, dynamic>>(
      '/goals/$id/progress',
      data: {'amount': amount},
    );
    return r.data!;
  }

  Future<void> delete(String id) async {
    await apiClient.delete('/goals/$id');
  }
}
