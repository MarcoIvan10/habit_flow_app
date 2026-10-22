import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/states/dashboard_ui_state.dart';
import '../providers/habits_providers.dart';
import '../widgets/charts_section_widget.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_error_view.dart';
import '../widgets/habit_form_sheet.dart';
import '../widgets/habit_matrix_widget.dart';
import '../widgets/kpi_grid_widget.dart';
import '../widgets/week_navigator_widget.dart';

/// Main authenticated dashboard screen displaying KPI summaries, week navigation,
/// weekly habit tracking cards, visual analytics charts, and confetti celebration.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen] for the authenticated [user].
  const DashboardScreen({
    required this.user,
    super.key,
  });

  /// Currently authenticated user.
  final AppUser user;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? AppColors.rose500 : AppColors.emerald600,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  Future<void> _handleToggleDay(String habitId, String isoDate) async {
    final result = await ref
        .read(habitsControllerProvider.notifier)
        .toggleHabitDay(habitId: habitId, isoDate: isoDate);

    if (result.errorMessage != null) {
      _showSnackBar(result.errorMessage!, isError: true);
      return;
    }

    if (result.completedAllToday) {
      _confettiController.play();
      _showSnackBar(
        '¡Increíble! Completaste el 100% de tus hábitos de hoy 🎉',
      );
    }
  }

  Future<void> _openCreateHabitSheet() async {
    final payload = await HabitFormSheet.show(context);
    if (payload == null || !mounted) {
      return;
    }

    final errorMessage =
        await ref.read(habitsControllerProvider.notifier).createHabit(
              name: payload.name,
              category: payload.category,
              icon: payload.icon,
              color: payload.color,
            );

    if (errorMessage != null) {
      _showSnackBar(errorMessage, isError: true);
    } else {
      _showSnackBar('Hábito "${payload.name}" creado.');
    }
  }

  Future<void> _openEditHabitSheet(Habit habit) async {
    final payload = await HabitFormSheet.show(
      context,
      initialHabit: habit,
    );
    if (payload == null || !mounted) {
      return;
    }

    final errorMessage =
        await ref.read(habitsControllerProvider.notifier).updateHabit(
              habitId: habit.id,
              name: payload.name,
              category: payload.category,
              icon: payload.icon,
              color: payload.color,
            );

    if (errorMessage != null) {
      _showSnackBar(errorMessage, isError: true);
    } else {
      _showSnackBar('Hábito actualizado.');
    }
  }

  Future<void> _confirmDeleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${habit.name}" y todo su historial de registros? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.rose500,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final errorMessage = await ref
        .read(habitsControllerProvider.notifier)
        .deleteHabit(habit.id);

    if (errorMessage != null) {
      _showSnackBar(errorMessage, isError: true);
    } else {
      _showSnackBar('Hábito eliminado.');
    }
  }

  Widget _buildReadyBody(DashboardUiReady uiState, TextTheme textTheme) {
    return RefreshIndicator(
      onRefresh: () => ref.read(habitsControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KpiGridWidget(summary: uiState.kpiSummary),
                const SizedBox(height: 18),
                WeekNavigatorWidget(
                  weekRangeLabel: uiState.weekRangeLabel,
                  weekOffset: uiState.weekOffset,
                  selectedCategory: uiState.selectedCategory,
                  onPreviousWeek: () {
                    ref.read(dashboardFilterProvider.notifier).previousWeek();
                  },
                  onNextWeek: () {
                    ref.read(dashboardFilterProvider.notifier).nextWeek();
                  },
                  onResetToday: () {
                    ref
                        .read(dashboardFilterProvider.notifier)
                        .resetToCurrentWeek();
                  },
                  onCategorySelected: (category) {
                    ref
                        .read(dashboardFilterProvider.notifier)
                        .selectCategory(category);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seguimiento Semanal',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${uiState.filteredHabits.length} ${uiState.filteredHabits.length == 1 ? 'hábito' : 'hábitos'}',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HabitMatrixWidget(
                  habits: uiState.filteredHabits,
                  weekDays: uiState.weekDays,
                  isFilteredEmpty: uiState.isFilteredEmpty,
                  onToggleDay: _handleToggleDay,
                  onEditHabit: _openEditHabitSheet,
                  onDeleteHabit: _confirmDeleteHabit,
                  onCreateFirstHabit: _openCreateHabitSheet,
                  onClearCategoryFilter: () {
                    ref
                        .read(dashboardFilterProvider.notifier)
                        .selectCategory('Todas');
                  },
                ),
                const SizedBox(height: 12),
                ChartsSectionWidget(
                  dailyProgressPoints: uiState.dailyProgressPoints,
                  habits: uiState.filteredHabits,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardUiStateProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: DashboardAppBar(
        user: widget.user,
        isDark: isDark,
        onToggleTheme: () {
          ref.read(themeModeProvider.notifier).toggleTheme(brightness);
        },
        onSignOut: () {
          ref.read(authSessionProvider.notifier).signOut();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateHabitSheet,
        backgroundColor: AppColors.indigo600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo Hábito',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            switch (uiState) {
              DashboardUiLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              DashboardUiError(:final message) => DashboardErrorView(
                  message: message,
                  onRetry: () {
                    ref.read(habitsControllerProvider.notifier).refresh();
                  },
                ),
              final DashboardUiReady readyState =>
                _buildReadyBody(readyState, textTheme),
            },
            IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 26,
                gravity: 0.25,
                colors: const [
                  AppColors.indigo500,
                  AppColors.emerald500,
                  AppColors.amber500,
                  AppColors.rose500,
                  AppColors.cyan500,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
