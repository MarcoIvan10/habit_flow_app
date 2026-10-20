import '../entities/habit.dart';
import '../entities/habit_log.dart';

/// Contrato de repositorio para gestión de hábitos y check-ins diarios
/// (Principio de Inversión de Dependencias - SOLID).
///
/// Ningún componente de presentación o dominio invoca `supabase.from()` directamente.
abstract interface class HabitRepository {
  /// Obtiene todos los hábitos del usuario autenticado ordenados por fecha de creación.
  Future<List<Habit>> fetchHabits();

  /// Obtiene todos los registros diarios (`habit_logs`) del usuario autenticado.
  Future<List<HabitLog>> fetchHabitLogs();

  /// Crea un nuevo hábito y devuelve la entidad persistida.
  Future<Habit> createHabit({
    required String name,
    required String category,
    required String icon,
    required String color,
  });

  /// Actualiza los datos de un hábito existente.
  Future<Habit> updateHabit({
    required String habitId,
    required String name,
    required String category,
    required String icon,
    required String color,
  });

  /// Elimina un hábito y sus registros asociados (`ON DELETE CASCADE`).
  Future<void> deleteHabit(String habitId);

  /// Alterna (crea o elimina) el check-in de un hábito en una fecha `YYYY-MM-DD`.
  /// Devuelve `true` si el hábito quedó marcado como completado, `false` si se desmarcó.
  Future<bool> toggleHabitCompletion({
    required String habitId,
    required String isoDate,
    required bool shouldComplete,
  });
}

