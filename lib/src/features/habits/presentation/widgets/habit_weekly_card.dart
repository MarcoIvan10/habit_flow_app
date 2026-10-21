import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/week_day_info.dart';
import '../../domain/models/habit_with_metrics.dart';
import 'day_check_button.dart';

/// Renders a compact weekly tracking card for a single [HabitWithMetrics] item.
class HabitWeeklyCard extends StatelessWidget {
  /// Creates a [HabitWeeklyCard].
  const HabitWeeklyCard({
    required this.item,
    required this.weekDays,
    required this.onToggleDay,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Habit and its associated streak metrics.
  final HabitWithMetrics item;

  /// The 7 days of the currently selected week.
  final List<WeekDayInfo> weekDays;

  /// Callback invoked with an ISO `YYYY-MM-DD` string when a day slot is tapped.
  final ValueChanged<String> onToggleDay;

  /// Callback invoked when the user selects the edit action.
  final VoidCallback onEdit;

  /// Callback invoked when the user selects the delete action.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;
    final accentColor = AppConstants.resolveHabitColor(habit.color);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    habit.icon,
                    style: const TextStyle(fontSize: 21),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.slate800
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              habit.category,
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.slate300
                                    : AppColors.slate600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'Récord: ${item.bestStreak}d',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: item.currentStreak > 0
                        ? AppColors.amber500.withValues(alpha: 0.15)
                        : (isDark ? AppColors.slate800 : AppColors.slate100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.currentStreak > 0 ? '🔥' : '⚡',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.currentStreak}d',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: item.currentStreak > 0
                              ? AppColors.amber500
                              : AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opciones de hábito',
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit();
                    } else if (action == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Editar hábito'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.rose500,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: AppColors.rose500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays.map((day) {
                final isCompleted =
                    item.completedDates.contains(day.isoDate);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: DayCheckButton(
                      day: day,
                      isCompleted: isCompleted,
                      accentColor: accentColor,
                      onTap: day.isFuture
                          ? null
                          : () => onToggleDay(day.isoDate),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

