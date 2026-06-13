import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionRepository {

  final LocalDatasource _dataSource;
  // Constructor receives the datasource from outside
  TransactionRepository(this._dataSource);

  //    GETS ALL TRANSACTIONS
  Future <List<TransactionModel>> getTransactions() async {
    return await _dataSource.getTransactions();
  }
  //      Save Transaction
   Future<void> saveTransactions(
    List<TransactionModel> transactions,
  ) async {
    await _dataSource.saveTransactions(transactions);
  }
  //     ADDS NEW TRANSACTION
  Future <void> addTransaction(TransactionModel transaction) async{
    final transactions= await _dataSource.getTransactions();
    transactions.add(transaction);
    await _dataSource.saveTransactions(transactions);
  }

  //    REMOVES A TRANSACTION
  Future<void> deleteTransaction(String id)async {
    final transactions=await _dataSource.getTransactions();
    transactions.removeWhere((transcation) => transcation.id == id);
    await _dataSource.saveTransactions(transactions);
  }

  //   UPDATEING TRANSACTION
 Future<void> updateTransaction(String id, TransactionModel updated)async {
  final transactions=await _dataSource.getTransactions();
    final index = transactions.indexWhere(
      (transcation) => transcation.id == id,
    );
    if (index != -1) {
      transactions[index] = updated;
      await _dataSource.saveTransactions(transactions);
    }
  }
}

//   RIVERPOD
final transactionRepositoryProvider=Provider<TransactionRepository>((ref){
    final datasource=ref.watch(localDataSourceProvider).requireValue;
    return TransactionRepository(datasource);
});
