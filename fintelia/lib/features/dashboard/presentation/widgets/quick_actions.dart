/// ============================================
/// FINTELIA — Quick Actions Widget
/// ============================================
library;

import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Grid of quick action buttons on the dashboard.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.verticalMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionItem(
              icon: Icons.add_rounded,
              label: 'Add',
              color: AppColors.primary,
              onTap: () => context.push('/transactions/add'),
            ),
            _ActionItem(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              color: AppColors.secondary,
              onTap: () {},
            ),
            _ActionItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Budget',
              color: AppColors.accent,
              onTap: () => context.go('/budgets'),
            ),
            _ActionItem(
              icon: Icons.analytics_rounded,
              label: 'Analytics',
              color: AppColors.info,
              onTap: () => context.go('/analytics'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            AppSpacing.verticalSm,
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
