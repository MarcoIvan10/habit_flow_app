import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow_app/src/app.dart';
import 'package:habit_flow_app/src/core/utils/habit_date_utils.dart';
import 'package:habit_flow_app/src/core/utils/streak_calculator.dart';
import 'package:habit_flow_app/src/features/habits/domain/entities/habit.dart';
import 'package:habit_flow_app/src/features/habits/domain/models/dashboard_filter_state.dart';
import 'package:habit_flow_app/src/features/habits/domain/models/habits_workspace_data.dart';
import 'package:habit_flow_app/src/features/habits/domain/usecases/build_dashboard_ui_state_use_case.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Test suite verifying streak calculation, domain use cases, and root authentication rendering.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('StreakCalculator unit tests', () {
    test('calculates current streak when today is completed', () {
      final today = HabitDateUtils.dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final completedKeys = {
        HabitDateUtils.toIsoDateString(today),
        HabitDateUtils.toIsoDateString(yesterday),
        HabitDateUtils.toIsoDateString(twoDaysAgo),
      };

      final metrics = StreakCalculator.calculate(
        completedKeys,
        referenceToday: today,
      );

      expect(metrics.currentStreak, 3);
      expect(metrics.bestStreak, 3);
    });

    test('keeps current streak alive when today is pending but yesterday was completed', () {
      final today = HabitDateUtils.dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final completedKeys = {
        HabitDateUtils.toIsoDateString(yesterday),
        HabitDateUtils.toIsoDateString(twoDaysAgo),
      };

      final metrics = StreakCalculator.calculate(
        completedKeys,
        referenceToday: today,
      );

      expect(metrics.currentStreak, 2);
      expect(metrics.bestStreak, 2);
    });

    test('returns 0 current streak if neither today nor yesterday was completed', () {
      final today = HabitDateUtils.dateOnly(DateTime.now());
      final fourDaysAgo = today.subtract(const Duration(days: 4));
      final fiveDaysAgo = today.subtract(const Duration(days: 5));

      final completedKeys = {
        HabitDateUtils.toIsoDateString(fourDaysAgo),
        HabitDateUtils.toIsoDateString(fiveDaysAgo),
      };

      final metrics = StreakCalculator.calculate(
        completedKeys,
        referenceToday: today,
      );

      expect(metrics.currentStreak, 0);
      expect(metrics.bestStreak, 2);
    });
  });

  group('BuildDashboardUiStateUseCase unit tests', () {
    test('computes weekly KPIs and habit metrics accurately', () {
      final today = HabitDateUtils.dateOnly(DateTime.now());
      final todayKey = HabitDateUtils.toIsoDateString(today);

      final habit = Habit(
        id: 'habit-1',
        userId: 'user-1',
        name: 'Practicar Duolingo',
        category: 'Mindfulness',
        icon: '🦉',
        color: 'emerald',
        createdAt: today.subtract(const Duration(days: 10)),
      );

      final workspace = HabitsWorkspaceData(
        habits: [habit],
        completedDatesByHabit: {
          'habit-1': {todayKey},
        },
      );

      const DashboardFilterState filter = (
        weekOffset: 0,
        selectedCategory: 'Todas',
      );

      final state = BuildDashboardUiStateUseCase.execute(
        workspace: workspace,
        filter: filter,
        referenceToday: today,
      );

      expect(state.allHabits.length, 1);
      expect(state.filteredHabits.length, 1);
      expect(state.filteredHabits.first.currentStreak, 1);
      expect(state.kpiSummary.weekCompletedCount, 1);
      expect(state.kpiSummary.topStreakDays, 1);
    });
  });

  testWidgets('HabitFlowApp renders AuthScreen initially when unauthenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabitFlowApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('HabitFlow'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
  });
}
