import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/constants/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formato de fechas en español
  try {
    await initializeDateFormatting('es');
  } catch (e) {
    debugPrint('Aviso: initializeDateFormatting: $e');
  }

  // Cargar variables de entorno si existen
  try {
    await EnvConfig.init();
  } catch (e) {
    debugPrint('Aviso: EnvConfig.init: $e');
  }

  // Inicializar Supabase de forma protegida
  if (EnvConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        publishableKey: EnvConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Aviso: Supabase.initialize: $e');
    }
  }

  // runApp se invoca SIEMPRE de forma garantizada
  runApp(
    const ProviderScope(
      child: HabitFlowApp(),
    ),
  );
}
