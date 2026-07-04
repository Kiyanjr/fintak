//   Manages budget limits per category
import 'package:fintak/data/datasources/local_datasource.dart';
import 'package:fintak/data/models/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetRepository {
final LocalDatasource _dataSource;
BudgetRepository(this._dataSource);
final List<BudgetModel> _budgets=[];

Future <List<BudgetModel>> getBudgets()async{
  return await _dataSource.getBudgets();
}
    /*   SAVE BUDGET
     Find matching category + month + year.
    Replace it if found.
   Add it if not found.
      Save the updated list:
    */
Future<void> saveBudget(BudgetModel budget) async {
    final budgets = await _dataSource.getBudgets();

    final index = budgets.indexWhere(
      (existingBudget) =>
          existingBudget.category == budget.category &&
          existingBudget.month == budget.month &&
          existingBudget.year == budget.year,
    );

    if (index != -1) {
      budgets[index] = budget;
    } else {
      budgets.add(budget);
    }

    await _dataSource.saveBudgets(budgets);
  }
Future<void> deleteBudget(String id)async{
  final budgets=await _dataSource.getBudgets();
  _budgets.removeWhere((budget)=>budget.id==id);
  await _dataSource.saveBudgets(budgets);

}

Future <void> updateBudget(String id, BudgetModel updated)async{
  final budgets= await _dataSource.getBudgets();
  final index=budgets.indexWhere(
    (budget)=>budget.id==id,
  );
  if(index!=-1){
    budgets[index]=updated;
    await _dataSource.saveBudgets(budgets);
  }
}


}
final budgetRepositoryProvider=Provider<BudgetRepository>((ref){
  final datasource=ref.watch(localDataSourceProvider).requireValue;
  return BudgetRepository(datasource);
});