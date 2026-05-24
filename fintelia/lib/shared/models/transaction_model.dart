/// ============================================
/// FINTELIA — Transaction Model
/// ============================================
library;

import 'package:equatable/equatable.dart';

/// Transaction type.
enum TransactionType { income, expense }

/// Transaction domain model.
class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.transactionType,
    required this.transactionDate,
    this.userId,
    this.currency = 'INR',
    this.subcategory,
    this.description,
    this.paymentMethod,
    this.merchant,
    this.receiptUrl,
    this.emotionalTag,
    this.isRecurring = false,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final double amount;
  final String currency;
  final String category;
  final String? subcategory;
  final String? description;
  final TransactionType transactionType;
  final String? paymentMethod;
  final String? merchant;
  final String? receiptUrl;
  final String? emotionalTag;
  final bool isRecurring;
  final DateTime transactionDate;
  final DateTime? createdAt;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      amount: json['amount'] is String
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String?,
      transactionType: json['transaction_type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      paymentMethod: json['payment_method'] as String?,
      merchant: json['merchant'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      emotionalTag: json['emotional_tag'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'category': category,
        'subcategory': subcategory,
        'description': description,
        'transaction_type':
            transactionType == TransactionType.income ? 'income' : 'expense',
        'payment_method': paymentMethod,
        'merchant': merchant,
        'emotional_tag': emotionalTag,
        'is_recurring': isRecurring,
        'transaction_date': transactionDate.toIso8601String(),
      };

  /// Whether this is an income transaction.
  bool get isIncome => transactionType == TransactionType.income;

  /// Whether this is an expense transaction.
  bool get isExpense => transactionType == TransactionType.expense;

  /// Signed amount (negative for expenses).
  double get signedAmount => isExpense ? -amount : amount;

  @override
  List<Object?> get props => [id, amount, category, transactionType, transactionDate];
}
