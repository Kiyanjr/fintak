import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:fintak/features/budget/viewmodels/budget_viewmodel.dart';
import 'package:fintak/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class HomeState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final double totalIncome;
  final double totalExpenses;

  const HomeState({
    this.transactions = const [],
    this.isLoading = true,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
  });
  double get totalBalance => totalIncome - totalExpenses;

  HomeState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    double? totalIncome,
    double? totalExpenses,
  }) {
    return HomeState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }
}

class HomeViewmodel extends StateNotifier<HomeState> {
  final TransactionRepository _transactionRepository;
  final Ref _ref;
  HomeViewmodel(this._ref, {required this._transactionRepository})
    : super(const HomeState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions = await _transactionRepository.getTransactions();

      double incomeSum = 0.0;
      double expenseSum = 0.0;

      for (final t in transactions) {
        if (t.type == TransactionType.income) {
          incomeSum += t.amount;
        } else if (t.type == TransactionType.expense) {
          expenseSum += t.amount;
        }
      }
       //   updating
      state = state.copyWith(
        transactions: transactions,
        totalExpenses: expenseSum,
        totalIncome: incomeSum,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
 // Delete funcation
 Future<void> deleteTransaction(String id) async{
  await _transactionRepository.deleteTransaction(id);
  // Reload everything after deletion
  await loadTransactions();
    // Keep budget and stats in sync
  _ref.read(budgetViewModelProvider.notifier).loadBudgets();
  _ref.read(statsViewModelProvider.notifier).refresh();
 }


}

final homeViewmodelProvider=StateNotifierProvider<HomeViewmodel,HomeState>((ref){
final repository=ref.watch(transactionRepositoryProvider);
return HomeViewmodel(transactionRepository: repository,ref);
});