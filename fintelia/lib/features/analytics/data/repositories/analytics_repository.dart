/// ============================================
/// FINTELIA — Analytics Repository
/// API data layer for analytics endpoints
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';

class AnalyticsRepository {
  AnalyticsRepository({required this.apiClient});
  final ApiClient apiClient;

  Future<Map<String, dynamic>> getOverview({int days = 30}) async {
    final r = await apiClient.get<Map<String, dynamic>>(
      '/analytics/overview',
      queryParameters: {'days': days},
    );
    return r.data!;
  }

  Future<List<Map<String, dynamic>>> getMonthly({int months = 6}) async {
    final r = await apiClient.get<List<dynamic>>(
      '/analytics/monthly',
      queryParameters: {'months': months},
    );
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getWeekly({int weeks = 8}) async {
    final r = await apiClient.get<List<dynamic>>(
      '/analytics/weekly',
      queryParameters: {'weeks': weeks},
    );
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCategories({int days = 30}) async {
    final r = await apiClient.get<List<dynamic>>(
      '/analytics/categories',
      queryParameters: {'days': days},
    );
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getTrends({int months = 6}) async {
    final r = await apiClient.get<Map<String, dynamic>>(
      '/analytics/trends',
      queryParameters: {'months': months},
    );
    return r.data!;
  }

  Future<List<Map<String, dynamic>>> getCashflow({int days = 30}) async {
    final r = await apiClient.get<List<dynamic>>(
      '/analytics/cashflow',
      queryParameters: {'days': days},
    );
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getInsights() async {
    final r = await apiClient.get<List<dynamic>>('/analytics/insights');
    return (r.data ?? []).cast<Map<String, dynamic>>();
  }
}
