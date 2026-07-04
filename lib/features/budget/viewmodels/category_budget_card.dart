import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/features/budget/viewmodels/budget_viewmodel.dart';
import 'package:fintak/features/budget/widegts/category_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryBudgetCard extends StatelessWidget {
  final CategoryBudgetItem item;
  final VoidCallback onDelete; // called when user confirms delete

  const CategoryBudgetCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Get icon and colors for this category from shared helper
    final icon = getCategoryIcon(item.category);
    final (bgColor, iconColor) = getCategoryColors(item.category);

    // Capitalize the category name for display
    final categoryLabel = item.category.name[0].toUpperCase() +
        item.category.name.substring(1);

    return GestureDetector(
      // Long press triggers delete confirmation
      onLongPress: onDelete,
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
          children: [

            // ── Top row: icon + name + badge ──
            Row(
              children: [

                // Category icon with colored background
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 15),
                  ),
                ),

                const SizedBox(width: 10),

                // Category name + spent vs limit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryLabel,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurface)),
                      const SizedBox(height: 2),
                      Text(
                        // e.g. "€87.00 of €350.00"
                        '${formatter.format(item.spent)} of ${formatter.format(item.budgetLimit)}',
                        style: TextStyle(
                            fontSize: 10,
                            color: onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),

                // Badge — red "Over" or green percentage
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    // Red background if over, green if on track
                    color: item.isOverBudget
                        ? AppColors.redSoft
                        : AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    item.isOverBudget
                        ? 'Over'
                        : '${(item.percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: item.isOverBudget
                          ? AppColors.red
                          : AppColors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                // percentage is already clamped 0.0-1.0 in the getter
                value: item.percentage,
                minHeight: 5,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  // Red if over, accent purple if on track
                  item.isOverBudget ? AppColors.red : AppColors.accent,
                ),
              ),
            ),

            // Hint text for long press delete
            const SizedBox(height: 6),
            Text(
              'Long press to delete',
              style: TextStyle(
                fontSize: 9,
                color: onSurface.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}