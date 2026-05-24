import 'package:freezed_annotation/freezed_annotation.dart';

part 'behavioral_model.freezed.dart';
part 'behavioral_model.g.dart';

@freezed
class BehavioralSummary with _$BehavioralSummary {
  const factory BehavioralSummary({
    required double emotionalSpendingScore,
    required double impulseScore,
    required double financialHealthScore,
    required Map<String, dynamic> behavioralArchetype,
    required List<String> recommendations,
    required DateTime lastUpdated,
  }) = _BehavioralSummary;

  factory BehavioralSummary.fromJson(Map<String, dynamic> json) {
    return BehavioralSummary(
      emotionalSpendingScore: (json['emotional_spending_score'] as num?)?.toDouble() ?? 0.0,
      impulseScore: (json['impulse_score'] as num?)?.toDouble() ?? 0.0,
      financialHealthScore: (json['financial_health_score'] as num?)?.toDouble() ?? 0.0,
      behavioralArchetype: json['behavioral_archetype'] as Map<String, dynamic>? ?? {'name': 'Analyzer', 'description': 'Careful spender.'},
      recommendations: (json['recommendations']?['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastUpdated: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }
}
