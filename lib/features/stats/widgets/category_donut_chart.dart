import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//The donut chart with legend showing spending per category.

class CategoryDonutChart extends StatelessWidget {
  final Map<TransactionCategory, double> categoryBreakdown;

  const CategoryDonutChart({super.key, required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final cardDecoration = BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
    final colors = [
      AppColors.accent,
      AppColors.blue,
      AppColors.amber,
      AppColors.teal,
      AppColors.red,
      AppColors.green,
    ];
    final entries = categoryBreakdown.entries.toList();

    // Handels the empty State
    if (categoryBreakdown.isEmpty) {
      return Container(
        // card decoration
        padding: EdgeInsets.all(14),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No expense data yet',
            style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.6)),
          ),
        ),
      );
    }

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 14),
          // Donout chart in left side , items in right
          Row(
            children: [
              SizedBox(
                height: 110,
                width: 110,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2, // space between each chart piece
                    centerSpaceRadius: 32, // raduis of empty space inside the circle
                    sections: _buildSections(entries, colors), // data
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right side Elemnts
              Expanded( //< fully achieveing in right side of screen
                child: Column(
                  children: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    final categoryLabel =
                        entry.key.name[0].toUpperCase() +
                        entry.key.name.substring(1);
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i == entries.length - 1 ? 0 : 7,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(entry.value),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _buildSections(
  List<MapEntry<TransactionCategory, double>> entries,
  List<Color> colors,
) {
  return List.generate(entries.length, (i) {
    final entry = entries[i];
    return PieChartSectionData(
      value: entry.value, // number value of each piece
      color: colors[i % colors.length], // prevending to crush beacus we have 6 colors
      radius: 28, // thickness
      showTitle: false, // dont show number on the piece
    );
  });
}
