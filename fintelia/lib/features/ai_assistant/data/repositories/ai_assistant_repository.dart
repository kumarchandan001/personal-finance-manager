/// ============================================
/// FINTELIA — AI Assistant Repository
/// API data layer for AI assistant features
/// ============================================
library;

import 'package:fintelia/core/network/api_client.dart';

/// Repository that maps AI assistant API calls to response maps.
class AiAssistantRepository {
  AiAssistantRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Send a chat message and receive AI response.
  /// Returns: {"response": str, "suggestions": [str]}
  Future<Map<String, dynamic>> chat(String message) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/ai/chat',
      data: {'message': message},
    );
    return response.data!;
  }

  /// Request deep spending analysis.
  /// Returns: {"analysis": str, "suggestions": [str]}
  Future<Map<String, dynamic>> analyzeSpending() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/ai/analyze-spending',
    );
    return response.data!;
  }

  /// Get AI-generated monthly financial summary.
  /// Returns: {"summary": str, "suggestions": [str]}
  Future<Map<String, dynamic>> getSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/ai/summary',
    );
    return response.data!;
  }

  /// Get structured AI financial recommendations.
  /// Returns: list of recommendation objects.
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    final response = await apiClient.get<List<dynamic>>(
      '/ai/recommendations',
    );
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// AI-powered transaction categorization.
  /// Returns: {"category": str, "subcategory": str?, ...}
  Future<Map<String, dynamic>> categorizeTransaction({
    required String description,
    String merchant = '',
    double amount = 0,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/ai/categorize',
      data: {
        'description': description,
        'merchant': merchant,
        'amount': amount,
      },
    );
    return response.data!;
  }
}
