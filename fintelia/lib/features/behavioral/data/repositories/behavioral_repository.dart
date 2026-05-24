import 'package:dio/dio.dart';
import 'package:fintelia/core/network/api_client.dart';
import 'package:fintelia/features/behavioral/domain/behavioral_model.dart';

class BehavioralRepository {
  BehavioralRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BehavioralSummary> getBehavioralSummary() async {
    try {
      final response = await _apiClient.get('/behavioral/summary');
      if (response.data == null) {
        return await analyzeBehavioral();
      }
      return BehavioralSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch behavioral summary: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<BehavioralSummary> analyzeBehavioral() async {
    try {
      final response = await _apiClient.post('/behavioral/analyze');
      return BehavioralSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to analyze behavior: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
