import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/features/home/viewmodels/home_viewmodel.dart';
import 'package:fintak/features/home/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the home view model state to get the full list of transactions
    final homeState = ref.watch(homeViewmodelProvider);
    final transactions = homeState.transactions;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Transactions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),

          centerTitle: true,
        ),
        body: transactions.isEmpty
            ? Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              )
            : TransactionList(
                transactions: transactions,
                onDelete: (id) => ref
                    .read(homeViewmodelProvider.notifier)
                    .deleteTransaction(id),
              ),
      ),
    );
  }
}
