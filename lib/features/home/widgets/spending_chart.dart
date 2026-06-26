import 'package:fintak/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingChart extends StatelessWidget {
 final List<double> monthlyTotals;
 const SpendingChart({super.key, required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending trend',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '6 months',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          //  chart
          SizedBox(
            height: 90,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false), //<-- No gird line
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(enabled: false),
                //  plus 20% more empty space to roof top to stop it touching the top line
                minY: 0,
                maxY: monthlyTotals.isEmpty
                    ? 100
                    : monthlyTotals.reduce((a, b) => a > b ? a : b) * 1.2,
                //   fixing vartical horiznatal of months
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20, // 20 pixles for months names
                      getTitlesWidget: (value, meta) {
                        // NOTE  month is hardcoded for not later must be dynamic
                        const months = [
                          'Dec',
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                        ];
                        final index = value.toInt();
                        if (index < 0 || index >= months.length)
                          return const SizedBox.shrink();
                        final isLast = index == months.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[index],
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: isLast
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isLast ? AppColors.accent : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      monthlyTotals.length,
                      (i) => FlSpot(i.toDouble(), monthlyTotals[i]),
                    ),
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isLast = index == monthlyTotals.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 4 : 0,
                          color: AppColors.accent,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withOpacity(0.18),
                          AppColors.accent.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
