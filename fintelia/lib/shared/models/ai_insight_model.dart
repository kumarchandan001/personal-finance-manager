/// ============================================
/// FINTELIA — AI Insight Model
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// AI-generated insight model.
class AiInsightModel extends Equatable {
  const AiInsightModel({
    required this.id,
    required this.insightType,
    required this.title,
    required this.description,
    this.userId,
    this.confidenceScore,
    this.data,
    this.isRead = false,
    this.isActionable = true,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String insightType;
  final String title;
  final String description;
  final double? confidenceScore;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isActionable;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      insightType: json['insight_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      isActionable: json['is_actionable'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Whether the insight has expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Confidence as a human-readable label.
  String get confidenceLabel {
    if (confidenceScore == null) return 'Unknown';
    if (confidenceScore! >= 0.8) return 'High';
    if (confidenceScore! >= 0.5) return 'Medium';
    return 'Low';
  }

  @override
  List<Object?> get props => [id, insightType, title];
}
