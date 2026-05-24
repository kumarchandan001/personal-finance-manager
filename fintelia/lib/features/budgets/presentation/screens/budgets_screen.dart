/// ============================================
/// FINTELIA — Budgets Screen (Phase 2)
/// Real CRUD with progress tracking
/// ============================================
library;

import 'package:fintelia/features/budgets/presentation/providers/budgets_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});
  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(budgetProvider.notifier).loadBudgets());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(budgetProvider);
    final overview = ref.watch(budgetOverviewProvider);
    final progress = ref.watch(budgetProgressProvider);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Budget'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(budgetProvider.notifier).loadBudgets();
          ref.invalidate(budgetOverviewProvider);
          ref.invalidate(budgetProgressProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Overview Card ----
              overview.when(
                data: (data) {
                  final total = (data['total_budget'] as num?)?.toDouble() ?? 0;
                  final spent = (data['total_spent'] as num?)?.toDouble() ?? 0;
                  final util = (data['utilization_percent'] as num?)?.toDouble() ?? 0;
                  final over = (data['over_budget_count'] as num?)?.toInt() ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.balanceCardGradient,
                      borderRadius: AppSpacing.borderRadiusXl,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Budget', style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(height: 4),
                        Text(currFmt.format(total), style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (util / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(
                              util >= 90 ? Colors.redAccent : util >= 70 ? Colors.orangeAccent : Colors.greenAccent),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${currFmt.format(spent)} spent (${util.toStringAsFixed(0)}%)',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                            if (over > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$over over budget', style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalXl,

              // ---- Budget Progress List ----
              Text('Budget Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.verticalMd,

              progress.when(
                data: (items) => items.isEmpty
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 48,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          AppSpacing.verticalMd,
                          Text('No budgets yet', style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        ]),
                      ))
                    : Column(children: items.map((b) => _BudgetProgressCard(budget: b)).toList()),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator())),
                error: (_, __) => const Center(child: Text('Failed to load')),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final categoryCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    const String period = 'monthly';
    final now = DateTime.now();
    final DateTime startDate = DateTime(now.year, now.month, 1);
    final DateTime endDate = DateTime(now.year, now.month + 1, 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Budget', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: categoryCtrl, decoration: const InputDecoration(
                labelText: 'Category', prefixIcon: Icon(Icons.category_rounded), border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Budget Limit (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded),
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (categoryCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  final success = await ref.read(budgetProvider.notifier).createBudget({
                    'category': categoryCtrl.text.trim(),
                    'amount_limit': double.parse(amountCtrl.text.trim()),
                    'period': period,
                    'start_date': startDate.toIso8601String().substring(0, 10),
                    'end_date': endDate.toIso8601String().substring(0, 10),
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (success) {
                      ref.invalidate(budgetOverviewProvider);
                      ref.invalidate(budgetProgressProvider);
                    }
                  }
                },
                child: const Text('Create Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({required this.budget});
  final Map<String, dynamic> budget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final category = budget['category']?.toString() ?? '';
    final limit = (budget['amount_limit'] as num?)?.toDouble() ?? 0;
    final spent = (budget['spent_amount'] as num?)?.toDouble() ?? 0;
    final remaining = (budget['remaining'] as num?)?.toDouble() ?? 0;
    final util = (budget['utilization_percent'] as num?)?.toDouble() ?? 0;
    final status = budget['status']?.toString() ?? 'healthy';
    final daysLeft = (budget['remaining_days'] as num?)?.toInt() ?? 0;
    final isOnTrack = budget['is_on_track'] == true;

    final statusColor = status == 'exceeded' ? AppColors.expense
        : status == 'warning' ? Colors.orange
        : status == 'caution' ? Colors.amber
        : AppColors.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_catIcon(category), color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(category, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (util / 100).clamp(0.0, 1.0),
                backgroundColor: statusColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currFmt.format(spent)} / ${currFmt.format(limit)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Text('$daysLeft days left',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ],
            ),
            if (!isOnTrack && status != 'exceeded')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('Projected to exceed budget', style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange, fontSize: 11)),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  IconData _catIcon(String c) {
    switch (c.toLowerCase()) {
      case 'food': case 'groceries': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'bills': case 'utilities': return Icons.receipt_long_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.medical_services_rounded;
      default: return Icons.category_rounded;
    }
  }
}
