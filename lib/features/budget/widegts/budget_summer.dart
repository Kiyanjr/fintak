//This is the dark card at the top showing total
//budget vs total spent — matches the dark summary card in your mockup.
import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate overall budget metrics
    final percentage = totalBudget == 0 ? 0.0 : (totalSpent / totalBudget).clamp(0.0, 1.0);
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // 2. Shared decorative style for all cards to prevent duplication
    final cardDecoration = BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -----------------------------------------------------------------
        // Child 1: Two stat cards side by side (Spent & Remaining)
        // -----------------------------------------------------------------
        Row(
          children: [
            // Left card — Spent info
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 10,
                        color: onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(totalSpent),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalSpent > totalBudget
                          ? 'Over budget'
                          : 'of €${totalBudget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.red.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Right card — Remaining info
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 10,
                        color: onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format((totalBudget - totalSpent).abs()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: totalSpent > totalBudget ? AppColors.red : AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalSpent > totalBudget ? 'Exceeded' : 'left this month',
                      style: TextStyle(
                        fontSize: 10,
                        color: onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // -----------------------------------------------------------------
        // Child 3: Overall progress bar card
        // -----------------------------------------------------------------
        Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overall budget used',
                    style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: totalSpent > totalBudget ? AppColors.red : AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fixed height container wrapped around indicator to prevent layout crashes
              SizedBox(
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      totalSpent > totalBudget ? AppColors.red : AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}