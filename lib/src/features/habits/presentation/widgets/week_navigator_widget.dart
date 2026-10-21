import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Provides week navigation controls and horizontal category filter chips.
class WeekNavigatorWidget extends StatelessWidget {
  /// Creates a [WeekNavigatorWidget].
  const WeekNavigatorWidget({
    required this.weekRangeLabel,
    required this.weekOffset,
    required this.selectedCategory,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onResetToday,
    required this.onCategorySelected,
    super.key,
  });

  /// Formatted date range label for the selected week.
  final String weekRangeLabel;

  /// Relative week offset (`0` for current week, negative for past weeks).
  final int weekOffset;

  /// Currently selected category filter name.
  final String selectedCategory;

  /// Callback triggered when navigating to the previous week.
  final VoidCallback onPreviousWeek;

  /// Callback triggered when navigating to the next week.
  final VoidCallback onNextWeek;

  /// Callback triggered when resetting directly to the current week.
  final VoidCallback onResetToday;

  /// Callback triggered when selecting a category chip.
  final ValueChanged<String> onCategorySelected;

  String _resolveWeekTitle() {
    if (weekOffset == 0) {
      return 'Esta Semana';
    }
    if (weekOffset == -1) {
      return 'Semana Pasada';
    }
    return 'Hace ${weekOffset.abs()} semanas';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCategories = ['Todas', ...AppConstants.categories];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Semana anterior',
                  onPressed: onPreviousWeek,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _resolveWeekTitle(),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.indigo500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weekRangeLabel,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (weekOffset != 0)
                  TextButton.icon(
                    onPressed: onResetToday,
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text('Hoy'),
                  ),
                IconButton(
                  tooltip: 'Semana siguiente',
                  onPressed: weekOffset < 0 ? onNextWeek : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: allCategories.map((category) {
              final isSelected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.indigo600,
                  backgroundColor:
                      isDark ? AppColors.slate900 : Colors.white,
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.slate300 : AppColors.slate700),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.indigo600
                        : (isDark ? AppColors.slate800 : AppColors.slate200),
                  ),
                  onSelected: (_) => onCategorySelected(category),
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}
