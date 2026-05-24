/// ============================================
/// FINTELIA — Add/Edit Transaction Screen
/// Real API create/update with validation
/// ============================================
library;

import 'package:fintelia/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:fintelia/shared/models/transaction_model.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:fintelia/widgets/app_button.dart';
import 'package:fintelia/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});
  final TransactionModel? transaction;

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();

  String _type = 'expense';
  String _category = 'Food';
  DateTime _date = DateTime.now();
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  static const _categories = [
    'Food', 'Transport', 'Shopping', 'Bills', 'Entertainment',
    'Health', 'Salary', 'Freelance', 'Investment', 'Other',
  ];

  static const _paymentMethods = ['cash', 'card', 'bank_transfer', 'upi', 'other'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toStringAsFixed(2);
      _descriptionController.text = t.description ?? '';
      _merchantController.text = t.merchant ?? '';
      _type = t.transactionType.name;
      _category = t.category;
      _date = t.transactionDate;
      _paymentMethod = t.paymentMethod ?? 'cash';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'amount': double.parse(_amountController.text.trim()),
      'category': _category,
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'transaction_type': _type,
      'payment_method': _paymentMethod,
      'merchant': _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      'transaction_date': _date.toUtc().toIso8601String(),
      'is_recurring': false,
    };

    bool success;
    if (_isEditing) {
      success = await ref.read(transactionProvider.notifier)
          .updateTransaction(widget.transaction!.id, data);
    } else {
      success = await ref.read(transactionProvider.notifier)
          .createTransaction(data);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Transaction updated' : 'Transaction created')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save transaction'), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type toggle
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(Icons.arrow_downward_rounded)),
                  ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(Icons.arrow_upward_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _type == 'income'
                          ? AppColors.income.withValues(alpha: 0.15)
                          : AppColors.expense.withValues(alpha: 0.15);
                    }
                    return null;
                  }),
                ),
              ),
              AppSpacing.verticalXl,

              // Amount
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              AppSpacing.verticalLg,

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
              AppSpacing.verticalLg,

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'What was this for?',
                prefixIcon: Icons.description_outlined,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalLg,

              // Merchant
              AppTextField(
                controller: _merchantController,
                label: 'Merchant (optional)',
                hint: 'Store or payee name',
                prefixIcon: Icons.store_rounded,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalLg,

              // Payment method
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: const Icon(Icons.payment_rounded),
                  border: OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
                ),
                items: _paymentMethods.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.replaceAll('_', ' ').toUpperCase()),
                )).toList(),
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
              ),
              AppSpacing.verticalLg,

              // Date
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                onTap: _pickDate,
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              const SizedBox(height: 32),

              // Save button
              AppButton(
                label: _isEditing ? 'Update Transaction' : 'Save Transaction',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }
}
