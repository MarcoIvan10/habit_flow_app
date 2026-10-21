import '../entities/habit.dart';
import '../entities/habit_log.dart';

/// Abstract repository contract for habit CRUD operations and daily check-in synchronization.
abstract interface class HabitRepository {
  /// Fetches all habits belonging to the authenticated user ordered by creation timestamp.
  Future<List<Habit>> fetchHabits();

  /// Fetches daily completion log entries belonging to the authenticated user.
  Future<List<HabitLog>> fetchHabitLogs();

  /// Creates and persists a new habit with the provided attributes.
  Future<Habit> createHabit({
    required String name,
    required String category,
    required String icon,
    required String color,
  });

  /// Updates an existing habit identified by [habitId].
  Future<Habit> updateHabit({
    required String habitId,
    required String name,
    required String category,
    required String icon,
    required String color,
  });

  /// Deletes the habit identified by [habitId] along with its associated logs.
  Future<void> deleteHabit(String habitId);

  /// Toggles the completion state of [habitId] on [isoDate] according to [shouldComplete].
  Future<bool> toggleHabitCompletion({
    required String habitId,
    required String isoDate,
    required bool shouldComplete,
  });
}
