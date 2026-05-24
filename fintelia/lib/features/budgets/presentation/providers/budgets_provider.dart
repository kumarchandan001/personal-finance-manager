/// ============================================
/// FINTELIA — Budget Provider
/// State management for budgets with CRUD
/// ============================================
library;

import 'package:fintelia/features/budgets/data/repositories/budget_repository.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(apiClient: ref.read(apiClientProvider));
});

// Budget list
class BudgetListState {
  const BudgetListState({this.budgets = const [], this.isLoading = false, this.error});
  final List<Map<String, dynamic>> budgets;
  final bool isLoading;
  final String? error;

  BudgetListState copyWith({List<Map<String, dynamic>>? budgets, bool? isLoading, String? error}) {
    return BudgetListState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetListState> {
  BudgetNotifier(this._repo) : super(const BudgetListState());
  final BudgetRepository _repo;

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final budgets = await _repo.list();
      state = state.copyWith(budgets: budgets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createBudget(Map<String, dynamic> data) async {
    try {
      final budget = await _repo.create(data);
      state = state.copyWith(budgets: [budget, ...state.budgets]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.update(id, data);
      final budgets = state.budgets.map((b) => b['id'] == id ? updated : b).toList();
      state = state.copyWith(budgets: budgets);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _repo.delete(id);
      state = state.copyWith(budgets: state.budgets.where((b) => b['id'] != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetListState>((ref) {
  return BudgetNotifier(ref.read(budgetRepositoryProvider));
});

// Budget overview
final budgetOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(budgetRepositoryProvider).getOverview();
});

// Budget progress
final budgetProgressProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(budgetRepositoryProvider).getProgress();
});
