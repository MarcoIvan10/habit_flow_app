import '../../../../core/utils/habit_date_utils.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../models/daily_progress_point.dart';
import '../models/dashboard_filter_state.dart';
import '../models/dashboard_kpi_summary.dart';
import '../models/habit_with_metrics.dart';
import '../models/habits_workspace_data.dart';
import '../states/dashboard_ui_state.dart';

/// Pure domain use case that transforms raw [HabitsWorkspaceData] and [DashboardFilterState]
/// into a complete [DashboardUiReady] state with streak metrics, KPIs, and chart points.
abstract final class BuildDashboardUiStateUseCase {
  /// Executes the dashboard state computation.
  static DashboardUiReady execute({
    required HabitsWorkspaceData workspace,
    required DashboardFilterState filter,
    DateTime? referenceToday,
  }) {
    final today = HabitDateUtils.dateOnly(referenceToday ?? DateTime.now());
    final todayIso = HabitDateUtils.toIsoDateString(today);
    final weekDays = HabitDateUtils.getWeekDays(
      weekOffset: filter.weekOffset,
      referenceDate: today,
    );
    final weekRangeLabel = HabitDateUtils.formatWeekRangeLabel(
      weekOffset: filter.weekOffset,
      referenceDate: today,
    );

    final allHabitsWithMetrics = workspace.habits.map<HabitWithMetrics>((habit) {
      final dates =
          workspace.completedDatesByHabit[habit.id] ?? const <String>{};
      final streaks = StreakCalculator.calculate(
        dates,
        referenceToday: today,
      );
      return (
        habit: habit,
        completedDates: dates,
        currentStreak: streaks.currentStreak,
        bestStreak: streaks.bestStreak,
        isCompletedToday: dates.contains(todayIso),
      );
    }).toList(growable: false);

    final filteredHabits = filter.selectedCategory == 'Todas'
        ? allHabitsWithMetrics
        : allHabitsWithMetrics
            .where((item) => item.habit.category == filter.selectedCategory)
            .toList(growable: false);

    final totalHabits = allHabitsWithMetrics.length;
    final uniqueCategoriesCount =
        allHabitsWithMetrics.map((e) => e.habit.category).toSet().length;

    final todayCompletedCount =
        allHabitsWithMetrics.where((e) => e.isCompletedToday).length;
    final todayCompletionRate =
        totalHabits == 0 ? 0.0 : (todayCompletedCount / totalHabits);

    int topStreakDays = 0;
    String topStreakHabitName = 'Sin rachas activas';
    for (final item in allHabitsWithMetrics) {
      if (item.currentStreak > topStreakDays) {
        topStreakDays = item.currentStreak;
        topStreakHabitName = item.habit.name;
      }
    }

    final weekTargetCount = filteredHabits.length * 7;
    int weekCompletedCount = 0;

    final dailyProgressPoints = weekDays.map<DailyProgressPoint>((day) {
      int completedOnDay = 0;
      for (final item in filteredHabits) {
        if (item.completedDates.contains(day.isoDate)) {
          completedOnDay++;
        }
      }
      weekCompletedCount += completedOnDay;
      final pct = filteredHabits.isEmpty
          ? 0.0
          : (completedOnDay / filteredHabits.length) * 100.0;

      return (
        shortLabel: day.shortLabel,
        isoDate: day.isoDate,
        completedCount: completedOnDay,
        totalHabits: filteredHabits.length,
        percentage: pct,
        isToday: day.isToday,
      );
    }).toList(growable: false);

    final weekCompletionRate =
        weekTargetCount == 0 ? 0.0 : (weekCompletedCount / weekTargetCount);

    final DashboardKpiSummary kpiSummary = (
      activeHabitsCount: totalHabits,
      uniqueCategoriesCount: uniqueCategoriesCount,
      todayCompletedCount: todayCompletedCount,
      todayCompletionRate: todayCompletionRate,
      topStreakDays: topStreakDays,
      topStreakHabitName: topStreakHabitName,
      weekCompletedCount: weekCompletedCount,
      weekTargetCount: weekTargetCount,
      weekCompletionRate: weekCompletionRate,
    );

    return DashboardUiReady(
      allHabits: allHabitsWithMetrics,
      filteredHabits: filteredHabits,
      weekDays: weekDays,
      weekRangeLabel: weekRangeLabel,
      weekOffset: filter.weekOffset,
      selectedCategory: filter.selectedCategory,
      kpiSummary: kpiSummary,
      dailyProgressPoints: dailyProgressPoints,
    );
  }
}

