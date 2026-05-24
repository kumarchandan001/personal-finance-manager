/// ============================================
/// FINTELIA — Goals Screen (Phase 2)
/// Real CRUD with progress tracking
/// ============================================
library;

import 'package:fintelia/features/goals/presentation/providers/goals_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});
  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(goalProvider.notifier).loadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(goalProvider.notifier).loadGoals(),
        child: state.isLoading && state.goals.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_outlined, size: 64,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                        AppSpacing.verticalMd,
                        Text('No goals yet', style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        AppSpacing.verticalSm,
                        Text('Tap + to set your first savings goal',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: AppSpacing.screenPadding,
                    itemCount: state.goals.length + 1,
                    itemBuilder: (_, i) {
                      if (i == state.goals.length) return const SizedBox(height: 80);
                      return _GoalCard(
                        goal: state.goals[i],
                        onAddProgress: () => _showProgressDialog(context, state.goals[i]),
                        onDelete: () => _deleteGoal(state.goals[i]),
                      );
                    },
                  ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? deadline;
    const String priority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Goal', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, decoration: const InputDecoration(
                  labelText: 'Goal Title', prefixIcon: Icon(Icons.flag_rounded), border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Target Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded),
                      border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: descCtrl, decoration: const InputDecoration(
                  labelText: 'Description (optional)', prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder())),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                  side: BorderSide(color: Theme.of(ctx).colorScheme.outline),
                ),
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(deadline != null ? DateFormat.yMMMd().format(deadline!) : 'Set Deadline (optional)'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setModalState(() => deadline = picked);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                    final data = <String, dynamic>{
                      'title': titleCtrl.text.trim(),
                      'target_amount': double.parse(amountCtrl.text.trim()),
                      'priority': priority,
                    };
                    if (descCtrl.text.isNotEmpty) data['description'] = descCtrl.text.trim();
                    if (deadline != null) data['deadline'] = deadline!.toIso8601String().substring(0, 10);

                    final success = await ref.read(goalProvider.notifier).createGoal(data);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Create Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, Map<String, dynamic> goal) {
    final amountCtrl = TextEditingController();
    final title = goal['title']?.toString() ?? 'Goal';
    final id = goal['id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "$title"'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded), border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (amountCtrl.text.isEmpty) return;
              await ref.read(goalProvider.notifier).addProgress(id, double.parse(amountCtrl.text.trim()));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(Map<String, dynamic> goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(goalProvider.notifier).deleteGoal(goal['id']?.toString() ?? '');
    }
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onAddProgress, required this.onDelete});
  final Map<String, dynamic> goal;
  final VoidCallback onAddProgress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final title = goal['title']?.toString() ?? '';
    final target = (goal['target_amount'] as num?)?.toDouble() ?? 0;
    final current = (goal['current_amount'] as num?)?.toDouble() ?? 0;
    final remaining = (goal['remaining'] as num?)?.toDouble() ?? 0;
    final pct = (goal['completion_percent'] as num?)?.toDouble() ?? 0;
    final monthlyReq = goal['monthly_required'] as num?;
    final projected = goal['projected_completion']?.toString();
    final status = goal['status']?.toString() ?? 'active';
    final deadline = goal['deadline']?.toString();
    final isCompleted = status == 'completed';

    final color = isCompleted ? AppColors.income
        : pct >= 75 ? const Color(0xFF4ECDC4)
        : pct >= 40 ? AppColors.primary
        : const Color(0xFFFFBE0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                          color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (deadline != null)
                            Text('Due: ${DateFormat.yMMMd().format(DateTime.parse(deadline))}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                        ],
                      ),
                    ),
                  ]),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'add', child: Text('Add Progress')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (v) {
                    if (v == 'add') onAddProgress();
                    if (v == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),

            // Amount details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currFmt.format(current)} / ${currFmt.format(target)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${pct.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
                ),
              ],
            ),

            if (!isCompleted && (monthlyReq != null || projected != null)) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (monthlyReq != null)
                    Expanded(child: _InfoChip(
                      icon: Icons.calendar_month_rounded,
                      label: '${currFmt.format(monthlyReq)}/mo needed',
                      theme: theme,
                    )),
                  if (projected != null)
                    Expanded(child: _InfoChip(
                      icon: Icons.timeline_rounded,
                      label: 'Est. ${DateFormat.yMMM().format(DateTime.parse(projected))}',
                      theme: theme,
                    )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.theme});
  final IconData icon;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
