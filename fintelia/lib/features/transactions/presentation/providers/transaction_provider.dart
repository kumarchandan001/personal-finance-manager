/// ============================================
/// FINTELIA — Transaction Provider
/// State management for transaction CRUD
/// ============================================
library;

import 'package:fintelia/features/transactions/data/repositories/transaction_repository.dart';
import 'package:fintelia/shared/models/transaction_model.dart';
import 'package:fintelia/shared/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transaction repository provider.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TransactionRepository(apiClient: apiClient);
});

/// Filter state for transaction list.
class TransactionFilter {
  const TransactionFilter({this.category, this.transactionType});
  final String? category;
  final String? transactionType;

  TransactionFilter copyWith({String? category, String? transactionType}) {
    return TransactionFilter(
      category: category,
      transactionType: transactionType,
    );
  }
}

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => const TransactionFilter(),
);

/// Transaction list state.
class TransactionListState {
  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  TransactionListState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Transaction list notifier with CRUD and filtering.
class TransactionNotifier extends StateNotifier<TransactionListState> {
  TransactionNotifier(this._repo) : super(const TransactionListState());

  final TransactionRepository _repo;
  static const _pageSize = 20;

  /// Load transactions (replaces current list).
  Future<void> loadTransactions({
    String? category,
    String? transactionType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final txns = await _repo.list(
        limit: _pageSize,
        category: category,
        transactionType: transactionType,
      );
      state = state.copyWith(
        transactions: txns,
        isLoading: false,
        hasMore: txns.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more transactions (pagination).
  Future<void> loadMore({String? category, String? transactionType}) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final txns = await _repo.list(
        limit: _pageSize,
        offset: state.transactions.length,
        category: category,
        transactionType: transactionType,
      );
      state = state.copyWith(
        transactions: [...state.transactions, ...txns],
        isLoading: false,
        hasMore: txns.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new transaction and prepend to list.
  Future<bool> createTransaction(Map<String, dynamic> data) async {
    try {
      final txn = await _repo.create(data);
      state = state.copyWith(
        transactions: [txn, ...state.transactions],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update an existing transaction in the list.
  Future<bool> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _repo.update(id, data);
      final txns = state.transactions
          .map((t) => t.id == id ? updated : t)
          .toList();
      state = state.copyWith(transactions: txns);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a transaction from the list.
  Future<bool> deleteTransaction(String id) async {
    try {
      await _repo.delete(id);
      final txns = state.transactions.where((t) => t.id != id).toList();
      state = state.copyWith(transactions: txns);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Global transaction list provider.
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionListState>((ref) {
  final repo = ref.read(transactionRepositoryProvider);
  return TransactionNotifier(repo);
});

/// Transaction summary provider (income/expense totals).
final transactionSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getSummary();
});

/// Transaction categories provider.
final transactionCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getCategories();
});
