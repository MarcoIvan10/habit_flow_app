import '../../../../core/utils/week_day_info.dart';
import '../models/daily_progress_point.dart';
import '../models/dashboard_kpi_summary.dart';
import '../models/habit_with_metrics.dart';

/// Sealed hierarchy representing the UI state of the main habits dashboard.
sealed class DashboardUiState {
  /// Creates a [DashboardUiState].
  const DashboardUiState();
}

/// Indicates that habits and completion logs are currently loading.
final class DashboardUiLoading extends DashboardUiState {
  /// Creates a [DashboardUiLoading] state.
  const DashboardUiLoading();
}

/// Indicates that loading the habits workspace failed with [message].
final class DashboardUiError extends DashboardUiState {
  /// Creates a [DashboardUiError] state.
  const DashboardUiError(this.message);

  /// User-facing error message.
  final String message;
}

/// Represents the ready state containing all computed dashboard metrics, filtered habits, and chart points.
final class DashboardUiReady extends DashboardUiState {
  /// Creates a [DashboardUiReady] state.
  const DashboardUiReady({
    required this.allHabits,
    required this.filteredHabits,
    required this.weekDays,
    required this.weekRangeLabel,
    required this.weekOffset,
    required this.selectedCategory,
    required this.kpiSummary,
    required this.dailyProgressPoints,
  });

  /// Complete list of user habits enriched with streak metrics.
  final List<HabitWithMetrics> allHabits;

  /// List of habits filtered by [selectedCategory].
  final List<HabitWithMetrics> filteredHabits;

  /// The 7 days (Monday to Sunday) of the active week at [weekOffset].
  final List<WeekDayInfo> weekDays;

  /// Formatted Spanish date range label for the active week.
  final String weekRangeLabel;

  /// Relative week offset (`0` for current week, negative for past weeks).
  final int weekOffset;

  /// Currently selected category filter (`Todas` or a specific category).
  final String selectedCategory;

  /// Aggregated metrics for the four top KPI summary cards.
  final DashboardKpiSummary kpiSummary;

  /// Seven daily progress points used to render the weekly completion bar chart.
  final List<DailyProgressPoint> dailyProgressPoints;

  /// Returns `true` when the user has not created any habits yet.
  bool get isEmptyWorkspace => allHabits.isEmpty;

  /// Returns `true` when habits exist globally but none match [selectedCategory].
  bool get isFilteredEmpty => allHabits.isNotEmpty && filteredHabits.isEmpty;
}

