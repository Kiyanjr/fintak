import 'package:fintak/features/home/widgets/balance_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BalanceCard(totalExpense: 100000, totalIncome: 300000000),
        ),
    );
  }
}