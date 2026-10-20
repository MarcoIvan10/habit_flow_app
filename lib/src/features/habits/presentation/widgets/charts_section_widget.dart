import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/dashboard_models.dart';

/// Sección de Analítica Visual con `fl_chart` (Sección 5.5 de la especificación).
/// Incluye:
/// 1. Progreso Diario de la Semana (`BarChart` 0% - 100%).
/// 2. Comparativa de Rachas por Hábito (`BarChart` agrupado: Racha Actual vs Récord Histórico).
class ChartsSectionWidget extends StatelessWidget {
  const ChartsSectionWidget({
    required this.dailyProgressPoints,
    required this.habits,
    super.key,
  });

  final List<DailyProgressPoint> dailyProgressPoints;
  final List<HabitWithMetrics> habits;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeeklyProgressChartCard(points: dailyProgressPoints),
        const SizedBox(height: 16),
        _StreaksComparisonChartCard(habits: habits),
      ],
    );
  }
}

class _WeeklyProgressChartCard extends StatelessWidget {
  const _WeeklyProgressChartCard({required this.points});

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
                const _LegendDot(
                  color: AppColors.emerald500,
                  label: '100%',
                ),
                const SizedBox(width: 10),
                const _LegendDot(
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
                      final isFull = point.percentage >= 99.9 &&
                          point.totalHabits > 0;
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

class _StreaksComparisonChartCard extends StatelessWidget {
  const _StreaksComparisonChartCard({required this.habits});

  final List<HabitWithMetrics> habits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int maxStreakValue = 5;
    for (final item in habits) {
      maxStreakValue = math.max(
        maxStreakValue,
        math.max(item.currentStreak, item.bestStreak),
      );
    }
    final maxY = ((maxStreakValue + 2) / 2).ceil() * 2.0;
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
                const _LegendDot(
                  color: AppColors.amber500,
                  label: 'Actual',
                ),
                const SizedBox(width: 10),
                const _LegendDot(
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.slate500,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

