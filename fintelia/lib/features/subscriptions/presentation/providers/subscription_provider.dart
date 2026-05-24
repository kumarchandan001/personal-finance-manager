import 'package:fintelia/features/subscriptions/data/repositories/subscription_repository.dart';
import 'package:fintelia/features/subscriptions/domain/subscription_model.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SubscriptionRepository(apiClient: apiClient);
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<List<SubscriptionModel>>>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionNotifier(repo);
});

class SubscriptionNotifier extends StateNotifier<AsyncValue<List<SubscriptionModel>>> {
  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSubscriptions();
  }

  final SubscriptionRepository _repository;

  Future<void> loadSubscriptions() async {
    state = const AsyncValue.loading();
    try {
      final subs = await _repository.getSubscriptions();
      state = AsyncValue.data(subs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createSubscription(Map<String, dynamic> data) async {
    try {
      final newSub = await _repository.createSubscription(data);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newSub]);
      } else {
        state = AsyncValue.data([newSub]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSubscription(String id, Map<String, dynamic> data) async {
    try {
      final updatedSub = await _repository.updateSubscription(id, data);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.map((sub) => sub.id == id ? updatedSub : sub).toList(),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSubscription(String id) async {
    try {
      await _repository.deleteSubscription(id);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((sub) => sub.id != id).toList());
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
