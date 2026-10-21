import 'package:flutter/material.dart';

import '../../../../core/utils/week_day_info.dart';
import '../../domain/entities/habit.dart';
import '../../domain/models/habit_with_metrics.dart';
import 'empty_habits_card.dart';
import 'habit_weekly_card.dart';

/// Renders the vertical list of [HabitWeeklyCard] items or an [EmptyHabitsCard] when empty.
class HabitMatrixWidget extends StatelessWidget {
  /// Creates a [HabitMatrixWidget].
  const HabitMatrixWidget({
    required this.habits,
    required this.weekDays,
    required this.isFilteredEmpty,
    required this.onToggleDay,
    required this.onEditHabit,
    required this.onDeleteHabit,
    required this.onCreateFirstHabit,
    required this.onClearCategoryFilter,
    super.key,
  });

  /// Filtered list of habits paired with their streak metrics.
  final List<HabitWithMetrics> habits;

  /// The 7 days of the active week.
  final List<WeekDayInfo> weekDays;

  /// Whether the list is empty only because of the current category filter.
  final bool isFilteredEmpty;

  /// Callback invoked when a day button is toggled for a habit.
  final void Function(String habitId, String isoDate) onToggleDay;

  /// Callback invoked when the user requests to edit a [Habit].
  final ValueChanged<Habit> onEditHabit;

  /// Callback invoked when the user requests to delete a [Habit].
  final ValueChanged<Habit> onDeleteHabit;

  /// Callback invoked when the user taps the empty-state button to create their first habit.
  final VoidCallback onCreateFirstHabit;

  /// Callback invoked when the user clears the active category filter.
  final VoidCallback onClearCategoryFilter;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return EmptyHabitsCard(
        isFilteredEmpty: isFilteredEmpty,
        onPrimaryAction:
            isFilteredEmpty ? onClearCategoryFilter : onCreateFirstHabit,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: habits
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitWeeklyCard(
                item: item,
                weekDays: weekDays,
                onToggleDay: (isoDate) => onToggleDay(item.habit.id, isoDate),
                onEdit: () => onEditHabit(item.habit),
                onDelete: () => onDeleteHabit(item.habit),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
