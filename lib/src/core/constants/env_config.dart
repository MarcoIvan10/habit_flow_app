import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración segura de variables de entorno con fallbacks resilientes.
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

  // Valores predeterminados inyectados del proyecto del usuario
  static const String _fallbackUrl = 'https://hplqsbkpagrantwjragx.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwbHFzYmtwYWdyYW50d2pyYWd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1MDkxNTEsImV4cCI6MjEwODA4NTE1MX0.5vQykgLGGtqEFlEL7VkL9CSx0fKCoL1PFmYsrEqTTNk';

  /// Inicializa la lectura del archivo `.env` de forma protegida.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Aviso: .env no cargado como asset, usando configuración compilada.');
    }
  }

  /// URL del proyecto de Supabase.
  static String get supabaseUrl {
    if (_defineSupabaseUrl.trim().isNotEmpty) {
      return _defineSupabaseUrl.trim();
    }
    if (dotenv.isInitialized) {
      final envVal = (dotenv.maybeGet('SUPABASE_URL') ?? '').trim();
      if (envVal.isNotEmpty && !envVal.contains('tu-proyecto')) {
        return envVal;
      }
    }
    return _fallbackUrl;
  }

  /// Clave pública (Publishable / Anon Key) de Supabase.
  static String get supabaseAnonKey {
    if (_defineSupabasePublishableKey.trim().isNotEmpty) {
      return _defineSupabasePublishableKey.trim();
    }
    if (_defineSupabaseAnonKey.trim().isNotEmpty) {
      return _defineSupabaseAnonKey.trim();
    }
    if (dotenv.isInitialized) {
      final fromEnv = (dotenv.maybeGet('SUPABASE_PUBLISHABLE_KEY') ??
              dotenv.maybeGet('SUPABASE_ANON_KEY') ??
              '')
          .trim();
      if (fromEnv.isNotEmpty && !fromEnv.contains('tu-anon-key')) {
        return fromEnv;
      }
    }
    return _fallbackAnonKey;
  }

  /// Verifica que las credenciales estén configuradas y tengan formato válido.
  static bool get isConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
  }
}
