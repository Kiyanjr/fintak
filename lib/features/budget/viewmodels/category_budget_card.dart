import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/features/budget/viewmodels/budget_viewmodel.dart';
import 'package:fintak/features/budget/widegts/category_helpers.dart';
import 'package:flutter/material.dart';

class CategoryBudgetCard extends StatelessWidget {
  final CategoryBudgetItem item;
  final VoidCallback onDelete;

  const CategoryBudgetCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Capitalize first letter of category name
    final categoryLabel = item.category.name[0].toUpperCase() + item.category.name.substring(1);
    
    // Get shared configuration assets
    final iconData = getCategoryIcon(item.category);
    final (bgColor, iconColor) = getCategoryColors(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1 — Icon + Info + Trailing Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Aligns elements strictly to center line
                children: [
                  // Category design asset wrapper
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text details layout expanding space dynamically
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '\$${item.spent.toStringAsFixed(0)} spent of \$${item.budgetLimit.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Trailing status badge pill container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isOverBudget ? AppColors.redSoft : AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.isOverBudget ? 'Over' : '${(item.percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isOverBudget ? AppColors.red : AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Row 2 — Standard progress status bar
              SizedBox(
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: item.percentage,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isOverBudget ? AppColors.red : AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}