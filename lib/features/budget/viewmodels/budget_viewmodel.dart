import 'package:fintak/data/models/budget_model.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/budget_repository.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

// Represents one category item in the budget list
class CategoryBudgetItem {
  final String budgetId;
  final TransactionCategory category;
  final double budgetLimit;
  final double spent;

  CategoryBudgetItem({
    required this.budgetId,
    required this.category,
    required this.budgetLimit,
    required this.spent,
  });

  double get remaining => budgetLimit - spent;

  double get percentage =>
      budgetLimit == 0 ? 0.0 : (spent / budgetLimit).clamp(0.0, 1.0);

  bool get isOverBudget => spent > budgetLimit;
}

// Holds the full screen state for the Budget screen
class BudgetState {
  final bool isLoading;
  final double totalBudget;
  final double totalSpent;
  final List<CategoryBudgetItem> categoryItems;
  final String? errorMessage;

  BudgetState({
    this.isLoading = false,
    this.totalBudget = 0.0,
    this.totalSpent = 0.0,
    this.categoryItems = const [],
    this.errorMessage,
  });

  double get totalRemaining => totalBudget - totalSpent;

  double get totalPercentage =>
      totalBudget == 0 ? 0.0 : (totalSpent / totalBudget).clamp(0.0, 1.0);

  BudgetState copyWith({
    bool? isLoading,
    double? totalBudget,
    double? totalSpent,
    List<CategoryBudgetItem>? categoryItems,
    String? errorMessage,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      categoryItems: categoryItems ?? this.categoryItems,
      errorMessage: errorMessage,
    );
  }
}

class BudgetViewModel extends StateNotifier<BudgetState> {
  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  BudgetViewModel(
    this._budgetRepository,
    this._transactionRepository,
  ) : super(BudgetState()) {
    loadBudgets();
  }

  // Load budgets and calculate spent amounts for current month
  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      final allBudgets = await _budgetRepository.getBudgets();
      final allTransactions = await _transactionRepository.getTransactions();

      // Filter budgets for the current month and year only
      final currentMonthBudgets = allBudgets.where((b) =>
          b.month == currentMonth && b.year == currentYear).toList();

      // Filter transactions for the current month
      final thisMonthExpenses = allTransactions.where((t) {
        return t.date.month == currentMonth &&
            t.date.year == currentYear &&
            t.type == TransactionType.expense;
      }).toList();

      // Map each budget into a CategoryBudgetItem
      final categoryItems = currentMonthBudgets.map((budget) {
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

      final totalBudget =
          categoryItems.fold(0.0, (sum, item) => sum + item.budgetLimit);

      final totalSpent =
          thisMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);

      state = state.copyWith(
        isLoading: false,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        categoryItems: categoryItems,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load budgets.',
      );
    }
  }

  // Add or update a category budget for the current month
  Future<void> addOrUpdateBudget(
      TransactionCategory category, double limit) async {
    try {
      final now = DateTime.now();
      final budget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        limit: limit,
        month: now.month,
        year: now.year,
      );

      await _budgetRepository.saveBudget(budget);
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save budget.',
      );
    }
  }

  // Delete a budget by ID with immediate optimistic UI update
  Future<void> deleteBudget(String budgetId) async {
    try {
      //  Optimistic UI update: remove item locally first so UI responds instantly
      final updatedItems = state.categoryItems
          .where((item) => item.budgetId != budgetId)
          .toList();

      final newTotalBudget =
          updatedItems.fold(0.0, (sum, b) => sum + b.budgetLimit);

      state = state.copyWith(
        categoryItems: updatedItems,
        totalBudget: newTotalBudget,
      );

      //  Perform actual deletion in the repository
      await _budgetRepository.deleteBudget(budgetId);

      //  Sync state with the repository
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete budget.',
      );
    }
  }
}

final budgetViewModelProvider =
    StateNotifierProvider<BudgetViewModel, BudgetState>((ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return BudgetViewModel(budgetRepo, transactionRepo);
});