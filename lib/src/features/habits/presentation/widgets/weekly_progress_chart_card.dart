import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/daily_progress_point.dart';
import 'chart_legend_dot.dart';

/// Displays a `fl_chart` vertical bar chart representing daily completion percentages across the active week.
class WeeklyProgressChartCard extends StatelessWidget {
  /// Creates a [WeeklyProgressChartCard].
  const WeeklyProgressChartCard({
    required this.points,
    super.key,
  });

  /// Seven daily progress points from Monday to Sunday.
  final List<DailyProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        'Progreso Diario de la Semana',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Porcentaje de hábitos completados cada día',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const ChartLegendDot(
                  color: AppColors.emerald500,
                  label: '100%',
                ),
                const SizedBox(width: 10),
                const ChartLegendDot(
                  color: AppColors.indigo500,
                  label: 'Parcial',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 195,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
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
                        final point = points[groupIndex];
                        final pct = point.percentage.round();
                        return BarTooltipItem(
                          '${point.shortLabel}: $pct%\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${point.completedCount}/${point.totalHabits} hábitos',
                              style: const TextStyle(
                                color: AppColors.slate300,
                                fontWeight: FontWeight.w500,
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
                        reservedSize: 38,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
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
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          final point = points[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              point.shortLabel,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: point.isToday
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: point.isToday
                                    ? AppColors.indigo500
                                    : AppColors.slate400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List<BarChartGroupData>.generate(
                    points.length,
                    (index) {
                      final point = points[index];
                      final isFull =
                          point.percentage >= 99.9 && point.totalHabits > 0;
                      final barColor = isFull
                          ? AppColors.emerald500
                          : AppColors.indigo500;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: point.percentage.clamp(0.0, 100.0),
                            width: 18,
                            color: barColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: isDark
                                  ? AppColors.slate800.withValues(alpha: 0.6)
                                  : AppColors.slate100,
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

