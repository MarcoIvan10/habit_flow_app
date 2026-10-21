import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/week_day_info.dart';

/// Interactive button representing a single day check-in slot inside a weekly habit card.
class DayCheckButton extends StatelessWidget {
  /// Creates a [DayCheckButton].
  const DayCheckButton({
    required this.day,
    required this.isCompleted,
    required this.accentColor,
    required this.onTap,
    super.key,
  });

  /// Calendar metadata for the represented weekday.
  final WeekDayInfo day;

  /// Whether the habit was completed on this day.
  final bool isCompleted;

  /// Accent color applied when [isCompleted] is `true`.
  final Color accentColor;

  /// Callback invoked when the button is tapped, or `null` if the date is in the future.
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

