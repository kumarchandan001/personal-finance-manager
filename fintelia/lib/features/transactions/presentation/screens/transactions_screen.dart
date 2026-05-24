/// ============================================
/// FINTELIA — Transactions Screen
/// Real data from API with filtering & delete
/// ============================================
library;

import 'package:fintelia/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:fintelia/shared/models/transaction_model.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load transactions on first build
    Future.microtask(() =>
        ref.read(transactionProvider.notifier).loadTransactions());
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    final type = filter == 'All' ? null : filter.toLowerCase();
    ref.read(transactionProvider.notifier).loadTransactions(transactionType: type);
  }

  Future<void> _deleteTransaction(TransactionModel txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${txn.description ?? txn.category}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final success = await ref.read(transactionProvider.notifier).deleteTransaction(txn.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Transaction deleted' : 'Failed to delete')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final theme = Theme.of(context);
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Income', 'Expense'].map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => _applyFilter(f),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: state.isLoading && state.transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.expense),
                            AppSpacing.verticalMd,
                            Text(state.error!, textAlign: TextAlign.center),
                            AppSpacing.verticalMd,
                            OutlinedButton(
                              onPressed: () => ref.read(transactionProvider.notifier).loadTransactions(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : state.transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 64,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                                AppSpacing.verticalMd,
                                Text('No transactions yet',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                                AppSpacing.verticalSm,
                                Text('Tap + to add your first transaction',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(transactionProvider.notifier).loadTransactions(
                              transactionType: _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase(),
                            ),
                            child: ListView.builder(
                              padding: AppSpacing.screenPadding,
                              itemCount: state.transactions.length,
                              itemBuilder: (_, i) {
                                final txn = state.transactions[i];
                                final isIncome = txn.isIncome;
                                final icon = _categoryIcon(txn.category);
                                return Dismissible(
                                  key: Key(txn.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: AppColors.expense.withValues(alpha: 0.1),
                                    child: const Icon(Icons.delete_rounded, color: AppColors.expense),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _deleteTransaction(txn);
                                    return false; // We handle deletion manually
                                  },
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
                                    leading: CircleAvatar(
                                      backgroundColor: (isIncome ? AppColors.income : AppColors.expense).withValues(alpha: 0.1),
                                      child: Icon(icon, color: isIncome ? AppColors.income : AppColors.expense, size: 20),
                                    ),
                                    title: Text(txn.description ?? txn.category,
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      '${txn.category} • ${DateFormat.MMMd().format(txn.transactionDate)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    trailing: Text(
                                      '${isIncome ? '+' : '-'}${currencyFmt.format(txn.amount)}',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: isIncome ? AppColors.income : AppColors.expense,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onTap: () => context.push('/transactions/add', extra: txn),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': case 'dining': case 'groceries': return Icons.restaurant_rounded;
      case 'transport': case 'transportation': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'salary': case 'income': return Icons.account_balance_wallet_rounded;
      case 'bills': case 'utilities': return Icons.receipt_long_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': case 'medical': return Icons.medical_services_rounded;
      default: return Icons.category_rounded;
    }
  }
}
