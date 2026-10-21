import '../../../../core/utils/habit_date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';

/// In-memory implementation of [HabitRepository] used for local demo mode.
final class LocalDemoHabitRepository implements HabitRepository {
  /// Creates a [LocalDemoHabitRepository] pre-populated with sample habits and check-in history.
  LocalDemoHabitRepository() {
    _seedInitialData();
  }

  final List<Habit> _habits = [];
  final List<HabitLog> _logs = [];
  int _idCounter = 100;

  @override
  Future<List<Habit>> fetchHabits() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<Habit>.unmodifiable(_habits);
  }

  @override
  Future<List<HabitLog>> fetchHabitLogs() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<HabitLog>.unmodifiable(_logs);
  }

  @override
  Future<Habit> createHabit({
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final habit = Habit(
      id: 'demo-habit-${_idCounter++}',
      userId: 'demo-user-001',
      name: Validators.sanitizeText(name),
      category: category,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
    );
    _habits.add(habit);
    return habit;
  }

  @override
  Future<Habit> updateHabit({
    required String habitId,
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) {
      throw StateError('Hábito no encontrado');
    }
    final updated = _habits[index].copyWith(
      name: Validators.sanitizeText(name),
      category: category,
      icon: icon,
      color: color,
    );
    _habits[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _habits.removeWhere((h) => h.id == habitId);
    _logs.removeWhere((l) => l.habitId == habitId);
  }

  @override
  Future<bool> toggleHabitCompletion({
    required String habitId,
    required String isoDate,
    required bool shouldComplete,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (shouldComplete) {
      final exists = _logs.any(
        (l) => l.habitId == habitId && l.completedDate == isoDate,
      );
      if (!exists) {
        _logs.add(
          HabitLog(
            id: 'demo-log-${_idCounter++}',
            habitId: habitId,
            userId: 'demo-user-001',
            completedDate: isoDate,
            createdAt: DateTime.now(),
          ),
        );
      }
      return true;
    }

    _logs.removeWhere(
      (l) => l.habitId == habitId && l.completedDate == isoDate,
    );
    return false;
  }

  void _seedInitialData() {
    final today = HabitDateUtils.dateOnly(DateTime.now());

    final initialHabits = [
      Habit(
        id: 'demo-habit-1',
        userId: 'demo-user-001',
        name: 'Beber 2L de agua',
        category: 'Salud',
        icon: '💧',
        color: 'cyan',
        createdAt: today.subtract(const Duration(days: 14)),
      ),
      Habit(
        id: 'demo-habit-2',
        userId: 'demo-user-001',
        name: 'Entrenamiento de fuerza',
        category: 'Deporte',
        icon: '🏋️',
        color: 'emerald',
        createdAt: today.subtract(const Duration(days: 14)),
      ),
      Habit(
        id: 'demo-habit-3',
        userId: 'demo-user-001',
        name: 'Lectura 30 minutos',
        category: 'Mente',
        icon: '📚',
        color: 'indigo',
        createdAt: today.subtract(const Duration(days: 14)),
      ),
      Habit(
        id: 'demo-habit-4',
        userId: 'demo-user-001',
        name: 'Meditación consciente',
        category: 'Mente',
        icon: '🧘',
        color: 'purple',
        createdAt: today.subtract(const Duration(days: 14)),
      ),
    ];

    _habits.addAll(initialHabits);

    final offsetsByHabit = <String, List<int>>{
      'demo-habit-1': [0, 1, 2, 3, 4, 5, 7, 8, 9],
      'demo-habit-2': [0, 1, 2, 4, 6, 7, 8, 9, 10],
      'demo-habit-3': [1, 2, 3, 4, 5, 6, 7],
      'demo-habit-4': [0, 1, 3, 4, 5],
    };

    offsetsByHabit.forEach((habitId, dayOffsets) {
      for (final offset in dayOffsets) {
        final date = DateTime(today.year, today.month, today.day - offset);
        _logs.add(
          HabitLog(
            id: 'demo-log-${_idCounter++}',
            habitId: habitId,
            userId: 'demo-user-001',
            completedDate: HabitDateUtils.toIsoDateString(date),
            createdAt: date,
          ),
        );
      }
    });
  }
}
