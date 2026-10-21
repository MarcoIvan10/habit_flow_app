import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env_config.dart';

/// Exposes whether Supabase environment credentials are configured and active.
final isSupabaseInitializedProvider = Provider<bool>((ref) {
  return EnvConfig.isConfigured;
});

/// Provides the singleton [SupabaseClient] instance strictly to data-layer repositories.
///
/// Architectural Rule (Dependency Inversion Principle):
/// Domain and presentation layers must never watch or read this provider directly.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
