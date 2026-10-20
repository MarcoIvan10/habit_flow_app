import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/local_demo_habit_repository.dart';
import '../../data/repositories/supabase_habit_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/models/dashboard_models.dart';
import '../../domain/repositories/habit_repository.dart';

/// Inyección de dependencias para [HabitRepository] respetando SOLID (DIP).
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final isConfigured = ref.watch(isSupabaseInitializedProvider);
  if (isConfigured) {
    final client = ref.watch(supabaseClientProvider);
    return SupabaseHabitRepository(client);
  }
  return LocalDemoHabitRepository();
});

/// Notifier para el filtro de semana (`weekOffset`) y categoría activa (`selectedCategory`).
class DashboardFilterNotifier extends Notifier<DashboardFilterState> {
  @override
  DashboardFilterState build() => (
        weekOffset: 0,
        selectedCategory: 'Todas',
      );

  void previousWeek() {
    state = (
      weekOffset: state.weekOffset - 1,
      selectedCategory: state.selectedCategory,
    );
  }

  void nextWeek() {
    if (state.weekOffset >= 0) return;
    state = (
      weekOffset: state.weekOffset + 1,
      selectedCategory: state.selectedCategory,
    );
  }

  void resetToCurrentWeek() {
    state = (
      weekOffset: 0,
      selectedCategory: state.selectedCategory,
    );
  }

  void selectCategory(String category) {
    state = (
      weekOffset: state.weekOffset,
      selectedCategory: category,
    );
  }
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilterState>(
  DashboardFilterNotifier.new,
);

/// Resultado de alternar un día (Record de Dart 3).
typedef ToggleActionResult = ({
  bool completedAllToday,
  String? errorMessage,
});

/// Controlador asíncrono (Riverpod 2.x `AsyncNotifier`) con soporte de Optimistic UI.
class HabitsController extends AsyncNotifier<HabitsWorkspaceData> {
  @override
  Future<HabitsWorkspaceData> build() async {
    // Escuchar la sesión para recargar cuando cambie el usuario autenticado
    ref.watch(authSessionProvider);
    return _fetchWorkspaceData();
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

  /// Recarga manualmente los hábitos y registros desde el repositorio.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchWorkspaceData);
  }

  /// Alterna el estado completado de un hábito en [isoDate] aplicando Optimistic UI:
  /// actualiza primero la interfaz y revierte automáticamente si falla la petición.
  Future<ToggleActionResult> toggleHabitDay({
    required String habitId,
    required String isoDate,
  }) async {
    final currentData = state.valueOrNull;
    if (currentData == null) {
      return (completedAllToday: false, errorMessage: null);
    }

    final previousDates =
        currentData.completedDatesByHabit[habitId] ?? const <String>{};
    final shouldComplete = !previousDates.contains(isoDate);

    // 1. Clonado profundo inmutable para actualización optimista inmediata
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

    final optimisticState = currentData.copyWith(
      completedDatesByHabit: updatedMap,
    );
    state = AsyncData(optimisticState);

    // Verificar si con este toque se alcanzó el 100% de los hábitos de HOY
    final todayIso = HabitDateUtils.todayIso();
    final completedAllToday = shouldComplete &&
        isoDate == todayIso &&
        optimisticState.habits.isNotEmpty &&
        optimisticState.habits.every(
          (h) =>
              optimisticState.completedDatesByHabit[h.id]?.contains(todayIso) ??
              false,
        );

    // 2. Sincronización en segundo plano con el repositorio
    try {
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
      // Revertir al estado previo en caso de fallo
      state = AsyncData(currentData);
      final appError = AppException.fromError(error);
      return (
        completedAllToday: false,
        errorMessage: appError.userMessage,
      );
    }
  }

  /// Crea un nuevo hábito y actualiza el estado local sin recargar toda la pantalla.
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
      return AppException.fromError(error).userMessage;
    }
  }

  /// Edita un hábito existente y actualiza el estado en memoria.
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
      return AppException.fromError(error).userMessage;
    }
  }

  /// Elimina un hábito con actualización optimista y reversión segura en caso de error.
  Future<String?> deleteHabit(String habitId) async {
    final currentData = state.valueOrNull;
    if (currentData == null) return null;

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
      return AppException.fromError(error).userMessage;
    }
  }
}

final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, HabitsWorkspaceData>(
  HabitsController.new,
);

