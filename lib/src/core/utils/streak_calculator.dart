import 'habit_date_utils.dart';
import 'streak_metrics.dart';

/// Deterministic engine for computing active and historical best habit streaks.
abstract final class StreakCalculator {
  /// Calculates [StreakMetrics] from a set of `YYYY-MM-DD` [completedIsoDates]
  /// relative to [referenceToday].
  static StreakMetrics calculate(
    Set<String> completedIsoDates, {
    DateTime? referenceToday,
  }) {
    if (completedIsoDates.isEmpty) {
      return (currentStreak: 0, bestStreak: 0);
    }

    final today = HabitDateUtils.dateOnly(referenceToday ?? DateTime.now());
    final currentStreak = _computeCurrentStreak(completedIsoDates, today);
    final bestStreak = _computeBestStreak(completedIsoDates);

    return (
      currentStreak: currentStreak,
      bestStreak: bestStreak,
    );
  }

  static int _computeCurrentStreak(
    Set<String> completedIsoDates,
    DateTime today,
  ) {
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final todayIso = HabitDateUtils.toIsoDateString(today);
    final yesterdayIso = HabitDateUtils.toIsoDateString(yesterday);

    DateTime? cursor;
    if (completedIsoDates.contains(todayIso)) {
      cursor = today;
    } else if (completedIsoDates.contains(yesterdayIso)) {
      cursor = yesterday;
    }

    int streak = 0;
    while (cursor != null) {
      final iso = HabitDateUtils.toIsoDateString(cursor);
      if (completedIsoDates.contains(iso)) {
        streak++;
        cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
      } else {
        break;
      }
    }
    return streak;
  }

  static int _computeBestStreak(Set<String> completedIsoDates) {
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
        runningStreak = date == expectedNext ? runningStreak + 1 : 1;
      }
      if (runningStreak > bestStreak) {
        bestStreak = runningStreak;
      }
      previousDate = date;
    }

    return bestStreak;
  }
}
