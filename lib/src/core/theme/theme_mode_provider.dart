import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier moderno (Riverpod 2.x) para controlar y persistir el modo de tema (Claro / Oscuro / Sistema).
///
/// Diseñado para arranque instantáneo (0ms) sin bloquear la ejecución inicial de `runApp()`.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _storageKey = 'habitflow_theme_mode';

  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.system;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        state = switch (saved) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
      }
    } catch (_) {
      // Si el canal de SharedPreferences aún no está disponible, se mantiene ThemeMode.system
    }
  }

  Future<void> toggleTheme(Brightness currentBrightness) async {
    final nextMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_storageKey, value);
    } catch (_) {
      // Ignorar fallas de persistencia para no bloquear la UI
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
