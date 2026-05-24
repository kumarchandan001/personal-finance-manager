/// ============================================
/// FINTELIA — Goal Model
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// Financial goal domain model.
class GoalModel extends Equatable {
  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.userId,
    this.description,
    this.currentAmount = 0,
    this.deadline,
    this.priority = 'medium',
    this.status = 'active',
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String priority;
  final String status;
  final DateTime? createdAt;

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'target_amount': targetAmount,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
      };

  /// Progress as 0.0 to 1.0 ratio.
  double get progressRatio =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Progress as percentage.
  double get progressPercentage => progressRatio * 100;

  /// Remaining amount to reach the goal.
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  /// Whether the goal is completed.
  bool get isCompleted => currentAmount >= targetAmount;

  /// Days remaining until deadline, or null.
  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [id, title, targetAmount, currentAmount];
}
