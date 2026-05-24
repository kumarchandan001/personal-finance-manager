import 'package:fintelia/features/behavioral/presentation/providers/behavioral_provider.dart';
import 'package:fintelia/features/behavioral/presentation/widgets/score_gauge.dart';
import 'package:fintelia/themes/app_colors.dart';
import 'package:fintelia/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BehavioralScreen extends ConsumerWidget {
  const BehavioralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(behavioralSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial DNA'),
      ),
      body: summaryAsync.when(
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(behavioralRepositoryProvider).analyzeBehavioral();
              ref.invalidate(behavioralSummaryProvider);
            },
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                _buildArchetypeCard(context, summary.behavioralArchetype),
                AppSpacing.verticalXl,
                _buildScoresSection(context, summary),
                AppSpacing.verticalXl,
                _buildRecommendations(context, summary.recommendations),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              AppSpacing.verticalMd,
              Text('Error loading data: ${err.toString()}'),
              AppSpacing.verticalBase,
              ElevatedButton(
                onPressed: () => ref.refresh(behavioralSummaryProvider.future),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchetypeCard(BuildContext context, Map<String, dynamic> archetype) {
    final name = archetype['name'] as String? ?? 'Analyzer';
    final description = archetype['description'] as String? ?? '';

    return Container(
      padding: AppSpacing.cardPaddingLarge,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 32),
              AppSpacing.horizontalMd,
              Expanded(
                child: Text(
                  'Your Archetype: $name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresSection(BuildContext context, dynamic summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Behavioral Scores',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalBase,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScoreGauge(
              score: summary.emotionalSpendingScore,
              title: 'Emotional',
              color: AppColors.primary,
            ),
            ScoreGauge(
              score: summary.impulseScore,
              title: 'Impulse',
              color: AppColors.accent,
            ),
            ScoreGauge(
              score: summary.financialHealthScore,
              title: 'Health',
              color: AppColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, List<String> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        AppSpacing.verticalBase,
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Padding(
                  padding: AppSpacing.cardPaddingSmall,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppColors.warning),
                      AppSpacing.horizontalMd,
                      Expanded(
                        child: Text(
                          rec,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
