/// ============================================
/// FINTELIA — Budget Model
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// Budget domain model.
class BudgetModel extends Equatable {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.amountLimit,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.userId,
    this.spentAmount = 0,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String category;
  final double amountLimit;
  final double spentAmount;
  final String period; // weekly, monthly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime? createdAt;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      category: json['category'] as String,
      amountLimit: (json['amount_limit'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0,
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount_limit': amountLimit,
        'period': period,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

  /// Remaining budget amount.
  double get remaining => amountLimit - spentAmount;

  /// Budget usage as 0.0 to 1.0 ratio.
  double get usageRatio =>
      amountLimit > 0 ? (spentAmount / amountLimit).clamp(0.0, 1.0) : 0.0;

  /// Budget usage as percentage.
  double get usagePercentage => usageRatio * 100;

  /// Whether the budget is overspent.
  bool get isOverBudget => spentAmount > amountLimit;

  /// Whether the budget is in warning zone (>70%).
  bool get isWarning => usagePercentage >= 70 && usagePercentage < 90;

  /// Whether the budget is critical (>90%).
  bool get isCritical => usagePercentage >= 90;

  @override
  List<Object?> get props => [id, category, amountLimit, spentAmount];
}
