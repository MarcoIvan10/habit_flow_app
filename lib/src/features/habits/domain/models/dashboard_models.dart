import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';

/// Record de Dart 3 que combina un [Habit] con sus fechas completadas y métricas de racha.
typedef HabitWithMetrics = ({
  Habit habit,
  Set<String> completedDates,
  int currentStreak,
  int bestStreak,
  bool isCompletedToday,
});

/// Record de Dart 3 para las 4 tarjetas KPI superiores del Dashboard.
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

/// Record de Dart 3 para cada barra diaria en el gráfico semanal (`fl_chart`).
typedef DailyProgressPoint = ({
  String shortLabel,
  String isoDate,
  int completedCount,
  int totalHabits,
  double percentage,
  bool isToday,
});

/// Filtro de visualización del Dashboard (`Todas` o una categoría específica).
typedef DashboardFilterState = ({
  int weekOffset,
  String selectedCategory,
});

/// Contenedor inmutable de los datos sincronizados de hábitos y registros.
final class HabitsWorkspaceData {
  const HabitsWorkspaceData({
    required this.habits,
    required this.completedDatesByHabit,
  });

  final List<Habit> habits;
  final Map<String, Set<String>> completedDatesByHabit;

  HabitsWorkspaceData copyWith({
    List<Habit>? habits,
    Map<String, Set<String>>? completedDatesByHabit,
  }) {
    return HabitsWorkspaceData(
      habits: habits ?? this.habits,
      completedDatesByHabit:
          completedDatesByHabit ?? this.completedDatesByHabit,
    );
  }
}

/// Jerarquía sellada (Dart 3 Sealed Class) para modelar el estado completo de la UI
/// del Dashboard con pattern matching exhaustivo (sin booleanos dispersos).
sealed class DashboardUiState {
  const DashboardUiState();
}

final class DashboardUiLoading extends DashboardUiState {
  const DashboardUiLoading();
}

final class DashboardUiError extends DashboardUiState {
  const DashboardUiError(this.message);
  final String message;
}

final class DashboardUiReady extends DashboardUiState {
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

  final List<HabitWithMetrics> allHabits;
  final List<HabitWithMetrics> filteredHabits;
  final List<WeekDayInfo> weekDays;
  final String weekRangeLabel;
  final int weekOffset;
  final String selectedCategory;
  final DashboardKpiSummary kpiSummary;
  final List<DailyProgressPoint> dailyProgressPoints;

  bool get isEmptyWorkspace => allHabits.isEmpty;
  bool get isFilteredEmpty => allHabits.isNotEmpty && filteredHabits.isEmpty;
}

