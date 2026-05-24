import 'package:fintelia/features/subscriptions/presentation/providers/subscription_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subsState = ref.watch(subscriptionProvider);
    final currFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: Navigate to add subscription
            },
          ),
        ],
      ),
      body: subsState.when(
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
              child: Text(
                'No subscriptions found.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(subscriptionProvider.notifier).loadSubscriptions(),
            child: ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: subs.length,
              separatorBuilder: (_, __) => AppSpacing.verticalMd,
              itemBuilder: (context, index) {
                final sub = subs[index];
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: AppSpacing.borderRadiusLg,
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                      child: const Icon(Icons.subscriptions_rounded, color: AppColors.primary),
                    ),
                    title: Text(sub.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Next: ${DateFormat.yMMMd().format(sub.nextBillingDate)}'),
                        Text(sub.billingCycle.toUpperCase(), style: theme.textTheme.labelSmall),
                      ],
                    ),
                    trailing: Text(
                      currFmt.format(sub.amount),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.expense),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.expense),
              AppSpacing.verticalMd,
              Text('Failed to load subscriptions', style: theme.textTheme.titleMedium),
              Text(err.toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              AppSpacing.verticalLg,
              ElevatedButton(
                onPressed: () => ref.read(subscriptionProvider.notifier).loadSubscriptions(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
