/// ============================================
/// FINTELIA — Analytics Screen (Phase 2 Polish)
/// Premium modern fintech analytics UI
/// ============================================
library;

import 'package:fintelia/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      final periods = [AnalyticsPeriod.weekly, AnalyticsPeriod.monthly, AnalyticsPeriod.yearly];
      ref.read(analyticsPeriodProvider.notifier).state = periods[_tabController.index];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overview = ref.watch(analyticsOverviewProvider(30));
    final categories = ref.watch(analyticsCategoriesProvider(30));
    final monthly = ref.watch(analyticsMonthlyProvider(6));
    final trends = ref.watch(analyticsTrendsProvider(6));

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly'), Tab(text: 'Yearly')],
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: theme.textTheme.titleSmall,
          dividerColor: Colors.transparent,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsOverviewProvider(30));
          ref.invalidate(analyticsCategoriesProvider(30));
          ref.invalidate(analyticsMonthlyProvider(6));
          ref.invalidate(analyticsTrendsProvider(6));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Summary Cards ----
              overview.when(
                data: (data) => _SummaryCards(data: data),
                loading: () => _buildSkeletonRow(theme),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              AppSpacing.verticalLg,

              // ---- Spending Trends (Bar Chart) ----
              Text('Spending Trends', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.verticalSm,
              monthly.when(
                data: (data) => data.isNotEmpty
                    ? _SpendingBarChart(data: data)
                    : _emptyChart(theme, 'Add more transactions to view monthly trends.', Icons.bar_chart_rounded),
                loading: () => _buildSkeleton(theme, height: 200),
                error: (_, __) => _emptyChart(theme, 'Failed to load trends.', Icons.error_outline_rounded),
              ),
              AppSpacing.verticalLg,

              // ---- Category Breakdown (Pie + List) ----
              Text('Category Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.verticalSm,
              categories.when(
                data: (cats) => cats.isNotEmpty
                    ? _CategoryBreakdown(categories: cats)
                    : _emptyChart(theme, 'Add transactions to see category breakdown.', Icons.pie_chart_rounded),
                loading: () => _buildSkeleton(theme, height: 260),
                error: (_, __) => _emptyChart(theme, 'Failed to load categories.', Icons.error_outline_rounded),
              ),
              AppSpacing.verticalLg,

              // ---- Trend Indicators ----
              trends.when(
                data: (data) => _TrendIndicators(data: data),
                loading: () => _buildSkeletonRow(theme, height: 80),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.verticalLg,

              // ---- Income vs Expense Line Chart ----
              Text('Income vs Expense', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              AppSpacing.verticalSm,
              monthly.when(
                data: (data) => data.length >= 2
                    ? _IncomeExpenseLineChart(data: data)
                    : _emptyChart(theme, 'Add more data to unlock income vs expense trends.', Icons.insights_rounded),
                loading: () => _buildSkeleton(theme, height: 220),
                error: (_, __) => _emptyChart(theme, 'Failed to load.', Icons.error_outline_rounded),
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyChart(ThemeData theme, String msg, IconData icon) {
    return Container(
      height: 160, width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(msg, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme, {required double height}) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
      child: Container(
        height: height, width: double.infinity,
        decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: AppSpacing.borderRadiusLg),
      ),
    );
  }

  Widget _buildSkeletonRow(ThemeData theme, {double height = 90}) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(child: Container(height: height, decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: AppSpacing.borderRadiusMd))),
          const SizedBox(width: 12),
          Expanded(child: Container(height: height, decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: AppSpacing.borderRadiusMd))),
          const SizedBox(width: 12),
          Expanded(child: Container(height: height, decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: AppSpacing.borderRadiusMd))),
        ],
      ),
    );
  }
}

// ---- Summary Cards Row ----
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final income = (data['total_income'] as num?)?.toDouble() ?? 0;
    final expense = (data['total_expense'] as num?)?.toDouble() ?? 0;
    final savingsRate = (data['savings_rate'] as num?)?.toDouble() ?? 0;

    return Row(
      children: [
        Expanded(child: _StatCard(theme: theme, label: 'Income', value: currFmt.format(income), icon: Icons.arrow_upward_rounded, color: AppColors.income)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(theme: theme, label: 'Expense', value: currFmt.format(expense), icon: Icons.arrow_downward_rounded, color: AppColors.expense)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(theme: theme, label: 'Savings', value: '${savingsRate.toStringAsFixed(0)}%', icon: Icons.savings_rounded, color: AppColors.primary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.theme, required this.label, required this.value, required this.icon, required this.color});
  final ThemeData theme;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11)),
        ],
      ),
    );
  }
}

