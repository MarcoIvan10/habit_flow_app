import 'package:flutter/material.dart';

/// Provides application-wide domain constants, allowed catalog values,
/// validation thresholds, and accent color resolution.
abstract final class AppConstants {
  /// The display name of the application.
  static const String appName = 'HabitFlow';

  /// The subtitle tagline displayed on the authentication header.
  static const String appTagline =
      'Construye hábitos consistentes, un día a la vez';

  /// Allowed habit category names enforced across UI and database constraints.
  static const List<String> categories = [
    'Salud',
    'Deporte',
    'Mente',
    'Productividad',
    'Finanzas',
  ];

  /// Curated emoji icons selectable when creating or editing a habit.
  static const List<String> habitIcons = [
    '💧',
    '🏋️',
    '📚',
    '🧘',
    '🥗',
    '💻',
    '🏃',
    '💤',
    '🎸',
    '💰',
    '🧠',
    '🍵',
  ];

  /// Supported accent color keys persisted in the database.
  static const List<String> accentColorKeys = [
    'indigo',
    'emerald',
    'amber',
    'rose',
    'cyan',
    'purple',
  ];

  /// Abbreviated Spanish weekday labels ordered from Monday (index 0) to Sunday (index 6).
  static const List<String> weekDayShortLabels = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  /// Maximum allowed character length for a habit name.
  static const int maxHabitNameLength = 60;

  /// Minimum required character length for user passwords.
  static const int minPasswordLength = 8;

  /// Maximum number of habit log entries fetched per synchronization request.
  static const int maxHabitLogsFetchLimit = 2000;

  /// Maps a persisted [colorKey] identifier to its corresponding Material [Color].
  static Color resolveHabitColor(String colorKey) {
    return switch (colorKey.toLowerCase()) {
      'emerald' => const Color(0xFF10B981),
      'amber' => const Color(0xFFF59E0B),
      'rose' => const Color(0xFFF43F5E),
      'cyan' => const Color(0xFF06B6D4),
      'purple' => const Color(0xFFA855F7),
      _ => const Color(0xFF6366F1),
    };
  }
}
