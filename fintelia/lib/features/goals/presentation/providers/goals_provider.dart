/// ============================================
/// FINTELIA — Goal Provider
/// State management for goals with CRUD + progress
/// ============================================
library;

import 'package:fintelia/features/goals/data/repositories/goal_repository.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(apiClient: ref.read(apiClientProvider));
});

// Goal list state
class GoalListState {
  const GoalListState({this.goals = const [], this.isLoading = false, this.error});
  final List<Map<String, dynamic>> goals;
  final bool isLoading;
  final String? error;

  GoalListState copyWith({List<Map<String, dynamic>>? goals, bool? isLoading, String? error}) {
    return GoalListState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GoalNotifier extends StateNotifier<GoalListState> {
  GoalNotifier(this._repo) : super(const GoalListState());
  final GoalRepository _repo;

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goals = await _repo.listWithDetails();
      state = state.copyWith(goals: goals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createGoal(Map<String, dynamic> data) async {
    try {
      await _repo.create(data);
      await loadGoals(); // Reload to get calculated fields
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      await _repo.update(id, data);
      await loadGoals();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addProgress(String id, double amount) async {
    try {
      await _repo.updateProgress(id, amount);
      await loadGoals();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGoal(String id) async {
    try {
      await _repo.delete(id);
      state = state.copyWith(goals: state.goals.where((g) => g['id'] != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, GoalListState>((ref) {
  return GoalNotifier(ref.read(goalRepositoryProvider));
});
