import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//  MATRIX OF  STATICS CARDS
class StatsSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final int treansactioncount;
  final double incomeChangePercent; //percentage change in income vs last month
  final double
  expenseChangePercent; //percentage change in expenses vs last month
  final double savingRat; //ercentage of income that was saved
  const StatsSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.treansactioncount,
    this.incomeChangePercent = 0.0,
    this.expenseChangePercent = 0.0,
    this.savingRat = 0.0,
  });
  @override
  Widget build(BuildContext context) {
    final onSurface=Theme.of(context).colorScheme.onSurface;
    final saved = totalIncome - totalExpense;
    final saveRate = totalIncome == 0
        ? 0.0
        : ((saved / totalIncome) * 100).clamp(0.0, 100.0);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return GridView.count(
      crossAxisCount: 2, //Splits the grid into exactly two columns.
      crossAxisSpacing:
          10, //Puts a 10-pixel gap horizontally between the two columns.
      mainAxisSpacing: 10, //: Puts a 10-pixel gap vertically between the rows.
      childAspectRatio: 1.6, // controls how tall each card is
      shrinkWrap: true, // insidce a scroll view
      physics:
          const NeverScrollableScrollPhysics(), //the parent scroll view handles scrolling, not this grid
      children: [
        // Income Card
        _StatsCard(
          label: 'Income',
          value: formatter.format(totalIncome),
          change: incomeChangePercent == 0
              ? 'vs last month'
              : '${incomeChangePercent > 0 ? '+' : ''}${incomeChangePercent.toStringAsFixed(0)}% vs last month',
          valueColor: incomeChangePercent >= 0
              ? AppColors.green
              : AppColors.red,
        ),

        // Expense Card
        _StatsCard(
          label: 'Expenses',
          value: formatter.format(totalExpense),
          change: expenseChangePercent == 0
              ? 'vs last month'
              : '${expenseChangePercent > 0 ? '+' : ''}${expenseChangePercent.toStringAsFixed(0)}% vs last month ',
          valueColor: expenseChangePercent <= 0
              ? AppColors.green
              : AppColors.red,
        ),
        // Save Card
        _StatsCard(
          label: 'Saved',
          value: formatter.format(saved >= 0 ? saved : saved.abs()),
          change: '${saveRate.toStringAsFixed(0)}% of income',
          valueColor: savingRat >= 50 ? AppColors.green : AppColors.red,
        ),
        // Transaction
        _StatsCard(
          label: 'Transaction',
          value:treansactioncount.toString() ,
          change: 'This Month',
          valueColor:onSurface.withOpacity(0.4) ,
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String change; //small texts at bottom '67%rate' or 'this monht'
  final Color valueColor;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.change,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 4),
          //fits perfectly inside its parent container without overflowing.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            change,
            style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}
