import 'package:fintak/data/models/budget_model.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/budget_repository.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/budget_repository.dart';

// ─────────────────────────────────────────────
// CategoryBudgetItem
// A computed object combining BudgetModel + actual spending
// This is NOT saved anywhere — created fresh every time loadBudgets() runs
// ─────────────────────────────────────────────
class CategoryBudgetItem {
  final String budgetId;         // id of the BudgetModel — needed for delete
  final TransactionCategory category;
  final double budgetLimit;      // the max the user set
  final double spent;            // how much actually spent this month

  const CategoryBudgetItem({
    required this.budgetId,
    required this.category,
    required this.budgetLimit,
    required this.spent,
  });

  // How much is left — can be negative if over budget
  double get remaining => budgetLimit - spent;

  // Percentage spent — clamped so it never visually exceeds 100%
  double get percentage => budgetLimit == 0
      ? 0.0
      : (spent / budgetLimit).clamp(0.0, 1.0);

  // Simple flag the UI uses to show red vs green
  bool get isOverBudget => spent > budgetLimit;
}

// ─────────────────────────────────────────────
// BudgetState
// Everything the Budget screen needs at any moment
// ─────────────────────────────────────────────
class BudgetState {
  final List<CategoryBudgetItem> categoryItems;
  final double totalBudget;   // sum of all budget limits
  final double totalSpent;    // sum of all expense transactions this month
  final bool isLoading;
  final String? errorMessage;
  final int currentMonth;
  final int currentYear;

  static const _sentinel = Object();

  const BudgetState({
    this.categoryItems = const [],
    this.totalBudget = 0.0,
    this.totalSpent = 0.0,
    this.isLoading = true,
    this.errorMessage,
    int? currentMonth,
    int? currentYear,
  })  : currentMonth = currentMonth ?? 0,
        currentYear = currentYear ?? 0;

  BudgetState copyWith({
    List<CategoryBudgetItem>? categoryItems,
    double? totalBudget,
    double? totalSpent,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? currentMonth,
    int? currentYear,
  }) {
    return BudgetState(
      categoryItems: categoryItems ?? this.categoryItems,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      isLoading: isLoading ?? this.isLoading,
      // sentinel pattern — lets us explicitly set errorMessage back to null
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
    );
  }
}

// ─────────────────────────────────────────────
// BudgetViewModel
// Manages all budget logic — loading, adding, deleting
// ─────────────────────────────────────────────
class BudgetViewModel extends StateNotifier<BudgetState> {
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  BudgetViewModel(this._transactionRepository, this._budgetRepository)
      : super(BudgetState(
          currentMonth: DateTime.now().month,
          currentYear: DateTime.now().year,
        )) {
    // Load immediately when ViewModel is created
    loadBudgets();
  }

  // ── LOAD ──────────────────────────────────
  // Main method — loads transactions + budgets, calculates everything
  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Load both lists at the same time — faster than awaiting one by one
      final results = await Future.wait([
        _transactionRepository.getTransactions(),
        _budgetRepository.getBudgets(),
      ]);

      final transactions = results[0] as List<TransactionModel>;
      final budgets = results[1] as List<BudgetModel>;

      // Only care about expense transactions in the current month
      final thisMonthExpenses = transactions.where((t) =>
          t.type == TransactionType.expense &&
          t.date.month == currentMonth &&
          t.date.year == currentYear).toList();

      // For each budget, calculate how much was spent in that category this month
      final categoryItems = budgets.map((budget) {
        final spent = thisMonthExpenses
            .where((t) => t.category == budget.category)
            .fold(0.0, (sum, t) => sum + t.amount);

        return CategoryBudgetItem(
          budgetId: budget.id,
          category: budget.category,
          budgetLimit: budget.limit,
          spent: spent,
        );
      }).toList();

      // Sort — over budget items appear at the top
      categoryItems.sort((a, b) {
        if (a.isOverBudget && !b.isOverBudget) return -1;
        if (!a.isOverBudget && b.isOverBudget) return 1;
        return 0;
      });

      // Total budget = sum of all limits
      final totalBudget =
          budgets.fold(0.0, (sum, b) => sum + b.limit);

      // Total spent = sum of ALL expense transactions this month
      // (not just ones with a budget set)
      final totalSpent =
          thisMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);

      state = state.copyWith(
        categoryItems: categoryItems,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        isLoading: false,
        currentMonth: currentMonth,
        currentYear: currentYear,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load budgets. Please try again.',
      );
    }
  }

  // ── ADD OR UPDATE ──────────────────────────
  // If a budget already exists for this category+month+year → update its limit
  // If not → create a new one
  Future<void> addOrUpdateBudget(
      TransactionCategory category, double limit) async {
    try {
      final budgets = await _budgetRepository.getBudgets();

      // Check if a budget already exists for this category this month
      final existing = budgets.where((b) =>
          b.category == category &&
          b.month == DateTime.now().month &&
          b.year == DateTime.now().year).firstOrNull;

      if (existing != null) {
        // Update the existing one with the new limit
        final updated = existing.copyWith(limit: limit);
        await _budgetRepository.updateBudget(existing.id,updated);
      } else {
        // Create a brand new budget
        final newBudget = BudgetModel(
          category: category,
          limit: limit,
          month: DateTime.now().month,
          year: DateTime.now().year,
        );
        await _budgetRepository.saveBudget(newBudget);
      }

      // Reload to reflect changes
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save budget. Please try again.',
      );
    }
  }

  // ── DELETE ─────────────────────────────────
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _budgetRepository.deleteBudget(budgetId);
      // Reload to reflect deletion
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete budget.',
      );
    }
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
final budgetViewModelProvider =
    StateNotifierProvider<BudgetViewModel, BudgetState>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  return BudgetViewModel(transactionRepo, budgetRepo);
});
