//    The bar chart showing last 6 months of spending with the current month
//     highlighted in accent color.
import 'package:fintak/core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<double> monthlySpendings;

  const MonthlyBarChart({super.key, required this.monthlySpendings});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly spending',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.accentDark : AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text('${monthlySpendings.length}M',
                style: TextStyle(color:Colors.white),
                 
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart wrapper with explicit height constraint
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false), // background lines 
                borderData: FlBorderData(show: false), // remove borders around the chart
                //  horizontion layout look
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles( 
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,// text blow the chart shape
                      // creating months names
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final month = DateTime(
                          now.year,
                          now.month - (5 - value.toInt()),
                        );
                        // date to months name
                        final label = DateFormat('MMM').format(month);
                        final isCurrentMonth = value.toInt() == 5;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isCurrentMonth
                                  ? AppColors.accent
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                 // logic of touching the border
                barTouchData: BarTouchData(
                  // toching shows popup wuth black background
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    // Touched chart items
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        // rod.yoY  height of column
                        // Column is zero created small tiny to show it empy
                        '\$${rod.toY == 0.5 ? "0" : rod.toY.toStringAsFixed(0)}}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                // Creating Column of charts
                barGroups: List.generate(6, (i) {
                  // Last Cloumn or current month
                  final isCurrentMonth = i == 5;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        // 0.5 gives a tiny visible stub when spending is zero
                        toY: monthlySpendings[i] == 0
                            ? 0.5
                            : monthlySpendings[i],
                        color: isCurrentMonth
                            ? AppColors.accent
                            : AppColors.accentSoft,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
