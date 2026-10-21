/// Immutable domain entity representing a user-configured habit.
final class Habit {
  /// Creates a [Habit] instance.
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  /// Unique UUID identifier of the habit.
  final String id;

  /// Owner user UUID identifier.
  final String userId;

  /// Display name of the habit.
  final String name;

  /// Category classification of the habit.
  final String category;

  /// Emoji icon representing the habit.
  final String icon;

  /// Accent color key associated with the habit.
  final String color;

  /// Creation timestamp of the habit.
  final DateTime createdAt;

  /// Returns a copy of this [Habit] with the specified fields updated.
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
