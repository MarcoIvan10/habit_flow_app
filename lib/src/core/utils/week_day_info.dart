/// Immutable Dart 3 Record representing a single calendar day within an active Monday-to-Sunday week.
typedef WeekDayInfo = ({
  DateTime date,
  String isoDate,
  String shortLabel,
  int dayNumber,
  bool isToday,
  bool isFuture,
});

