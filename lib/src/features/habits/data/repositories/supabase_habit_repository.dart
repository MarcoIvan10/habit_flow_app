import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_dto.dart';
import '../models/habit_log_dto.dart';

/// Implementación concreta de [HabitRepository] respaldada por PostgreSQL en Supabase con RLS.
final class SupabaseHabitRepository implements HabitRepository {
  const SupabaseHabitRepository(this._client);

  final SupabaseClient _client;

  static const String _habitsTable = 'habits';
  static const String _habitLogsTable = 'habit_logs';

  String _requireAuthenticatedUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthAppException(
        userMessage: 'Tu sesión ha expirado. Vuelve a iniciar sesión.',
      );
    }
    return userId;
  }

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
      throw AppException.fromError(error);
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
          .order('completed_date', ascending: true);

      return (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HabitLogDto.fromJson)
          .toList(growable: false);
    } catch (error) {
      throw AppException.fromError(error);
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
      final sanitizedName = Validators.sanitizeText(name);
      final validationError = Validators.validateHabitName(sanitizedName);
      if (validationError != null) {
        throw ValidationAppException(userMessage: validationError);
      }

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
      throw AppException.fromError(error);
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
      final sanitizedName = Validators.sanitizeText(name);
      final validationError = Validators.validateHabitName(sanitizedName);
      if (validationError != null) {
        throw ValidationAppException(userMessage: validationError);
      }

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
      throw AppException.fromError(error);
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
      throw AppException.fromError(error);
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
      } else {
        await _client
            .from(_habitLogsTable)
            .delete()
            .eq('habit_id', habitId)
            .eq('user_id', userId)
            .eq('completed_date', isoDate);
        return false;
      }
    } catch (error) {
      throw AppException.fromError(error);
    }
  }
}

