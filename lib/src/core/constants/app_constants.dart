import 'package:flutter/material.dart';

/// Catálogo de constantes de negocio y opciones predeterminadas de HabitFlow.
abstract final class AppConstants {
  static const String appName = 'HabitFlow';
  static const String appTagline =
      'Construye hábitos consistentes, un día a la vez';

  /// Categorías disponibles para clasificar hábitos.
  static const List<String> categories = [
    'Salud',
    'Deporte',
    'Mente',
    'Productividad',
    'Finanzas',
  ];

  /// Emojis curados para representar hábitos.
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

  /// Nombres de colores de acento soportados en base de datos.
  static const List<String> accentColorKeys = [
    'indigo',
    'emerald',
    'amber',
    'rose',
    'cyan',
    'purple',
  ];

  /// Etiquetas cortas de los días de la semana (Lunes = 1 .. Domingo = 7).
  static const List<String> weekDayShortLabels = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  /// Límites de validación para proteger la integridad de datos.
  static const int maxHabitNameLength = 60;
  static const int minPasswordLength = 8;

  /// Resuelve la clave de color persistida en Supabase hacia un [Color] de UI.
  static Color resolveHabitColor(String colorKey) {
    return switch (colorKey.toLowerCase()) {
      'emerald' => const Color(0xFF10B981),
      'amber' => const Color(0xFFF59E0B),
      'rose' => const Color(0xFFF43F5E),
      'cyan' => const Color(0xFF06B6D4),
      'purple' => const Color(0xFFA855F7),
      _ => const Color(0xFF6366F1), // indigo por defecto
    };
  }
}

