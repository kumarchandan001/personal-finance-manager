import 'package:fintelia/features/behavioral/data/repositories/behavioral_repository.dart';
import 'package:fintelia/features/behavioral/domain/behavioral_model.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final behavioralRepositoryProvider = Provider<BehavioralRepository>((ref) {
  return BehavioralRepository(apiClient: ref.read(apiClientProvider));
});

final behavioralSummaryProvider = FutureProvider.autoDispose<BehavioralSummary>((ref) async {
  final repository = ref.read(behavioralRepositoryProvider);
  return repository.getBehavioralSummary();
});
