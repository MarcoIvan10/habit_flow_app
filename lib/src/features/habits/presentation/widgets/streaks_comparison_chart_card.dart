import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/habit_with_metrics.dart';
import 'chart_legend_dot.dart';

/// Displays a grouped `fl_chart` bar chart comparing each habit's active streak against its historical best streak.
class StreaksComparisonChartCard extends StatelessWidget {
  /// Creates a [StreaksComparisonChartCard].
  const StreaksComparisonChartCard({
    required this.habits,
    super.key,
  });

  /// Habits paired with their computed streak metrics.
  final List<HabitWithMetrics> habits;

  double _computeMaxY() {
    int maxStreakValue = 5;
    for (final item in habits) {
      maxStreakValue = math.max(
        maxStreakValue,
        math.max(item.currentStreak, item.bestStreak),
      );
    }
    return ((maxStreakValue + 2) / 2).ceil() * 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxY = _computeMaxY();
    final interval = math.max(1.0, (maxY / 4).roundToDouble());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comparativa de Rachas',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Racha actual vs. récord histórico (en días)',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const ChartLegendDot(
                  color: AppColors.amber500,
                  label: 'Actual',
                ),
                const SizedBox(width: 10),
                const ChartLegendDot(
                  color: AppColors.indigo500,
                  label: 'Récord',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 205,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.slate800 : AppColors.slate200,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          isDark ? AppColors.slate800 : AppColors.slate900,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = habits[groupIndex];
                        final label =
                            rodIndex == 0 ? 'Racha Actual' : 'Récord Histórico';
                        return BarTooltipItem(
                          '${item.habit.icon} ${item.habit.name}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '$label: ${rod.toY.toInt()} días',
                              style: TextStyle(
                                color: rodIndex == 0
                                    ? AppColors.amber500
                                    : AppColors.indigo400,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}d',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.slate400,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= habits.length) {
                            return const SizedBox.shrink();
                          }
                          final habit = habits[index].habit;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Tooltip(
                              message: habit.name,
                              child: Text(
                                habit.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List<BarChartGroupData>.generate(
                    habits.length,
                    (index) {
                      final item = habits[index];
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: item.currentStreak.toDouble(),
                            width: 11,
                            color: AppColors.amber500,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: item.bestStreak.toDouble(),
                            width: 11,
                            color: AppColors.indigo500,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

