import 'package:fintak/data/models/budget_model.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/budget_repository.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class CategoryBudgetItem {
  final TransactionCategory category;
  final double budgetLimit; // the max user set
  final double spent; // how much actually spent this month in this category
  final String budgetId; // the id of the budgetmodel

  CategoryBudgetItem({
    required this.category,
    required this.budgetLimit,
    required this.spent,
    required this.budgetId,
  });
  //No copyWith needed — this is a read-only computed object, never mutated.

  // calculation getter
  double get remaining => budgetLimit - spent;

  // controling % range between 0.0 to 0.1 hleps to prevent overflowing the graphic
  double get percentage =>
      (budgetLimit == 0) ? 0.0 : (spent / budgetLimit).clamp(0.0, 1.0);

  bool get isOverBudget => spent > budgetLimit;
}

//          State Class holding the budget State

class BudgetState {
  final List<CategoryBudgetItem> categoryItems;
  final double totalBudget; // sum of all budget limits
  final double totalSpent; // sum of all spending thus month
  final bool isLoading;
  final String? errorMessage;
  final int currentMonth;
  final int currentYear;

  const BudgetState({
    this.categoryItems = const [],
    this.totalBudget = 0.0,
    this.totalSpent = 0.0,
    this.isLoading = true,
    required this.errorMessage,
    required this.currentMonth,
    required this.currentYear,
  });
  BudgetState copyWith({
    List<CategoryBudgetItem>? categoryItems,
    double? totalBudget,
    double? totalSpent,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false, // senstial pattern to clear error
    int? currentMonth,
    int? currentYear,
  }) {
    return BudgetState(
      categoryItems: categoryItems ?? this.categoryItems,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
    );
  }
}

//     managing and caculating budget  view model
class BudgetViewModel extends StateNotifier<BudgetState> {
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  BudgetViewModel(this._transactionRepository, this._budgetRepository)
    : super(
        BudgetState(
          currentMonth: DateTime.now().month,
          currentYear: DateTime.now().year,
          errorMessage: null,
        ),
      ) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    // /Load both lists in parallel using Future.
    //wait this is faster than awaiting them one by one
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _transactionRepository.getTransactions(),
        _budgetRepository.getBidgets(),
      ]);
      // casting operation : since the output method previous linses are happening at same time
      // we tell the copmpiler that index 0 is for tran and 1 for budgets
      final transactions = results[0] as List<TransactionModel>;
      final budgets = results[1] as List<BudgetModel>;

      // current months and year
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // Filtring transactions into this month expenses
      final thisMonthExpenses = transactions.where((t) {
        return t.type == TransactionType.expense &&
            t.date.month == currentMonth &&
            t.date.year == currentYear;
      }).toList();

      //For each BudgetModel in budgets,
      //calculate how much was spent in that category this month:
      final categoryItems = budgets.map((budget) {
        final spent = thisMonthExpenses
            .where((t) => t.category == budget.category)
            .fold(0.0, (sum, t) => sum + t.amount);
        return CategoryBudgetItem(
          category: budget.category,
          budgetLimit: budget.limit,
          spent: spent,
          budgetId: budget.id,
        );
      }).toList();
      // caculating all sums of budgets and total spending
      final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
      final totalSpent = thisMonthExpenses.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );

      // updating state
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
        errorMessage: 'Failed to load budget analysis.',
      );
    }
  }

  Future<void> addOrupdateBudegt(
    TransactionCategory category,
    double limit,
  ) async {
    try {
      final budgets = await _budgetRepository.getBidgets();
      final now = DateTime.now();
      // checking if the budegt exist in year month
      final existing = budgets
          .where(
            (b) =>
                b.category == category &&
                b.month == now.month &&
                b.year == now.year,
          )
          .firstOrNull; // return null if nothing founded
      if (existing != null) {
        // first scaniro budegt exists  => updating
        final updatedBudget = existing.copyWith(limit: limit);
        await _budgetRepository.updateBudget(existing.id, updatedBudget);
      } else {
        // budget doesnt exist  creating new model
        final newBudget = BudgetModel(
          category: category,
          limit: limit,
          month: now.month,
          year: now.year,
        );
        await _budgetRepository.saveBudget(newBudget);
      }
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save budget changes.');
    }
  }

  // deleting budget method on special id
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _budgetRepository.deleteBudget(budgetId);
      await loadBudgets();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete budget.');
    }
  }
}

// provider
final budgetViewModelProvider =
    StateNotifierProvider<BudgetViewModel, BudgetState>((ref) {
      final transactionRepo = ref.watch(transactionRepositoryProvider);
      final budgetRepo = ref.watch(budgetRepositoryProvider);
      return BudgetViewModel(transactionRepo, budgetRepo);
    });
