import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class StatsState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpenses;
  final List<double> monthlySpending;
  final Map<TransactionCategory, double> categoryBreakdown;
  final bool isLoading;
  final double incomeChangePercent;
  final double expenseChangePercent;
  final double savingsRate;

  StatsState({
    this.transactions = const [],
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.monthlySpending = const [0, 0, 0, 0, 0, 0],
    this.categoryBreakdown = const {},
    this.isLoading = true,
    this.incomeChangePercent = 0.0,
    this.expenseChangePercent = 0.0,
    this.savingsRate = 0.0,
  });
  StatsState copyWith({
    List<TransactionModel>? transactions,
    double? totalIncome,
    double? totalExpense,
    List<double>? monthlySpending,
    Map<TransactionCategory, double>? categoryBreakdown,
    bool? isLoading,
    double? incomeChangePercent,
    double? expenseChangePercent,
    double? savingsRate,
  }) {
    return StatsState(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpense ?? this.totalExpenses,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      isLoading: isLoading ?? this.isLoading,
      incomeChangePercent: incomeChangePercent ?? this.incomeChangePercent,
      expenseChangePercent: expenseChangePercent ?? this.expenseChangePercent,
      savingsRate: savingsRate ?? this.savingsRate,
    );
  }
}

class StatsViewModel extends StateNotifier<StatsState> {
  final TransactionRepository _repository;
  StatsViewModel(this._repository) : super(StatsState()) {
    loadStats();
  }
  // loading Date
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);
    try {
      // Fetch all historical database entries
      final transactions = await _repository.getTransactions();
      final now = DateTime.now();
      // Filter transactions matching strictly current month and year
      final thisMonth = transactions
          .where((t) => t.date.month == now.month && t.date.year == now.year)
          .toList();

      // Filter transactions matching strictly LAST month
      final lastMonth = transactions
          .where(
            (t) =>
                t.date.month == DateTime(now.year, now.month - 1).month &&
                t.date.year == DateTime(now.year, now.month - 1).year,
          )
          .toList();

          // Last month income
          final lastMonthIncome=lastMonth.where((t)=>
          t.type==TransactionType.income
          ).fold(0.0, (sum,t)=>sum+t.amount);
          
          // Last Month Expense
          final lastMonthExpense=lastMonth.where((t)
          => t.type==TransactionType.expense
          ).fold(0.0, (sum,t)=>sum+t.amount);
            

      // Aggregate income totals via fold pipeline loops by their type
      final totalIncome = thisMonth
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      // Aggregate expense totals via fold pipeline loops
      final totalExpense = thisMonth
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      // Generate continuous 6-month historical expense records sequence
      final monthlySpending = List.generate(6, (i) {
        final month = DateTime(now.year, now.month - (5 - 1));
        return transactions
            .where(
              (t) =>
                  t.type == TransactionType.expense &&
                  t.date.month == month.month &&
                  t.date.year == month.year,
            )
            .fold(0.0, (sum, t) => sum + t.amount);
      });

      // categoryBreakDown a map from category to toal spent this month expenses

      // empty map
      final categoryBreakDown = <TransactionCategory, double>{};
      for (final t in thisMonth) {
        if (t.type == TransactionType.expense) {
          categoryBreakDown[t.category] =
              (categoryBreakDown[t.category] ?? 0.0 + t.amount);
        }
      }
      
      // Percentage change vs last month — 0 if no last month data
    final incomeChangePercent=lastMonthIncome == 0
    ? 0.0
    : ((totalIncome - lastMonthIncome)/lastMonthIncome *100);

    final expenseChangePercent=lastMonthExpense==0
    ? 0.0
    :((totalExpense-lastMonthExpense)/lastMonthExpense*100);
    
    // Savings rate wahat % of income was saved
    final savingsRate=totalIncome==0.0
    ? 0.0
    :((totalIncome - totalExpense)/totalIncome *100);

      // Updating state
      state = state.copyWith(
        transactions: transactions,
        totalExpense: totalExpense,
        totalIncome: totalIncome,
        categoryBreakdown: categoryBreakDown,
        monthlySpending: monthlySpending,
        isLoading: false,
        incomeChangePercent: incomeChangePercent,
        expenseChangePercent: expenseChangePercent,
        savingsRate: savingsRate,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() => loadStats();
}

final statsViewModelProvider =
    StateNotifierProvider<StatsViewModel, StatsState>((ref) {
      final repositoy = ref.watch(transactionRepositoryProvider);
      return StatsViewModel(repositoy);
    });
