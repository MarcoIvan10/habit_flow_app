import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env_config.dart';

/// Indica si Supabase fue inicializado exitosamente con credenciales válidas.
final isSupabaseInitializedProvider = Provider<bool>((ref) {
  return EnvConfig.isConfigured;
});

/// Proveedor de infraestructura para el cliente de Supabase.
///
/// IMPORTANTE (Regla de Arquitectura SOLID):
/// Este provider SOLO debe ser consumido por implementaciones concretas
/// dentro de la capa `data/repositories/`. Las capas `domain` y `presentation`
/// jamás deben depender directamente de `SupabaseClient`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

