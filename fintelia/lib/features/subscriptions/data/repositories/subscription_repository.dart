import 'package:dio/dio.dart';
import 'package:fintelia/core/network/api_client.dart';
import 'package:fintelia/features/subscriptions/domain/subscription_model.dart';

class SubscriptionRepository {
  SubscriptionRepository({required this.apiClient});

  final ApiClient apiClient;
  final String _basePath = '/subscriptions';

  Future<List<SubscriptionModel>> getSubscriptions() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(_basePath);
      final List<dynamic> data = response.data?['data'] ?? [];
      return data
          .map((json) => SubscriptionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch subscriptions: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<SubscriptionModel> createSubscription(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        _basePath,
        data: data,
      );
      return SubscriptionModel.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create subscription: ${e.message}');
    }
  }

  Future<SubscriptionModel> updateSubscription(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '$_basePath/$id',
        data: data,
      );
      return SubscriptionModel.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update subscription: ${e.message}');
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await apiClient.delete<Map<String, dynamic>>('$_basePath/$id');
    } on DioException catch (e) {
      throw Exception('Failed to delete subscription: ${e.message}');
    }
  }
}
