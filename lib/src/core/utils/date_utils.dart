import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Record inmutable de Dart 3 que representa un día dentro de la semana activa.
typedef WeekDayInfo = ({
  DateTime date,
  String isoDate,
  String shortLabel,
  int dayNumber,
  bool isToday,
  bool isFuture,
});

/// Utilidades puras para manejo de fechas en zona horaria local y formato ISO `YYYY-MM-DD`.
abstract final class HabitDateUtils {
  /// Trunca un [DateTime] a medianoche local (`00:00:00`).
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Convierte un [DateTime] a cadena ISO `YYYY-MM-DD`.
  static String toIsoDateString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Parsea una cadena `YYYY-MM-DD` a [DateTime] local sin desfase UTC.
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

  /// Obtiene la cadena ISO `YYYY-MM-DD` correspondiente al día de hoy.
  static String todayIso() => toIsoDateString(DateTime.now());

  /// Calcula el lunes de la semana correspondiente al [weekOffset]
  /// (`0` = semana actual, `-1` = semana pasada, etc.).
  static DateTime startOfWeek({int weekOffset = 0, DateTime? referenceDate}) {
    final ref = dateOnly(referenceDate ?? DateTime.now());
    // En Dart: weekday 1 = Lunes, 7 = Domingo
    final mondayOfCurrentWeek = ref.subtract(Duration(days: ref.weekday - 1));
    return DateTime(
      mondayOfCurrentWeek.year,
      mondayOfCurrentWeek.month,
      mondayOfCurrentWeek.day + (weekOffset * 7),
    );
  }

  /// Devuelve los 7 días (`Lun` a `Dom`) de la semana indicada por [weekOffset].
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

  /// Formatea el rango de la semana seleccionada (ej. `13 oct - 19 oct 2026`).
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

