import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/features/home/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final void Function(String id)? onDelete;
  final void Function(TransactionModel transaction)? onEdit;
  const TransactionList({
    super.key,
    required this.transactions,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: Colors.grey.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'No transactions yet.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // last item in the column wont have divider last from up to down
    return Column(
      // Walk through the logic: if you have 3 transactions, you need 3 tiles + 2 dividers
      children: List.generate(
        transactions.length * 2 - 1, // total widgets we need (items and divider)
        (index) {
          if (index.isOdd) {
            // Odd indexs having horizontal divider line
            return Divider(height: 1, color: dividerColor);
          }
          // for returning true transactions items index
          final transactionIndex = index ~/ 2;
          final transaction = transactions[transactionIndex];

          return TransactionTile(
            transaction: transaction,
            onDelete: onDelete != null ? () => onDelete!(transaction.id) : null, 
            onEdit: onEdit != null ? () => onEdit!(transaction) : null, // Passed to tile
          );
        },
      ),
    );
  }
}