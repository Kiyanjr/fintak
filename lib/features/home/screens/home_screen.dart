import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/features/home/screens/all_transactions_screen.dart';
import 'package:fintak/features/home/viewmodels/home_viewmodel.dart';
import 'package:fintak/features/home/widgets/add_transaction_sheet.dart';
import 'package:fintak/features/home/widgets/balance_card.dart';
import 'package:fintak/features/home/widgets/spending_chart.dart';
import 'package:fintak/features/home/widgets/transaction_list.dart';
import 'package:fintak/features/stats/viewmodels/stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewmodelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlySpendingChart = ref.watch(
      statsViewModelProvider.select((s) => s.monthlySpending),
    );
    //  if database is loading
    if (homeState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    //  completed load
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled:
                true, // critical — allows sheet to grow taller when keyboard opens
            backgroundColor:
                Colors.transparent, // lets our container's borderRadius show
            builder: (context) => const AddTransactionSheet(),
          );
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //       welcome
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kiyan DEV', // fix later
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkField : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // (BalanceCard)
                BalanceCard(
                  totalIncome: homeState.totalIncome,
                  totalExpense: homeState.totalExpenses,
                ),
                const SizedBox(height: 14),
                //      hard coded fix later
                SpendingChart(monthlyTotals: monthlySpendingChart),

                const SizedBox(height: 20),
                // header of list tile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Recent transactions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AllTransactionsScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(fontSize: 11, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                // only the 5 recents are showing
                TransactionList(
                  transactions: homeState.transactions.take(5).toList(),
                  onDelete: (id) => ref.read(homeViewmodelProvider.notifier).deleteTransaction(id),
                ),
              ], // last
            ),
          ),
        ),
      ),
    );
  }
}
