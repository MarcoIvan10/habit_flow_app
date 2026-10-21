import '../../domain/entities/habit_log.dart';

/// Data Transfer Object responsible for serializing and deserializing `public.habit_logs` records.
abstract final class HabitLogDto {
  /// Maps a PostgreSQL row [json] map into a domain [HabitLog] entity.
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

  /// Builds the JSON payload required to insert or upsert a row in `public.habit_logs`.
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
