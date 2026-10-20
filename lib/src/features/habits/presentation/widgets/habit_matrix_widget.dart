import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/habit.dart';
import '../../domain/models/dashboard_models.dart';

/// Lista de tarjetas compactas de seguimiento semanal de hábitos (Sección 5.4).
class HabitMatrixWidget extends StatelessWidget {
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

  final List<HabitWithMetrics> habits;
  final List<WeekDayInfo> weekDays;
  final bool isFilteredEmpty;
  final void Function(String habitId, String isoDate) onToggleDay;
  final ValueChanged<Habit> onEditHabit;
  final ValueChanged<Habit> onDeleteHabit;
  final VoidCallback onCreateFirstHabit;
  final VoidCallback onClearCategoryFilter;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return _EmptyHabitsCard(
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
              child: _HabitWeeklyCard(
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

class _HabitWeeklyCard extends StatelessWidget {
  const _HabitWeeklyCard({
    required this.item,
    required this.weekDays,
    required this.onToggleDay,
    required this.onEdit,
    required this.onDelete,
  });

  final HabitWithMetrics item;
  final List<WeekDayInfo> weekDays;
  final ValueChanged<String> onToggleDay;
  final VoidCallback onEdit;
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
            // Cabecera de la tarjeta
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
                // Insignia de racha activa
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
            // Fila interactiva de 7 días (Lun a Dom)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays.map((day) {
                final isCompleted =
                    item.completedDates.contains(day.isoDate);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: _DayCheckButton(
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

class _DayCheckButton extends StatelessWidget {
  const _DayCheckButton({
    required this.day,
    required this.isCompleted,
    required this.accentColor,
    required this.onTap,
  });

  final WeekDayInfo day;
  final bool isCompleted;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isCompleted
        ? accentColor
        : day.isFuture
            ? (isDark
                ? AppColors.slate900
                : AppColors.slate100.withValues(alpha: 0.6))
            : (isDark ? AppColors.slate800 : AppColors.slate100);

    final borderColor = isCompleted
        ? accentColor
        : day.isToday
            ? AppColors.indigo500
            : Colors.transparent;

    return Semantics(
      button: true,
      checked: isCompleted,
      label: '${day.shortLabel} ${day.dayNumber}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: day.isToday && !isCompleted ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                day.shortLabel,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight:
                      day.isToday ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted
                      ? Colors.white.withValues(alpha: 0.92)
                      : day.isToday
                          ? AppColors.indigo500
                          : AppColors.slate400,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey('checked'),
                        size: 17,
                        color: Colors.white,
                      )
                    : Text(
                        '${day.dayNumber}',
                        key: const ValueKey('unchecked'),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: day.isFuture
                              ? AppColors.slate400.withValues(alpha: 0.45)
                              : (isDark
                                  ? AppColors.slate300
                                  : AppColors.slate700),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHabitsCard extends StatelessWidget {
  const _EmptyHabitsCard({
    required this.isFilteredEmpty,
    required this.onPrimaryAction,
  });

  final bool isFilteredEmpty;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.indigo500.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFilteredEmpty
                    ? Icons.filter_alt_off_rounded
                    : Icons.auto_awesome_rounded,
                color: AppColors.indigo500,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFilteredEmpty
                  ? 'No hay hábitos en esta categoría'
                  : 'Comienza tu primer hábito hoy',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFilteredEmpty
                  ? 'Prueba seleccionando otra categoría o muestra todos tus hábitos.'
                  : 'Crea hábitos personalizados, registra tu avance diario y construye rachas duraderas.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(
                isFilteredEmpty ? Icons.clear_all_rounded : Icons.add_rounded,
              ),
              label: Text(
                isFilteredEmpty
                    ? 'Ver todas las categorías'
                    : 'Crear mi primer hábito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

