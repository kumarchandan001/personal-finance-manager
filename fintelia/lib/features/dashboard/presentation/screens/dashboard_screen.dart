/// ============================================
/// FINTELIA — Dashboard Screen (Phase 2)
/// Real financial data hub with charts
/// ============================================
library;

import 'package:fintelia/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fintelia/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:fintelia/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:fintelia/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:fintelia/utils/helpers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final overview = ref.watch(dashboardOverviewProvider);
    final categories = ref.watch(dashboardCategoriesProvider);
    final insights = ref.watch(dashboardInsightsProvider);
    final txnState = ref.watch(transactionProvider);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final displayName = authState.displayName ?? 'User';
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Helpers.getGreeting(),
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            Text(displayName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                child: Text(initials,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardOverviewProvider);
          ref.invalidate(dashboardCategoriesProvider);
          ref.invalidate(dashboardInsightsProvider);
          await ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Balance Card (real data) ----
              overview.when(
                data: (data) => _BalanceCardReal(data: data),
                loading: () => const BalanceCard(),
                error: (_, __) => const BalanceCard(),
              ),
              AppSpacing.verticalXl,

              // ---- Quick Actions ----
              const QuickActions(),
              AppSpacing.verticalXl,

              // ---- Insights Cards ----
              insights.when(
                data: (items) => items.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          AppSpacing.verticalSm,
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => _InsightCard(insight: items[i]),
                            ),
                          ),
                          AppSpacing.verticalXl,
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ---- Recent Transactions ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () => context.go('/transactions'), child: const Text('See All')),
                ],
              ),
              AppSpacing.verticalSm,

              if (txnState.isLoading && txnState.transactions.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (txnState.transactions.isEmpty)
                _emptyState(theme, 'No transactions yet', Icons.receipt_long_outlined)
              else
                ...txnState.transactions.take(5).map((txn) {
                  final isIncome = txn.isIncome;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
                      tileColor: theme.cardTheme.color,
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: (isIncome ? AppColors.income : AppColors.expense).withValues(alpha: 0.1),
                          borderRadius: AppSpacing.borderRadiusMd,
                        ),
                        child: Icon(_catIcon(txn.category),
                            color: isIncome ? AppColors.income : AppColors.expense, size: 22),
                      ),
                      title: Text(txn.description ?? txn.category, style: theme.textTheme.titleSmall),
                      subtitle: Text(DateFormat.MMMd().format(txn.transactionDate),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${currFmt.format(txn.amount)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }),

              AppSpacing.verticalXl,

              // ---- Spending Overview (pie chart) ----
              Text('Spending by Category',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.verticalMd,

              categories.when(
                data: (cats) => cats.isNotEmpty
                    ? Container(
                        height: 240,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: AppSpacing.borderRadiusLg,
                          border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: RepaintBoundary(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 36,
                                    sections: cats.take(5).toList().asMap().entries.map((e) {
                                      final c = e.value;
                                      final color = _chartColors[e.key % _chartColors.length];
                                      return PieChartSectionData(
                                        value: (c['percentage'] as num?)?.toDouble() ?? 0,
                                        color: color,
                                        radius: 50,
                                        title: '${(c['percentage'] as num?)?.toStringAsFixed(0) ?? 0}%',
                                        titleStyle: const TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: cats.take(5).toList().asMap().entries.map((e) {
                                final c = e.value;
                                final color = _chartColors[e.key % _chartColors.length];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 10, height: 10,
                                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(c['category']?.toString() ?? '', style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      )
                    : _emptyState(theme, 'No spending data yet', Icons.pie_chart_outline_rounded),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => _emptyState(theme, 'Failed to load chart', Icons.error_outline),
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme, String msg, IconData icon) {
    return Container(
      height: 120, width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          AppSpacing.verticalSm,
          Text(msg, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  IconData _catIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'food': case 'dining': case 'groceries': return Icons.restaurant_rounded;
      case 'transport': case 'transportation': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'salary': case 'income': return Icons.account_balance_wallet_rounded;
      case 'bills': case 'utilities': return Icons.receipt_long_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.medical_services_rounded;
      default: return Icons.category_rounded;
    }
  }

  static const _chartColors = [
    Color(0xFF6C63FF), Color(0xFFFF6B6B), Color(0xFF4ECDC4),
    Color(0xFFFFBE0B), Color(0xFFB388FF), Color(0xFF45B7D1),
  ];
}

// ---- Real Balance Card ----
class _BalanceCardReal extends StatelessWidget {
  const _BalanceCardReal({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final balance = (data['net_savings'] as num?)?.toDouble() ?? 0;
    final income = (data['total_income'] as num?)?.toDouble() ?? 0;
    final expense = (data['total_expense'] as num?)?.toDouble() ?? 0;
    final savingsRate = (data['savings_rate'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.balanceCardGradient,
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance', style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${savingsRate.toStringAsFixed(0)}% saved',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: balance),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            builder: (context, value, _) {
              return Text(currFmt.format(value),
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5));
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Income', style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                        Text(currFmt.format(income), style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.arrow_downward_rounded, color: Colors.redAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expense', style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                        Text(currFmt.format(expense), style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Insight Card ----
class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final Map<String, dynamic> insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = insight['severity']?.toString() ?? 'info';
    final color = severity == 'danger' ? AppColors.expense
        : severity == 'warning' ? Colors.orange
        : severity == 'success' ? AppColors.income
        : AppColors.primary;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(_severityIcon(severity), size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(insight['title']?.toString() ?? '',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(insight['message']?.toString() ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  IconData _severityIcon(String s) {
    switch (s) {
      case 'danger': return Icons.warning_amber_rounded;
      case 'warning': return Icons.info_outline_rounded;
      case 'success': return Icons.check_circle_outline_rounded;
      default: return Icons.lightbulb_outline_rounded;
    }
  }
}
