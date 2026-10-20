import '../../domain/entities/habit.dart';

/// DTO (Data Transfer Object) encargado de serializar/deserializar la tabla `public.habits`
/// de Supabase PostgreSQL hacia la entidad de dominio [Habit].
abstract final class HabitDto {
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

