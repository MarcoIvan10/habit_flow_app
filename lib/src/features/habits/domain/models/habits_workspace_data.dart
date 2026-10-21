import '../entities/habit.dart';

/// Immutable container holding the synchronized list of user [habits] and their completed ISO dates.
final class HabitsWorkspaceData {
  /// Creates a [HabitsWorkspaceData] instance.
  const HabitsWorkspaceData({
    required this.habits,
    required this.completedDatesByHabit,
  });

  /// Ordered list of active user habits.
  final List<Habit> habits;

  /// Map associating each `habit.id` with its set of completed `YYYY-MM-DD` date strings.
  final Map<String, Set<String>> completedDatesByHabit;

  /// Returns a copy of this [HabitsWorkspaceData] with the specified fields updated.
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

