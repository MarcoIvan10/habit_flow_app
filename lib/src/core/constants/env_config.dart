import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves environment configuration variables for Supabase connectivity.
///
/// Prioritizes compile-time `--dart-define` values and falls back to `.env`
/// loaded via `flutter_dotenv`. Never stores hardcoded credentials in source code.
abstract final class EnvConfig {
  static const String _defineSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const String _defineSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const String _defineSupabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Loads environment variables from the `.env` file when available.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (error) {
      debugPrint('EnvConfig.init fallback to compile-time defines: $error');
    }
  }

  /// Returns the configured Supabase project URL, or an empty string if unset.
  static String get supabaseUrl {
    if (_defineSupabaseUrl.trim().isNotEmpty) {
      return _defineSupabaseUrl.trim();
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return (dotenv.maybeGet('SUPABASE_URL') ?? '').trim();
  }

  /// Returns the configured Supabase public anonymous/publishable key, or an empty string if unset.
  static String get supabaseAnonKey {
    if (_defineSupabasePublishableKey.trim().isNotEmpty) {
      return _defineSupabasePublishableKey.trim();
    }
    if (_defineSupabaseAnonKey.trim().isNotEmpty) {
      return _defineSupabaseAnonKey.trim();
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    final fromEnv = dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY') ??
        dotenv.maybeGet('SUPABASE_ANON_KEY') ??
        '';
    return fromEnv.trim();
  }

  /// Evaluates whether valid, non-placeholder Supabase credentials are present.
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) {
      return false;
    }
    if (url.contains('tu-proyecto.supabase.co') ||
        key.contains('tu-anon-key')) {
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
  }
}
