import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Selector de semana activa y barra de filtros por categoría.
class WeekNavigatorWidget extends StatelessWidget {
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

  final String weekRangeLabel;
  final int weekOffset;
  final String selectedCategory;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onResetToday;
  final ValueChanged<String> onCategorySelected;

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
                        weekOffset == 0
                            ? 'Esta Semana'
                            : weekOffset == -1
                                ? 'Semana Pasada'
                                : 'Hace ${weekOffset.abs()} semanas',
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

