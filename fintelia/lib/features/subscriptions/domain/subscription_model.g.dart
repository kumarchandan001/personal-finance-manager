// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  billingCycle: json['billing_cycle'] as String,
  nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
  category: json['category'] as String,
  isActive: json['is_active'] as bool? ?? true,
  cancellationUrl: json['cancellation_url'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'amount': instance.amount,
  'billing_cycle': instance.billingCycle,
  'next_billing_date': instance.nextBillingDate.toIso8601String(),
  'category': instance.category,
  'is_active': instance.isActive,
  'cancellation_url': instance.cancellationUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