/// Proveedor derivado que transforma el estado asíncrono y los filtros activos
/// en la clase sellada [DashboardUiState] lista para pattern matching exhaustivo.
final dashboardUiStateProvider = Provider<DashboardUiState>((ref) {
  final asyncWorkspace = ref.watch(habitsControllerProvider);
  final filter = ref.watch(dashboardFilterProvider);

  return switch (asyncWorkspace) {
    AsyncData(:final value) => _buildReadyState(
        workspace: value,
        filter: filter,
      ),
    AsyncError(:final error) => DashboardUiError(
        AppException.fromError(error).userMessage,
      ),
    _ => const DashboardUiLoading(),
  };
});

DashboardUiReady _buildReadyState({
  required HabitsWorkspaceData workspace,
  required DashboardFilterState filter,
}) {
  final todayIso = HabitDateUtils.todayIso();
  final weekDays = HabitDateUtils.getWeekDays(weekOffset: filter.weekOffset);
  final weekRangeLabel = HabitDateUtils.formatWeekRangeLabel(
    weekOffset: filter.weekOffset,
  );

  // 1. Enriquecer cada hábito con sus métricas de racha (StreakCalculator)
  final allHabitsWithMetrics = workspace.habits.map<HabitWithMetrics>((habit) {
    final dates =
        workspace.completedDatesByHabit[habit.id] ?? const <String>{};
    final streaks = StreakCalculator.calculate(dates);
    return (
      habit: habit,
      completedDates: dates,
      currentStreak: streaks.currentStreak,
      bestStreak: streaks.bestStreak,
      isCompletedToday: dates.contains(todayIso),
    );
  }).toList(growable: false);

  // 2. Filtrar por categoría seleccionada
  final filteredHabits = filter.selectedCategory == 'Todas'
      ? allHabitsWithMetrics
      : allHabitsWithMetrics
          .where((item) => item.habit.category == filter.selectedCategory)
          .toList(growable: false);

  // 3. Calcular las 4 tarjetas KPI sobre el conjunto global de hábitos
  final totalHabits = allHabitsWithMetrics.length;
  final uniqueCategoriesCount =
      allHabitsWithMetrics.map((e) => e.habit.category).toSet().length;

  final todayCompletedCount =
      allHabitsWithMetrics.where((e) => e.isCompletedToday).length;
  final todayCompletionRate =
      totalHabits == 0 ? 0.0 : (todayCompletedCount / totalHabits);

  int topStreakDays = 0;
  String topStreakHabitName = 'Sin rachas activas';
  for (final item in allHabitsWithMetrics) {
    if (item.currentStreak > topStreakDays) {
      topStreakDays = item.currentStreak;
      topStreakHabitName = item.habit.name;
    }
  }

  // Efectividad en la semana seleccionada (sobre hábitos filtrados o totales)
  final targetHabitsForWeek = filteredHabits;
  final weekTargetCount = targetHabitsForWeek.length * 7;
  int weekCompletedCount = 0;

  final dailyProgressPoints = weekDays.map<DailyProgressPoint>((day) {
    int completedOnDay = 0;
    for (final item in targetHabitsForWeek) {
      if (item.completedDates.contains(day.isoDate)) {
        completedOnDay++;
      }
    }
    weekCompletedCount += completedOnDay;
    final pct = targetHabitsForWeek.isEmpty
        ? 0.0
        : (completedOnDay / targetHabitsForWeek.length) * 100.0;

    return (
      shortLabel: day.shortLabel,
      isoDate: day.isoDate,
      completedCount: completedOnDay,
      totalHabits: targetHabitsForWeek.length,
      percentage: pct,
      isToday: day.isToday,
    );
  }).toList(growable: false);

  final weekCompletionRate =
      weekTargetCount == 0 ? 0.0 : (weekCompletedCount / weekTargetCount);

  final kpiSummary = (
    activeHabitsCount: totalHabits,
    uniqueCategoriesCount: uniqueCategoriesCount,
    todayCompletedCount: todayCompletedCount,
    todayCompletionRate: todayCompletionRate,
    topStreakDays: topStreakDays,
    topStreakHabitName: topStreakHabitName,
    weekCompletedCount: weekCompletedCount,
    weekTargetCount: weekTargetCount,
    weekCompletionRate: weekCompletionRate,
  );

  return DashboardUiReady(
    allHabits: allHabitsWithMetrics,
    filteredHabits: filteredHabits,
    weekDays: weekDays,
    weekRangeLabel: weekRangeLabel,
    weekOffset: filter.weekOffset,
    selectedCategory: filter.selectedCategory,
    kpiSummary: kpiSummary,
    dailyProgressPoints: dailyProgressPoints,
  );
}
