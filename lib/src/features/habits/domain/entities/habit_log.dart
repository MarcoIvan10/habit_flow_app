/// Immutable domain entity representing a single daily check-in log for a habit.
final class HabitLog {
  /// Creates a [HabitLog] instance.
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedDate,
    required this.createdAt,
  });

  /// Unique UUID identifier of the log entry.
  final String id;

  /// Identifier of the associated [Habit].
  final String habitId;

  /// Identifier of the user who owns this log entry.
  final String userId;

  /// Completed calendar date in canonical ISO `YYYY-MM-DD` format.
  final String completedDate;

  /// Creation timestamp of the log entry.
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          userId == other.userId &&
          completedDate == other.completedDate;

  @override
  int get hashCode => Object.hash(id, habitId, userId, completedDate);
}
