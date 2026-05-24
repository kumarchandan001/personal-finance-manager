// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavioral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BehavioralSummaryImpl _$$BehavioralSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$BehavioralSummaryImpl(
  emotionalSpendingScore: (json['emotionalSpendingScore'] as num).toDouble(),
  impulseScore: (json['impulseScore'] as num).toDouble(),
  financialHealthScore: (json['financialHealthScore'] as num).toDouble(),
  behavioralArchetype: json['behavioralArchetype'] as Map<String, dynamic>,
  recommendations:
      (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$$BehavioralSummaryImplToJson(
  _$BehavioralSummaryImpl instance,
) => <String, dynamic>{
  'emotionalSpendingScore': instance.emotionalSpendingScore,
  'impulseScore': instance.impulseScore,
  'financialHealthScore': instance.financialHealthScore,
  'behavioralArchetype': instance.behavioralArchetype,
  'recommendations': instance.recommendations,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