// ---- Spending Bar Chart ----
class _SpendingBarChart extends StatelessWidget {
  const _SpendingBarChart({required this.data});
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.fold<double>(0, (m, d) {
      final inc = (d['income'] as num?)?.toDouble() ?? 0;
      final exp = (d['expense'] as num?)?.toDouble() ?? 0;
      return [m, inc, exp].reduce((a, b) => a > b ? a : b);
    });

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(4, 20, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surface,
              getTooltipItem: (group, gi, rod, ri) {
                final val = NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0).format(rod.toY);
                return BarTooltipItem(val, TextStyle(color: rod.color, fontWeight: FontWeight.w700, fontSize: 12));
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i >= 0 && i < data.length) {
                    final m = data[i]['month']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(m.length >= 7 ? m.substring(5) : m, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (val, _) => Text(
                  NumberFormat.compact().format(val),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.dividerTheme.color?.withValues(alpha: 0.3) ?? Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (d['income'] as num?)?.toDouble() ?? 0,
                color: AppColors.income,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: (d['expense'] as num?)?.toDouble() ?? 0,
                color: AppColors.expense,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }).toList(),
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}

// ---- Category Breakdown (Pie + Progress List) ----
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.categories});
  final List<Map<String, dynamic>> categories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Pie chart optimized size
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: categories.take(6).toList().asMap().entries.map((e) {
                  final c = e.value;
                  final color = AppColors.chartPalette[e.key % AppColors.chartPalette.length];
                  return PieChartSectionData(
                    value: (c['percentage'] as num?)?.toDouble() ?? 0,
                    color: color,
                    radius: 30,
                    title: '${(c['percentage'] as num?)?.toStringAsFixed(0) ?? 0}%',
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCirc,
            ),
          ),
          const SizedBox(height: 24),
          // Category list with premium progress bars
          ...categories.take(6).toList().asMap().entries.map((e) {
            final c = e.value;
            final color = AppColors.chartPalette[e.key % AppColors.chartPalette.length];
            final pct = (c['percentage'] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['category']?.toString() ?? '', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(currFmt.format((c['amount'] as num?)?.toDouble() ?? 0),
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: pct / 100),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => LinearProgressIndicator(
                              value: value,
                              backgroundColor: theme.brightness == Brightness.dark 
                                  ? Colors.white.withValues(alpha: 0.05) 
                                  : Colors.black.withValues(alpha: 0.05),
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---- Trend Indicators ----
class _TrendIndicators extends StatelessWidget {
  const _TrendIndicators({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expTrend = (data['expense_trend'] as num?)?.toDouble() ?? 0;
    final incTrend = (data['income_trend'] as num?)?.toDouble() ?? 0;

    return Row(
      children: [
        Expanded(child: _TrendTile(theme: theme, label: 'Expense trend', value: '${expTrend >= 0 ? '+' : ''}${expTrend.toStringAsFixed(1)}%', isUp: expTrend >= 0, isGood: expTrend < 0)),
        const SizedBox(width: 12),
        Expanded(child: _TrendTile(theme: theme, label: 'Income trend', value: '${incTrend >= 0 ? '+' : ''}${incTrend.toStringAsFixed(1)}%', isUp: incTrend >= 0, isGood: incTrend >= 0)),
      ],
    );
  }
}

class _TrendTile extends StatelessWidget {
  const _TrendTile({required this.theme, required this.label, required this.value, required this.isUp, required this.isGood});
  final ThemeData theme;
  final String label;
  final String value;
  final bool isUp;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    final color = isGood ? AppColors.income : AppColors.expense;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Income vs Expense Line Chart ----
class _IncomeExpenseLineChart extends StatelessWidget {
  const _IncomeExpenseLineChart({required this.data});
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = data.fold<double>(0, (m, d) {
      final inc = (d['income'] as num?)?.toDouble() ?? 0;
      final exp = (d['expense'] as num?)?.toDouble() ?? 0;
      return [m, inc, exp].reduce((a, b) => a > b ? a : b);
    });

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(4, 20, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: LineChart(
        LineChartData(
          maxY: maxVal * 1.15,
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surface,
              getTooltipItems: (spots) => spots.map((s) {
                final color = s.barIndex == 0 ? AppColors.income : AppColors.expense;
                final val = NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0).format(s.y);
                return LineTooltipItem(val, TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12));
              }).toList(),
            ),
          ),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.dividerTheme.color?.withValues(alpha: 0.3) ?? Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  final i = val.toInt();
                  if (i >= 0 && i < data.length) {
                    final m = data[i]['month']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(m.length >= 7 ? m.substring(5) : m, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, reservedSize: 46,
                getTitlesWidget: (val, _) => Text(
                  NumberFormat.compact().format(val),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['income'] as num?)?.toDouble() ?? 0)).toList(),
              color: AppColors.income,
              barWidth: 3,
              isCurved: true,
              preventCurveOverShooting: true,
              dotData: FlDotData(show: data.length <= 8),
              belowBarData: BarAreaData(show: true, color: AppColors.income.withValues(alpha: 0.08)),
            ),
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['expense'] as num?)?.toDouble() ?? 0)).toList(),
              color: AppColors.expense,
              barWidth: 3,
              isCurved: true,
              preventCurveOverShooting: true,
              dotData: FlDotData(show: data.length <= 8),
              belowBarData: BarAreaData(show: true, color: AppColors.expense.withValues(alpha: 0.08)),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}
