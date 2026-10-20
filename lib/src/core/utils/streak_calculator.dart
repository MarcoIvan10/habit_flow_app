import 'date_utils.dart';

/// Record de Dart 3 que encapsula las métricas de racha de un hábito.
typedef StreakMetrics = ({
  int currentStreak,
  int bestStreak,
});

/// Motor determinista de cálculo de rachas diarias (`currentStreak` y `bestStreak`).
abstract final class StreakCalculator {
  /// Calcula la racha vigente y la mejor racha histórica a partir de un conjunto
  /// de fechas completadas en formato `YYYY-MM-DD`.
  static StreakMetrics calculate(
    Set<String> completedIsoDates, {
    DateTime? referenceToday,
  }) {
    if (completedIsoDates.isEmpty) {
      return (currentStreak: 0, bestStreak: 0);
    }

    final today = HabitDateUtils.dateOnly(referenceToday ?? DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    final todayIso = HabitDateUtils.toIsoDateString(today);
    final yesterdayIso = HabitDateUtils.toIsoDateString(yesterday);

    // 1. Cálculo de Racha Actual (currentStreak)
    // Si está completado hoy, contamos hacia atrás desde hoy.
    // Si no está completado hoy pero sí ayer, la racha sigue viva y contamos desde ayer.
    int currentStreak = 0;
    DateTime? cursor;

    if (completedIsoDates.contains(todayIso)) {
      cursor = today;
    } else if (completedIsoDates.contains(yesterdayIso)) {
      cursor = yesterday;
    }

    while (cursor != null) {
      final iso = HabitDateUtils.toIsoDateString(cursor);
      if (completedIsoDates.contains(iso)) {
        currentStreak++;
        cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
      } else {
        break;
      }
    }

    // 2. Cálculo de Mejor Racha Histórica (bestStreak)
    final sortedDates = completedIsoDates
        .map(HabitDateUtils.parseIsoDate)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int bestStreak = 0;
    int runningStreak = 0;
    DateTime? previousDate;

    for (final date in sortedDates) {
      if (previousDate == null) {
        runningStreak = 1;
      } else {
        final expectedNext = DateTime(
          previousDate.year,
          previousDate.month,
          previousDate.day + 1,
        );
        if (date == expectedNext) {
          runningStreak++;
        } else {
          runningStreak = 1;
        }
      }
      if (runningStreak > bestStreak) {
        bestStreak = runningStreak;
      }
      previousDate = date;
    }

    return (
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }
}

