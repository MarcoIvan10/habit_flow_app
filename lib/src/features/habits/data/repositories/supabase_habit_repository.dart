import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_dto.dart';
import '../models/habit_log_dto.dart';

/// Concrete implementation of [HabitRepository] backed by Supabase PostgreSQL with Row Level Security.
final class SupabaseHabitRepository implements HabitRepository {
  /// Creates a [SupabaseHabitRepository] using the provided [_client].
  const SupabaseHabitRepository(this._client);

  final SupabaseClient _client;

  static const String _habitsTable = 'habits';
  static const String _habitLogsTable = 'habit_logs';

  @override
  Future<List<Habit>> fetchHabits() async {
    try {
      final userId = _requireAuthenticatedUserId();
      final rows = await _client
          .from(_habitsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HabitDto.fromJson)
          .toList(growable: false);
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  @override
  Future<List<HabitLog>> fetchHabitLogs() async {
    try {
      final userId = _requireAuthenticatedUserId();
      final rows = await _client
          .from(_habitLogsTable)
          .select()
          .eq('user_id', userId)
          .order('completed_date', ascending: false)
          .limit(AppConstants.maxHabitLogsFetchLimit);

      return (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HabitLogDto.fromJson)
          .toList(growable: false);
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  @override
  Future<Habit> createHabit({
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    try {
      final userId = _requireAuthenticatedUserId();
      final sanitizedName = _validateAndSanitizeHabitAttributes(
        name: name,
        category: category,
        color: color,
      );

      final payload = HabitDto.toInsertJson(
        userId: userId,
        name: sanitizedName,
        category: category,
        icon: icon,
        color: color,
      );

      final inserted = await _client
          .from(_habitsTable)
          .insert(payload)
          .select()
          .single();

      return HabitDto.fromJson(inserted);
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  @override
  Future<Habit> updateHabit({
    required String habitId,
    required String name,
    required String category,
    required String icon,
    required String color,
  }) async {
    try {
      final userId = _requireAuthenticatedUserId();
      final sanitizedName = _validateAndSanitizeHabitAttributes(
        name: name,
        category: category,
        color: color,
      );

      final payload = HabitDto.toUpdateJson(
        name: sanitizedName,
        category: category,
        icon: icon,
        color: color,
      );

      final updated = await _client
          .from(_habitsTable)
          .update(payload)
          .eq('id', habitId)
          .eq('user_id', userId)
          .select()
          .single();

      return HabitDto.fromJson(updated);
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      final userId = _requireAuthenticatedUserId();
      await _client
          .from(_habitsTable)
          .delete()
          .eq('id', habitId)
          .eq('user_id', userId);
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  @override
  Future<bool> toggleHabitCompletion({
    required String habitId,
    required String isoDate,
    required bool shouldComplete,
  }) async {
    try {
      final userId = _requireAuthenticatedUserId();

      if (shouldComplete) {
        final payload = HabitLogDto.toInsertJson(
          habitId: habitId,
          userId: userId,
          completedDate: isoDate,
        );
        await _client.from(_habitLogsTable).upsert(
              payload,
              onConflict: 'habit_id,completed_date',
            );
        return true;
      }

      await _client
          .from(_habitLogsTable)
          .delete()
          .eq('habit_id', habitId)
          .eq('user_id', userId)
          .eq('completed_date', isoDate);
      return false;
    } catch (error) {
      throw SupabaseErrorMapper.map(error);
    }
  }

  String _requireAuthenticatedUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthAppException(
        userMessage: 'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }
    return userId;
  }

  String _validateAndSanitizeHabitAttributes({
    required String name,
    required String category,
    required String color,
  }) {
    final sanitizedName = Validators.sanitizeText(name);
    final nameError = Validators.validateHabitName(sanitizedName);
    if (nameError != null) {
      throw ValidationAppException(userMessage: nameError);
    }
    if (!AppConstants.categories.contains(category)) {
      throw const ValidationAppException(
        userMessage: 'La categoría seleccionada no es válida.',
      );
    }
    if (!AppConstants.accentColorKeys.contains(color)) {
      throw const ValidationAppException(
        userMessage: 'El color seleccionado no es válido.',
      );
    }
    return sanitizedName;
  }
}
