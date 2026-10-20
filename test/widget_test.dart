import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow_app/src/app.dart';
import 'package:habit_flow_app/src/core/utils/date_utils.dart';
import 'package:habit_flow_app/src/core/utils/streak_calculator.dart';
import 'package:habit_flow_app/src/core/utils/validators.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('StreakCalculator', () {
    test('calcula racha actual y mejor racha histórica correctamente', () {
      final referenceToday = DateTime(2026, 10, 19);
      final completed = <String>{
        '2026-10-10',
        '2026-10-11',
        '2026-10-12',
        '2026-10-13',
        // hueco el 14-16
        '2026-10-17',
        '2026-10-18',
        '2026-10-19',
      };

      final metrics = StreakCalculator.calculate(
        completed,
        referenceToday: referenceToday,
      );

      expect(metrics.currentStreak, 3);
      expect(metrics.bestStreak, 4);
    });

    test('mantiene viva la racha actual si se completó ayer pero aún no hoy', () {
      final referenceToday = DateTime(2026, 10, 19);
      final completed = <String>{
        '2026-10-17',
        '2026-10-18',
      };

      final metrics = StreakCalculator.calculate(
        completed,
        referenceToday: referenceToday,
      );

      expect(metrics.currentStreak, 2);
      expect(metrics.bestStreak, 2);
    });
  });

  group('HabitDateUtils & Validators', () {
    test('genera los 7 días de la semana de Lunes a Domingo', () {
      final days = HabitDateUtils.getWeekDays(
        weekOffset: 0,
        referenceDate: DateTime(2026, 10, 19), // Lunes 19 oct 2026
      );

      expect(days.length, 7);
      expect(days.first.isoDate, '2026-10-19');
      expect(days.first.shortLabel, 'Lun');
      expect(days.first.isToday, isTrue);
      expect(days.last.isoDate, '2026-10-25');
      expect(days.last.shortLabel, 'Dom');
    });

    test('sanitiza y valida entradas correctamente', () {
      expect(Validators.validateEmail('correo@dominio.com'), isNull);
      expect(Validators.validateEmail('invalido'), isNotNull);
      expect(
        Validators.sanitizeText('  Leer   30\nminutos  '),
        'Leer 30 minutos',
      );
    });
  });

  testWidgets('Renderiza AuthScreen cuando no hay sesión activa', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HabitFlowApp(),
      ),
    );

    expect(find.text('HabitFlow'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsWidgets);
  });
}
