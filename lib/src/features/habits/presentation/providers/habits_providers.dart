import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/supabase_error_mapper.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/local_demo_habit_repository.dart';
import '../../data/repositories/supabase_habit_repository.dart';
import '../../domain/models/dashboard_filter_state.dart';
import '../../domain/models/habits_workspace_data.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/states/dashboard_ui_state.dart';
import '../../domain/usecases/build_dashboard_ui_state_use_case.dart';
import '../controllers/dashboard_filter_notifier.dart';
import '../controllers/habits_controller.dart';

/// Dependency injection provider for [HabitRepository].
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final isConfigured = ref.watch(isSupabaseInitializedProvider);
  if (isConfigured) {
    final client = ref.watch(supabaseClientProvider);
    return SupabaseHabitRepository(client);
  }
  return LocalDemoHabitRepository();
});

/// Provider managing the active [DashboardFilterState].
final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilterState>(
  DashboardFilterNotifier.new,
);

/// Provider managing the asynchronous [HabitsWorkspaceData] and habit mutations.
final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, HabitsWorkspaceData>(
  HabitsController.new,
);

/// Derived provider that computes the sealed [DashboardUiState] using [BuildDashboardUiStateUseCase].
final dashboardUiStateProvider = Provider<DashboardUiState>((ref) {
  final asyncWorkspace = ref.watch(habitsControllerProvider);
  final filter = ref.watch(dashboardFilterProvider);

  return switch (asyncWorkspace) {
    AsyncData(:final value) => BuildDashboardUiStateUseCase.execute(
        workspace: value,
        filter: filter,
      ),
    AsyncError(:final error) => DashboardUiError(
        SupabaseErrorMapper.map(error).userMessage,
      ),
    _ => const DashboardUiLoading(),
  };
});
