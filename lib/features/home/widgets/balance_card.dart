import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _formatter = NumberFormat.currency(
  symbol: '\$',
  decimalDigits: 0,
);

class BalanceCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  const BalanceCard({
    super.key,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? AppColors.accentDark : AppColors.accent,
      ),
      padding: EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // total balance label
          Text(
            'Total balance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 4),

          //  balance num
          Text(
            _formatter.format(balance),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          //Income and Expenses row
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  context: context,
                  label: 'Income',
                  amount: totalIncome,
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.teal,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildMiniCard(
                  context: context,
                  label: 'Expenses',
                  amount: totalExpense,
                  icon: Icons.trending_down_rounded,
                  iconColor: Color(0xFFF09595),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildMiniCard({
  required BuildContext context,
  required String label,
  required double amount,
  required IconData icon,
  required Color iconColor,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatter.format(amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
