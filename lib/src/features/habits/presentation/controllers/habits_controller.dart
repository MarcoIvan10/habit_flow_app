import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/supabase_error_mapper.dart';
import '../../../../core/utils/habit_date_utils.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/models/habits_workspace_data.dart';
import '../../domain/models/toggle_action_result.dart';
import '../providers/habits_providers.dart';

/// Asynchronous state controller managing user habits and daily check-in mutations
/// with Optimistic UI updates, automatic error rollback, and in-flight concurrency locks.
class HabitsController extends AsyncNotifier<HabitsWorkspaceData> {
  final Set<String> _inFlightToggleKeys = <String>{};

  @override
  Future<HabitsWorkspaceData> build() async {
    ref.watch(authSessionProvider);
    return _fetchWorkspaceData();
  }

  /// Reloads habits and completion logs from the active [HabitRepository].
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchWorkspaceData);
  }

  /// Toggles the completion status of [habitId] on [isoDate] using Optimistic UI
  /// while preventing duplicate concurrent requests for the same key.
  Future<ToggleActionResult> toggleHabitDay({
    required String habitId,
    required String isoDate,
  }) async {
    final currentData = state.valueOrNull;
    final mutationKey = '$habitId:$isoDate';

    if (currentData == null || _inFlightToggleKeys.contains(mutationKey)) {
      return (completedAllToday: false, errorMessage: null);
    }

    _inFlightToggleKeys.add(mutationKey);

    try {
      final previousDates =
          currentData.completedDatesByHabit[habitId] ?? const <String>{};
      final shouldComplete = !previousDates.contains(isoDate);

      final optimisticState = _applyOptimisticToggle(
        currentData: currentData,
        habitId: habitId,
        isoDate: isoDate,
        shouldComplete: shouldComplete,
      );
      state = AsyncData(optimisticState);

      final completedAllToday = _didCompleteAllToday(
        workspace: optimisticState,
        toggledIsoDate: isoDate,
        shouldComplete: shouldComplete,
      );

      final repository = ref.read(habitRepositoryProvider);
      await repository.toggleHabitCompletion(
        habitId: habitId,
        isoDate: isoDate,
        shouldComplete: shouldComplete,
      );

      return (
        completedAllToday: completedAllToday,
        errorMessage: null,
      );
    } catch (error) {
      state = AsyncData(currentData);
      final appError = SupabaseErrorMapper.map(error);
      return (
        completedAllToday: false,
        errorMessage: appError.userMessage,
      );
    } finally {
      _inFlightToggleKeys.remove(mutationKey);
    }
  }

  /// Creates a new habit and appends it to the active workspace state.
  Future<String?> createHabit({
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    final currentData = state.valueOrNull;
    try {
      final repository = ref.read(habitRepositoryProvider);
      final created = await repository.createHabit(
        name: name,
        category: category,
        icon: icon,
        color: color,
      );

      if (currentData != null) {
        final nextHabits = [...currentData.habits, created];
        final nextMap = <String, Set<String>>{
          ...currentData.completedDatesByHabit,
          created.id: <String>{},
        };
        state = AsyncData(
          currentData.copyWith(
            habits: nextHabits,
            completedDatesByHabit: nextMap,
          ),
        );
      } else {
        await refresh();
      }
      return null;
    } catch (error) {
      return SupabaseErrorMapper.map(error).userMessage;
    }
  }

  /// Updates an existing habit identified by [habitId] in the repository and local workspace.
  Future<String?> updateHabit({
    required String habitId,
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    final currentData = state.valueOrNull;
    try {
      final repository = ref.read(habitRepositoryProvider);
      final updated = await repository.updateHabit(
        habitId: habitId,
        name: name,
        category: category,
        icon: icon,
        color: color,
      );

      if (currentData != null) {
        final nextHabits = currentData.habits
            .map((h) => h.id == habitId ? updated : h)
            .toList(growable: false);
        state = AsyncData(currentData.copyWith(habits: nextHabits));
      } else {
        await refresh();
      }
      return null;
    } catch (error) {
      return SupabaseErrorMapper.map(error).userMessage;
    }
  }

  /// Deletes [habitId] optimistically and rolls back if the repository call fails.
  Future<String?> deleteHabit(String habitId) async {
    final currentData = state.valueOrNull;
    if (currentData == null) {
      return null;
    }

    final nextHabits = currentData.habits
        .where((h) => h.id != habitId)
        .toList(growable: false);
    final nextMap = Map<String, Set<String>>.from(
      currentData.completedDatesByHabit,
    )..remove(habitId);

    state = AsyncData(
      currentData.copyWith(
        habits: nextHabits,
        completedDatesByHabit: nextMap,
      ),
    );

    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.deleteHabit(habitId);
      return null;
    } catch (error) {
      state = AsyncData(currentData);
      return SupabaseErrorMapper.map(error).userMessage;
    }
  }

  Future<HabitsWorkspaceData> _fetchWorkspaceData() async {
    final repository = ref.read(habitRepositoryProvider);
    final results = await Future.wait<Object>([
      repository.fetchHabits(),
      repository.fetchHabitLogs(),
    ]);

    final habits = results[0] as List<Habit>;
    final logs = results[1] as List<HabitLog>;

    final completedMap = <String, Set<String>>{
      for (final habit in habits) habit.id: <String>{},
    };

    for (final log in logs) {
      completedMap
          .putIfAbsent(log.habitId, () => <String>{})
          .add(log.completedDate);
    }

    return HabitsWorkspaceData(
      habits: habits,
      completedDatesByHabit: completedMap,
    );
  }

  HabitsWorkspaceData _applyOptimisticToggle({
    required HabitsWorkspaceData currentData,
    required String habitId,
    required String isoDate,
    required bool shouldComplete,
  }) {
    final updatedMap = <String, Set<String>>{
      for (final entry in currentData.completedDatesByHabit.entries)
        entry.key: Set<String>.from(entry.value),
    };
    final targetSet = updatedMap.putIfAbsent(habitId, () => <String>{});
    if (shouldComplete) {
      targetSet.add(isoDate);
    } else {
      targetSet.remove(isoDate);
    }
    return currentData.copyWith(completedDatesByHabit: updatedMap);
  }

  bool _didCompleteAllToday({
    required HabitsWorkspaceData workspace,
    required String toggledIsoDate,
    required bool shouldComplete,
  }) {
    final todayIso = HabitDateUtils.todayIso();
    return shouldComplete &&
        toggledIsoDate == todayIso &&
        workspace.habits.isNotEmpty &&
        workspace.habits.every(
          (h) =>
              workspace.completedDatesByHabit[h.id]?.contains(todayIso) ??
              false,
        );
  }
}

