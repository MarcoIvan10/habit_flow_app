/// Immutable Dart 3 Record containing the four summary KPI metrics displayed on the dashboard.
typedef DashboardKpiSummary = ({
  int activeHabitsCount,
  int uniqueCategoriesCount,
  int todayCompletedCount,
  double todayCompletionRate,
  int topStreakDays,
  String topStreakHabitName,
  int weekCompletedCount,
  int weekTargetCount,
  double weekCompletionRate,
});

