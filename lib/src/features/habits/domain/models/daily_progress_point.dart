/// Immutable Dart 3 Record representing a single day's completion bar in the weekly progress chart.
typedef DailyProgressPoint = ({
  String shortLabel,
  String isoDate,
  int completedCount,
  int totalHabits,
  double percentage,
  bool isToday,
});

