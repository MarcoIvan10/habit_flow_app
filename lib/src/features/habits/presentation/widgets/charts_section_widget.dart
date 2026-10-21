import 'package:flutter/material.dart';

import '../../domain/models/daily_progress_point.dart';
import '../../domain/models/habit_with_metrics.dart';
import 'streaks_comparison_chart_card.dart';
import 'weekly_progress_chart_card.dart';

/// Composes the weekly progress bar chart and the streaks comparison bar chart section.
class ChartsSectionWidget extends StatelessWidget {
  /// Creates a [ChartsSectionWidget].
  const ChartsSectionWidget({
    required this.dailyProgressPoints,
    required this.habits,
    super.key,
  });

  /// Seven daily progress points for the active week.
  final List<DailyProgressPoint> dailyProgressPoints;

  /// Habits to include in the streak comparison chart.
  final List<HabitWithMetrics> habits;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeeklyProgressChartCard(points: dailyProgressPoints),
        const SizedBox(height: 16),
        StreaksComparisonChartCard(habits: habits),
      ],
    );
  }
}
