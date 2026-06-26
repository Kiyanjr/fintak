import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/repositories/transaction_repository.dart';
import 'package:fintak/features/home/viewmodels/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AddTransactionState {
  final String title;
  final String amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String note;
  final bool isLoading;
  final String? errorMessage;

  AddTransactionState({
    this.title = '',
    this.amount = '',
    this.type = TransactionType.expense,
    this.category = TransactionCategory.other,
    DateTime? date,
    this.note = '',
    this.isLoading = false,
    this.errorMessage,
  }) : date = date ?? const _DefaultDate().now;

  AddTransactionState copyWith({
    String? title,
    String? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false, // sential for deleting error messages
  }) {
    return AddTransactionState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class _DefaultDate {
  const _DefaultDate();
  DateTime get now => DateTime.now();
}

class AddTransactionViewModel extends StateNotifier<AddTransactionState> {
  final TransactionRepository _repository;
  AddTransactionViewModel(this._repository) : super(AddTransactionState());

  void updateTitle(String value) {
    state = state.copyWith(title: value, errorMessage: null);
  }

  void updateAmount(String value) {
    state = state.copyWith(amount: value, errorMessage: null);
  }

  void updateType(TransactionType type) {
    // Category Reset to other beacus income doenst mean a category of food
    state = state.copyWith(type: type, category: TransactionCategory.other);
  }

  void updateCategory(TransactionCategory category) {
    state = state.copyWith(category: category);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateNote(String value) {
    state = state.copyWith(note: value, errorMessage: null);
  }

  void _setError(String message) {
    state = state.copyWith(errorMessage: message, isLoading: false);
  }

  bool _validate() {
    if (state.title.trim().isEmpty) {
      _setError('Please enter a title');
      return false;
    }
    if (state.amount.trim().isEmpty) {
      _setError('Please enter an amount');
      return false;
    }
    final parsing = double.tryParse(state.amount.trim());
    if (parsing == null) {
      _setError('Please enter a valid amoubt');
      return false;
    }
    if (parsing <= 0) {
      _setError("Amount must be greater than zero");
      return false;
    }
    return true;
  }

  Future<void> saveTransaction(WidgetRef ref, BuildContext context)async {
    if (!_validate()) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final finalAmount = double.parse(state.amount.trim());
      final newTransactionModel = TransactionModel(
        title: state.title.trim(),
        amount: finalAmount,
        type: state.type,
        category: state.category,
        date: state.date,
        note: state.note.trim(),
      );
        //         Storing in the shared preferneces
      await _repository.addTransaction(newTransactionModel);
      //          Homeview model thats main part notice the changes and recall to read new ones
     await ref.read(homeViewmodelProvider.notifier).loadTransactions();
      
      state=state.copyWith(isLoading: false);

      // closing the sheet 
      if(context.mounted){
        Navigator.of(context).pop();
      }

    } catch (e) {
     _setError('Failed to save transaction. Please try again.');
    }
  }
}
   // autoDispose clear the sheet list after being closed. pop
final addTransactionViewModelProvider=StateNotifierProvider.autoDispose<AddTransactionViewModel,AddTransactionState>((ref){
 final repository=ref.watch(transactionRepositoryProvider);
 return AddTransactionViewModel(repository);
});