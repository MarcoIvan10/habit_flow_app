import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the active [ThemeMode] and persists user preference asynchronously
/// without blocking initial application startup.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _storageKey = 'habitflow_theme_mode';

  @override
  ThemeMode build() {
    _restorePersistedTheme();
    return ThemeMode.system;
  }

  /// Toggles between [ThemeMode.light] and [ThemeMode.dark] based on [currentBrightness].
  Future<void> toggleTheme(Brightness currentBrightness) async {
    final nextMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  /// Sets and persists the selected [mode] in local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_storageKey, serialized);
    } catch (_) {
      return;
    }
  }

  Future<void> _restorePersistedTheme() async {
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
      return;
    }
  }
}

/// Provides reactive access to [ThemeModeNotifier] and the current [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
