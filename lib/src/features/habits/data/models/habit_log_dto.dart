import '../../domain/entities/habit_log.dart';

/// DTO (Data Transfer Object) encargado de serializar/deserializar la tabla `public.habit_logs`
/// de Supabase PostgreSQL hacia la entidad de dominio [HabitLog].
abstract final class HabitLogDto {
  static HabitLog fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completedDate: json['completed_date'] as String,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> toInsertJson({
    required String habitId,
    required String userId,
    required String completedDate,
  }) {
    return {
      'habit_id': habitId,
      'user_id': userId,
      'completed_date': completedDate,
    };
  }
}

