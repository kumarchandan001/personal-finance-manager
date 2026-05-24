/// ============================================
/// FINTELIA — Analytics Provider
/// State management for analytics data
/// ============================================
library;

import 'package:fintelia/features/analytics/data/repositories/analytics_repository.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(apiClient: ref.read(apiClientProvider));
});

// Overview
final analyticsOverviewProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, days) async {
  return ref.read(analyticsRepositoryProvider).getOverview(days: days);
});

// Monthly data
final analyticsMonthlyProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, months) async {
  return ref.read(analyticsRepositoryProvider).getMonthly(months: months);
});

// Weekly data
final analyticsWeeklyProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, weeks) async {
  return ref.read(analyticsRepositoryProvider).getWeekly(weeks: weeks);
});

// Categories
final analyticsCategoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, days) async {
  return ref.read(analyticsRepositoryProvider).getCategories(days: days);
});

// Trends
final analyticsTrendsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, months) async {
  return ref.read(analyticsRepositoryProvider).getTrends(months: months);
});

// Cashflow
final analyticsCashflowProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, days) async {
  return ref.read(analyticsRepositoryProvider).getCashflow(days: days);
});

// Insights
final analyticsInsightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(analyticsRepositoryProvider).getInsights();
});

// Period selector state
enum AnalyticsPeriod { weekly, monthly, yearly }

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.monthly);
