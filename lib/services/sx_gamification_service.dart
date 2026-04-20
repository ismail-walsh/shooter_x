import 'dart:math' show max;
import '/backend/supabase/supabase.dart';

/// Handles all XP, streak, and challenge progression after a session is saved.
class SXGamificationService {
  SXGamificationService._();

  /// Call this immediately after every successful session save.
  /// [xpEarned] defaults to 100 but callers can override (e.g. bonus for PB).
  static Future<void> onSessionCompleted(
    String userId, {
    int xpEarned = 100,
  }) async {
    if (userId.isEmpty) return;

    await Future.wait([
      _updateStreak(userId),
      _awardXp(userId, xpEarned),
      _updateChallengeProgress(userId, 'sessions_this_week'),
    ]);
  }

  // ── Streak ────────────────────────────────────────────────────────────────
  static Future<void> _updateStreak(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final existing = await SupaFlow.client
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final lastDate = existing?['last_session_date'] as String?;

      // Don't double-count same-day sessions
      if (lastDate == today) return;

      final daysSince = lastDate != null
          ? DateTime.now()
              .difference(DateTime.parse(lastDate))
              .inDays
          : 999;

      // Streak continues if last session was within 7 days
      final newStreak = daysSince <= 7
          ? ((existing?['current_streak'] as int?) ?? 0) + 1
          : 1;

      final bestStreak = max(
        newStreak,
        (existing?['best_streak'] as int?) ?? 0,
      );

      await SupaFlow.client.from('user_streaks').upsert({
        'user_id': userId,
        'current_streak': newStreak,
        'best_streak': bestStreak,
        'last_session_date': today,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (_) {
      // Non-blocking
    }
  }

  // ── XP / Level ────────────────────────────────────────────────────────────
  static Future<void> _awardXp(String userId, int amount) async {
    try {
      await SupaFlow.client.rpc('increment_xp', params: {
        'uid': userId,
        'amount': amount,
      });
    } catch (_) {
      // RPC may not exist yet; fall back to manual update
      try {
        final row = await SupaFlow.client
            .from('users')
            .select('xp')
            .eq('id', userId)
            .maybeSingle();

        final currentXp = (row?['xp'] as int?) ?? 0;
        final newXp = currentXp + amount;
        final newLevel = (newXp ~/ 1000).clamp(0, 60);

        await SupaFlow.client.from('users').update({
          'xp': newXp,
          'level': newLevel,
        }).eq('id', userId);
      } catch (_) {
        // Silent — best effort
      }
    }
  }

  // ── Challenge progress ────────────────────────────────────────────────────
  static Future<void> _updateChallengeProgress(
      String userId, String type) async {
    try {
      // Find active user_challenges of the given type that aren't complete yet
      final rows = await SupaFlow.client
          .from('user_challenges')
          .select('id, progress, target')
          .eq('user_id', userId)
          .eq('type', type)
          .eq('completed', false);

      for (final row in (rows as List)) {
        final id = row['id'] as String;
        final progress = ((row['progress'] as int?) ?? 0) + 1;
        final target = (row['target'] as int?) ?? 1;
        final completed = progress >= target;

        await SupaFlow.client.from('user_challenges').update({
          'progress': progress,
          'completed': completed,
          if (completed)
            'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', id);
      }
    } catch (_) {
      // Non-blocking
    }
  }
}
