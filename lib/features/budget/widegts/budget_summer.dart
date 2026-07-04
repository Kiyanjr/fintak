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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Overall percentage — guarded against division by zero
    final percentage = totalBudget == 0
        ? 0.0
        : (totalSpent / totalBudget).clamp(0.0, 1.0);

    final isOver = totalSpent > totalBudget;
    final remaining = totalBudget - totalSpent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Row 1: Two stat cards side by side ──
        Row(
          children: [

            // Left card — Spent
            Expanded(
              child: Container(
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
                    Text('Spent',
                        style: TextStyle(
                            fontSize: 10,
                            color: onSurface.withOpacity(0.5))),
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
                      // If over budget show warning, otherwise show the limit context
                      isOver
                          ? 'Over budget!'
                          : 'of ${formatter.format(totalBudget)}',
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

            // Right card — Remaining
            Expanded(
              child: Container(
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
                    Text('Remaining',
                        style: TextStyle(
                            fontSize: 10,
                            color: onSurface.withOpacity(0.5))),
                    const SizedBox(height: 4),
                    Text(
                      // Show absolute value — negative sign is confusing here
                      formatter.format(remaining.abs()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        // Red if over budget, green if still within
                        color: isOver ? AppColors.red : AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isOver ? 'Exceeded' : 'left this month',
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

        // ── Row 2: Overall progress bar card ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              // Label + percentage number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall budget used',
                      style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withOpacity(0.5))),
                  Text(
                    // Show percentage as whole number
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOver ? AppColors.red : AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // The actual progress bar — ClipRRect gives rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? AppColors.red : AppColors.accent,
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