import '../entities/habit.dart';

/// Immutable Dart 3 Record pairing a [Habit] entity with its completed dates and computed streak metrics.
typedef HabitWithMetrics = ({
  Habit habit,
  Set<String> completedDates,
  int currentStreak,
  int bestStreak,
  bool isCompletedToday,
});

