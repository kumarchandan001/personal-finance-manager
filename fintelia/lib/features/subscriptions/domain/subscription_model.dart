import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required double amount,
    @JsonKey(name: 'billing_cycle') required String billingCycle, // monthly, yearly, weekly
    @JsonKey(name: 'next_billing_date') required DateTime nextBillingDate,
    required String category,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'cancellation_url') String? cancellationUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
