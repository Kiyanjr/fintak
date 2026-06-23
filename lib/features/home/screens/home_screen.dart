import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/features/home/viewmodels/home_viewmodel.dart';
import 'package:fintak/features/home/widgets/balance_card.dart';
import 'package:fintak/features/home/widgets/spending_chart.dart';
import 'package:fintak/features/home/widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
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

    //  if database is loading
    if (homeState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    //  completed load
    return Scaffold(
       floatingActionButton: FloatingActionButton(
        onPressed: (){
          // wired in next steps
        },
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
        child: const Icon(Icons.add_rounded),
       ) ,
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
                SpendingChart(
                  monthlyTotals: const [450, 720, 540, 880, 640, 1920],
                ),

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
                        //  later: add navigation
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(fontSize: 11, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                       // only the 5 recents are showing
                TransactionList(transactions: homeState.transactions.take(5).toList()),
              ], // last
            ),
          ),
        ),
      ),
    );
  }
}
