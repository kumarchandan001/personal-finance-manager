/// ============================================
/// FINTELIA — Dashboard Provider
/// Aggregated dashboard data from multiple APIs
/// ============================================
library;

import 'package:fintelia/features/analytics/data/repositories/analytics_repository.dart';
import 'package:fintelia/features/transactions/data/repositories/transaction_repository.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _analyticsRepoProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(apiClient: ref.read(apiClientProvider));
});

final _transactionRepoProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(apiClient: ref.read(apiClientProvider));
});

/// Dashboard overview data.
final dashboardOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(_analyticsRepoProvider);
  return repo.getOverview(days: 30);
});

/// Recent transactions for dashboard.
final dashboardRecentTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.read(_transactionRepoProvider);
  final txns = await repo.list(limit: 5);
  return txns.map((t) => t.toJson()..['id'] = t.id).toList();
});

/// Category breakdown for dashboard pie chart.
final dashboardCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(_analyticsRepoProvider);
  return repo.getCategories(days: 30);
});

/// Weekly trend data for dashboard mini chart.
final dashboardWeeklyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(_analyticsRepoProvider);
  return repo.getWeekly(weeks: 4);
});

/// Insights for dashboard cards.
final dashboardInsightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(_analyticsRepoProvider);
  return repo.getInsights();
});
