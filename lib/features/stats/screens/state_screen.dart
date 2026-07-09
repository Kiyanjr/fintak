import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:fintak/features/stats/widgets/category_donut_chart.dart';
import 'package:fintak/features/stats/widgets/monthly_bar_chart.dart';
import 'package:fintak/features/stats/widgets/stats_summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StateScreen extends ConsumerWidget {
  const StateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsViewModelProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (statsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final now = DateTime.now();
    final thisMonthCount = statsState.transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Statistics',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM yyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'overview',
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                //   Summary Cards
                StatsSummaryCard(
                  totalIncome: statsState.totalIncome,
                  totalExpense: statsState.totalExpenses,
                  treansactioncount: thisMonthCount.length,
                  incomeChangePercent: statsState.incomeChangePercent,
                  expenseChangePercent: statsState.expenseChangePercent,
                  savingRat: statsState.savingsRate,
                ),
                const SizedBox(height: 14),

                // Monthly Spending Chart
                monthlyBarChart(monthlySpendings: statsState.monthlySpending),
                const SizedBox(height: 14),

                // Category Donut Char
                CategoryDonutChart(
                  categoryBreakdown: statsState.categoryBreakdown,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
