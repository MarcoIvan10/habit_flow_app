/// Entidad inmutable de dominio que representa el registro diario (check-in) de un hábito.
final class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedDate,
    required this.createdAt,
  });

  final String id;
  final String habitId;
  final String userId;

  /// Fecha completada en formato ISO `YYYY-MM-DD`.
  final String completedDate;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          userId == other.userId &&
          completedDate == other.completedDate;

  @override
  int get hashCode => Object.hash(id, habitId, userId, completedDate);
}

