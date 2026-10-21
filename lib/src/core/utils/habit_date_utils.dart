import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import 'week_day_info.dart';

/// Provides pure, timezone-safe date utilities for ISO `YYYY-MM-DD` formatting
/// and Monday-to-Sunday weekly calendar generation.
abstract final class HabitDateUtils {
  /// Truncates a [DateTime] to local midnight (`00:00:00`).
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Formats a [DateTime] into a canonical `YYYY-MM-DD` string.
  static String toIsoDateString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parses an ISO `YYYY-MM-DD` string into a local midnight [DateTime].
  static DateTime parseIsoDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) {
      return dateOnly(DateTime.now());
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Returns today's local date formatted as `YYYY-MM-DD`.
  static String todayIso() => toIsoDateString(DateTime.now());

  /// Computes the Monday date for the week shifted by [weekOffset] relative to [referenceDate].
  static DateTime startOfWeek({int weekOffset = 0, DateTime? referenceDate}) {
    final reference = dateOnly(referenceDate ?? DateTime.now());
    final mondayOfCurrentWeek = reference.subtract(
      Duration(days: reference.weekday - 1),
    );
    return DateTime(
      mondayOfCurrentWeek.year,
      mondayOfCurrentWeek.month,
      mondayOfCurrentWeek.day + (weekOffset * 7),
    );
  }

  /// Generates the 7 [WeekDayInfo] items from Monday to Sunday for the given [weekOffset].
  static List<WeekDayInfo> getWeekDays({
    int weekOffset = 0,
    DateTime? referenceDate,
  }) {
    final today = dateOnly(referenceDate ?? DateTime.now());
    final monday = startOfWeek(
      weekOffset: weekOffset,
      referenceDate: today,
    );

    return List<WeekDayInfo>.generate(7, (index) {
      final date = DateTime(monday.year, monday.month, monday.day + index);
      return (
        date: date,
        isoDate: toIsoDateString(date),
        shortLabel: AppConstants.weekDayShortLabels[index],
        dayNumber: date.day,
        isToday: date == today,
        isFuture: date.isAfter(today),
      );
    });
  }

  /// Formats a human-readable Spanish date range label for the week at [weekOffset].
  static String formatWeekRangeLabel({
    int weekOffset = 0,
    DateTime? referenceDate,
  }) {
    final days = getWeekDays(
      weekOffset: weekOffset,
      referenceDate: referenceDate,
    );
    final first = days.first.date;
    final last = days.last.date;

    final dayMonthFormat = DateFormat('d MMM', 'es');
    final yearFormat = DateFormat('yyyy', 'es');

    return '${dayMonthFormat.format(first)} – ${dayMonthFormat.format(last)} ${yearFormat.format(last)}';
  }
}

