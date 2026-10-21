import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/local_demo_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/states/auth_session_state.dart';
import '../../domain/states/auth_submission_state.dart';
import '../controllers/auth_session_notifier.dart';
import '../controllers/auth_submission_controller.dart';

/// Dependency injection provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final isConfigured = ref.watch(isSupabaseInitializedProvider);
  if (isConfigured) {
    final client = ref.watch(supabaseClientProvider);
    return SupabaseAuthRepository(client);
  }
  return LocalDemoAuthRepository();
});

/// Global provider for observing and mutating the active [AuthSessionState].
final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);

/// Provider for managing the authentication form [AuthSubmissionState].
final authSubmissionProvider =
    NotifierProvider<AuthSubmissionController, AuthSubmissionState>(
  AuthSubmissionController.new,
);
