/// FINTELIA — Profile Screen
library;
import 'package:fintelia/features/behavioral/presentation/providers/behavioral_provider.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
      ]),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(children: [
          AppSpacing.verticalLg,
          // Avatar
          CircleAvatar(
            radius: 48, backgroundColor: AppColors.primaryContainer,
            child: Text('DU', style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          AppSpacing.verticalMd,
          Text('Demo User', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.verticalXs,
          Text('demo@fintelia.com', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          AppSpacing.verticalXl,

          // Financial DNA card
          ref.watch(behavioralSummaryProvider).when(
            data: (summary) => Container(
              width: double.infinity, padding: AppSpacing.cardPaddingLarge,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppSpacing.borderRadiusLg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 24),
                  AppSpacing.horizontalSm,
                  Text('Financial DNA', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
                AppSpacing.verticalMd,
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _dnaMetric('Health Score', '${summary.financialHealthScore.toStringAsFixed(0)}/100'),
                  _dnaMetric('Archetype', summary.behavioralArchetype['name'] as String? ?? 'Analyzer'),
                  _dnaMetric('Impulse', '${summary.impulseScore.toStringAsFixed(0)}/100'),
                ]),
              ]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          AppSpacing.verticalXl,

          // Menu items
          _menuItem(theme, Icons.person_outline_rounded, 'Edit Profile', () {}),
          _menuItem(theme, Icons.assessment_outlined, 'Financial Reports', () {}),
          _menuItem(theme, Icons.download_outlined, 'Export Data', () {}),
          _menuItem(theme, Icons.help_outline_rounded, 'Help & Support', () {}),
        ]),
      ),
    );
  }

  Widget _dnaMetric(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
    ]);
  }

  Widget _menuItem(ThemeData t, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: t.textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
