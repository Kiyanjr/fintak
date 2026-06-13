import 'package:fintak/data/models/budget_model.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalDatasource {
  SharedPreferences? _pref;

  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final jsonList = transactions
        .map((transaction) => transaction.toJson())
        .toList();

    final jsonString = jsonEncode(jsonList);

    await _pref!.setString('transactions', jsonString);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final jsonString = _pref?.getString('transactions');

    if (jsonString == null) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBudgets(List<BudgetModel> budgets) async {
    final jsonList = budgets.map((budgets) => budgets.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _pref!.setString('budgets', jsonString);
  }

  Future<List<BudgetModel>> getBudgets() async {
    final jsonString = _pref!.getString('budgets');
    if (jsonString == null) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> getTheme() async {
    return _pref!.getBool('isDarkMode') ?? false;
  }

  Future<void> saveTheme(bool isDarkMode) async {
    await _pref!.setBool('isDarkMode', isDarkMode);
  }

  //  Accepts a single UserModel, converts to map, encodes to string, saves
  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _pref!.setString('user', jsonString);
  }

  
  UserModel? getUser() {
    final jsonString = _pref!.getString('user');
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    final Map<String, dynamic> userMap = jsonDecode(jsonString);
    return UserModel.fromJson(userMap);
  }

  //  Removes the 'user' key on sign out
  Future<void> clearUser() async {
    await _pref!.remove('user');
  }
}

final localDataSourceProvider = FutureProvider<LocalDatasource>((ref) async {
  final datasource = LocalDatasource();
  await datasource.init();
  return datasource;
});
