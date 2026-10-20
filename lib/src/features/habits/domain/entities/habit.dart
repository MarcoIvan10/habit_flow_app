/// Entidad inmutable de dominio que representa un hábito configurado por el usuario.
final class Habit {
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String category;
  final String icon;
  final String color;
  final DateTime createdAt;

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          name == other.name &&
          category == other.category &&
          icon == other.icon &&
          color == other.color;

  @override
  int get hashCode => Object.hash(id, userId, name, category, icon, color);
}

