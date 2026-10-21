import '../../domain/entities/habit.dart';

/// Data Transfer Object responsible for serializing and deserializing `public.habits` records.
abstract final class HabitDto {
  /// Maps a PostgreSQL row [json] map into a domain [Habit] entity.
  static Habit fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: (json['category'] as String?) ?? 'Salud',
      icon: (json['icon'] as String?) ?? '💧',
      color: (json['color'] as String?) ?? 'indigo',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  /// Builds the JSON payload required to insert a new row into `public.habits`.
  static Map<String, dynamic> toInsertJson({
    required String userId,
    required String name,
    required String category,
    required String icon,
    required String color,
  }) {
    return {
      'user_id': userId,
      'name': name,
      'category': category,
      'icon': icon,
      'color': color,
    };
  }

  /// Builds the JSON payload required to update an existing row in `public.habits`.
  static Map<String, dynamic> toUpdateJson({
    required String name,
    required String category,
    required String icon,
    required String color,
  }) {
    return {
      'name': name,
      'category': category,
      'icon': icon,
      'color': color,
    };
  }
}
