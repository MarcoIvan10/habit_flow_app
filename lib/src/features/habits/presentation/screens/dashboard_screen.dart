import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/models/dashboard_models.dart';
import '../providers/habits_providers.dart';
import '../widgets/charts_section_widget.dart';
import '../widgets/habit_form_sheet.dart';
import '../widgets/habit_matrix_widget.dart';
import '../widgets/kpi_grid_widget.dart';
import '../widgets/week_navigator_widget.dart';

/// Pantalla principal del Dashboard de HabitFlow Mobile.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    required this.user,
    super.key,
  });

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
    if (!mounted) return;
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
    if (payload == null || !mounted) return;

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
    if (payload == null || !mounted) return;

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

    if (confirmed != true || !mounted) return;

    final errorMessage = await ref
        .read(habitsControllerProvider.notifier)
        .deleteHabit(habit.id);

    if (errorMessage != null) {
      _showSnackBar(errorMessage, isError: true);
    } else {
      _showSnackBar('Hábito eliminado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(dashboardUiStateProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.indigo500, AppColors.emerald500],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppConstants.appName),
                  Text(
                    widget.user.isDemo
                        ? 'Modo Demo • ${widget.user.displayName}'
                        : widget.user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme(brightness);
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              ref.read(authSessionProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pattern matching exhaustivo de Dart 3 sobre la Sealed Class DashboardUiState
          switch (uiState) {
            DashboardUiLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            DashboardUiError(:final message) => _DashboardErrorView(
                message: message,
                onRetry: () {
                  ref.read(habitsControllerProvider.notifier).refresh();
                },
              ),
            DashboardUiReady() => RefreshIndicator(
                onRefresh: () =>
                    ref.read(habitsControllerProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Cuadrícula 2x2 de KPIs
                          KpiGridWidget(summary: uiState.kpiSummary),
                          const SizedBox(height: 18),

                          // 2. Navegador Semanal y Filtro de Categorías
                          WeekNavigatorWidget(
                            weekRangeLabel: uiState.weekRangeLabel,
                            weekOffset: uiState.weekOffset,
                            selectedCategory: uiState.selectedCategory,
                            onPreviousWeek: () {
                              ref
                                  .read(dashboardFilterProvider.notifier)
                                  .previousWeek();
                            },
                            onNextWeek: () {
                              ref
                                  .read(dashboardFilterProvider.notifier)
                                  .nextWeek();
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

                          // Encabezado de sección de Hábitos
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

                          // 3. Matriz / Tarjetas Semanales con Optimistic UI
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

                          // 4. Sección de Analítica Visual (fl_chart)
                          ChartsSectionWidget(
                            dailyProgressPoints: uiState.dailyProgressPoints,
                            habits: uiState.filteredHabits,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          },

          // Overlay de celebración (Confetti) al completar el 100% del día
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
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.rose500.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.rose500,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pudimos cargar tus hábitos',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
