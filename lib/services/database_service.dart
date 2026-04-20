import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Centralized service for all Supabase database operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ==================== USERS ====================

  /// Get current user's profile
  Future<UsersRow?> getCurrentUserProfile() async {
    if (currentUserUid == null || currentUserUid!.isEmpty) return null;
    final result = await UsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', currentUserUid),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user by ID
  Future<UsersRow?> getUserById(String userId) async {
    final result = await UsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', userId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Create user profile after signup
  Future<UsersRow?> createUserProfile({
    required String id,
    required String email,
    required String username,
  }) async {
    final result = await UsersTable().insert({
      'id': id,
      'email': email,
      'username': username,
      'password_hash': '', // Not used with Supabase Auth
    });
    return result;
  }

  /// Update user profile
  Future<UsersRow?> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? preferredDiscipline,
    String? profileImg,
    String? coverImg,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (preferredDiscipline != null) data['preferred_discipline'] = preferredDiscipline;
    if (profileImg != null) data['profile_img'] = profileImg;
    if (coverImg != null) data['cover_img'] = coverImg;

    if (data.isEmpty) return null;

    final result = await UsersTable().update(
      data: data,
      matchingRows: (q) => q.eqOrNull('id', userId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== SESSIONS ====================

  /// Get all sessions for current user
  Future<List<SessionsRow>> getUserSessions({String? discipline}) async {
    if (currentUserUid == null) return [];
    final result = await SessionsTable().queryRows(
      queryFn: (q) {
        var query = q.eqOrNull('user_id', currentUserUid);
        if (discipline != null && discipline.isNotEmpty) {
          query = query.eqOrNull('discipline', discipline);
        }
        return query.order('created_at', ascending: false);
      },
    );
    return result;
  }

  /// Get session by ID
  Future<SessionsRow?> getSessionById(String sessionId) async {
    final result = await SessionsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', sessionId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Create a new shooting session
  Future<SessionsRow?> createSession({
    required String discipline,
    required String firearm,
    required String ammoType,
    required int distance,
    required int hits,
    required int totalShots,
    String? targetImageUrl,
    String? competitionId,
    Map<String, dynamic>? conditions,
  }) async {
    if (currentUserUid == null) return null;

    final accuracy = totalShots > 0 ? (hits / totalShots) * 100 : 0.0;

    final result = await SessionsTable().insert({
      'user_id': currentUserUid,
      'discipline': discipline,
      'firearm': firearm,
      'ammo_type': ammoType,
      'distance': distance,
      'hits': hits,
      'total_shots': totalShots,
      'accuracy': accuracy,
      'target_image_url': targetImageUrl,
      'competition_id': competitionId,
      'conditions': conditions,
    });
    return result;
  }

  /// Get user's session statistics
  Future<Map<String, dynamic>> getUserSessionStats() async {
    if (currentUserUid == null) return {};

    final sessions = await getUserSessions();
    if (sessions.isEmpty) return {};

    int totalSessions = sessions.length;
    int totalShots = 0;
    int totalHits = 0;
    double avgAccuracy = 0;

    for (var session in sessions) {
      totalShots += session.totalShots ?? 0;
      totalHits += session.hits ?? 0;
    }

    avgAccuracy = totalShots > 0 ? (totalHits / totalShots) * 100 : 0;

    return {
      'total_sessions': totalSessions,
      'total_shots': totalShots,
      'total_hits': totalHits,
      'avg_accuracy': avgAccuracy,
    };
  }

  // ==================== CLUBS ====================

  /// Get all clubs
  Future<List<ClubsRow>> getAllClubs({String? searchQuery, String? discipline}) async {
    final result = await ClubsTable().queryRows(
      queryFn: (q) {
        var query = q;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query = query.ilike('name', '%$searchQuery%');
        }
        if (discipline != null && discipline.isNotEmpty) {
          query = query.eqOrNull('discipline', discipline);
        }
        return query.order('name');
      },
    );
    return result;
  }

  /// Get club by ID
  Future<ClubsRow?> getClubById(String clubId) async {
    final result = await ClubsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', clubId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get user's club memberships
  Future<List<ClubMembershipsRow>> getUserClubMemberships() async {
    if (currentUserUid == null) return [];
    final result = await ClubMembershipsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    return result;
  }

  /// Get clubs that user is a member of
  Future<List<ClubsRow>> getUserClubs() async {
    final memberships = await getUserClubMemberships();
    if (memberships.isEmpty) return [];

    final clubIds = memberships.map((m) => m.clubId).whereType<String>().toList();
    if (clubIds.isEmpty) return [];

    final result = await ClubsTable().queryRows(
      queryFn: (q) => q.inFilter('id', clubIds),
    );
    return result;
  }

  /// Join a club
  Future<ClubMembershipsRow?> joinClub(String clubId) async {
    if (currentUserUid == null) return null;

    // Check if already a member
    final existing = await ClubMembershipsTable().querySingleRow(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('club_id', clubId),
    );
    if (existing.isNotEmpty) return existing.first;

    final result = await ClubMembershipsTable().insert({
      'user_id': currentUserUid,
      'club_id': clubId,
      'role': 'member',
    });
    return result;
  }

  /// Leave a club
  Future<void> leaveClub(String clubId) async {
    if (currentUserUid == null) return;
    await ClubMembershipsTable().delete(
      matchingRows: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('club_id', clubId),
    );
  }

  /// Check if user is member of a club
  Future<bool> isClubMember(String clubId) async {
    if (currentUserUid == null) return false;
    final result = await ClubMembershipsTable().querySingleRow(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('club_id', clubId),
    );
    return result.isNotEmpty;
  }

  // ==================== EVENTS ====================

  /// Get all events
  Future<List<EventsRow>> getAllEvents({String? clubId}) async {
    final result = await EventsTable().queryRows(
      queryFn: (q) {
        var query = q;
        if (clubId != null && clubId.isNotEmpty) {
          query = query.eqOrNull('club_id', clubId);
        }
        return query.order('date', ascending: true);
      },
    );
    return result;
  }

  /// Get upcoming events
  Future<List<EventsRow>> getUpcomingEvents() async {
    // Use date-only string (YYYY-MM-DD) so the filter works for both
    // DATE and TIMESTAMPTZ column types in PostgreSQL.
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final result = await EventsTable().queryRows(
      queryFn: (q) => q
          .gte('date', today)
          .order('date', ascending: true),
    );
    return result;
  }

  /// Get event by ID
  Future<EventsRow?> getEventById(String eventId) async {
    final result = await EventsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', eventId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Register for an event
  Future<EventRegistrationsRow?> registerForEvent(String eventId) async {
    if (currentUserUid == null) return null;

    // Check if already registered
    final existing = await EventRegistrationsTable().querySingleRow(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('event_id', eventId),
    );
    if (existing.isNotEmpty) return existing.first;

    final result = await EventRegistrationsTable().insert({
      'user_id': currentUserUid,
      'event_id': eventId,
      'status': 'registered',
    });
    return result;
  }

  /// Unregister from an event
  Future<void> unregisterFromEvent(String eventId) async {
    if (currentUserUid == null) return;
    await EventRegistrationsTable().delete(
      matchingRows: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('event_id', eventId),
    );
  }

  /// Check if user is registered for an event
  Future<bool> isRegisteredForEvent(String eventId) async {
    if (currentUserUid == null) return false;
    final result = await EventRegistrationsTable().querySingleRow(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('event_id', eventId),
    );
    return result.isNotEmpty;
  }

  /// Get user's event registrations
  Future<List<EventRegistrationsRow>> getUserEventRegistrations() async {
    if (currentUserUid == null) return [];
    final result = await EventRegistrationsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    return result;
  }

  // ==================== POSTS ====================

  /// Get all posts (community feed)
  Future<List<PostsRow>> getAllPosts({int limit = 50}) async {
    final result = await PostsTable().queryRows(
      queryFn: (q) => q.order('created_at', ascending: false).limit(limit),
    );
    return result;
  }

  /// Get posts for a specific club
  Future<List<ClubPostsRow>> getClubPosts(String clubId) async {
    final result = await ClubPostsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('club_id', clubId)
          .order('created_at', ascending: false),
    );
    return result;
  }

  /// Create a post
  Future<PostsRow?> createPost({
    required String content,
    String? mediaUrl,
    String? sessionId,
    String? clubId,
  }) async {
    if (currentUserUid == null) return null;

    final result = await PostsTable().insert({
      'user_id': currentUserUid,
      'content': content,
      'media_url': mediaUrl,
      'session_id': sessionId,
      'club_id': clubId,
      'likes': 0,
    });
    return result;
  }

  /// Like a post (increment likes count)
  Future<void> likePost(String postId) async {
    // Note: For proper like tracking, you'd want a separate likes table
    // This is a simplified version that just increments the counter
    final post = await PostsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', postId),
    );
    if (post.isNotEmpty) {
      await PostsTable().update(
        data: {'likes': (post.first.likes ?? 0) + 1},
        matchingRows: (q) => q.eqOrNull('id', postId),
      );
    }
  }

  // ==================== DISCIPLINES ====================

  /// Get all disciplines
  Future<List<DisciplinesRow>> getAllDisciplines() async {
    final result = await DisciplinesTable().queryRows(
      queryFn: (q) => q.order('discipline_name'),
    );
    return result;
  }

  // ==================== TRAINING ====================

  /// Get user's training progress
  Future<List<TrainingProgressRow>> getUserTrainingProgress() async {
    if (currentUserUid == null) return [];
    final result = await TrainingProgressTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    return result;
  }

  /// Update training progress
  Future<TrainingProgressRow?> updateTrainingProgress({
    required String trainingType,
    required String module,
    required double progress,
  }) async {
    if (currentUserUid == null) return null;

    // Check if exists
    final existing = await TrainingProgressTable().querySingleRow(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .eqOrNull('training_type', trainingType)
          .eqOrNull('module', module),
    );

    if (existing.isNotEmpty) {
      final result = await TrainingProgressTable().update(
        data: {'progress': progress, 'last_updated': DateTime.now().toIso8601String()},
        matchingRows: (q) => q.eqOrNull('id', existing.first.id),
      );
      return result.isNotEmpty ? result.first : null;
    } else {
      final result = await TrainingProgressTable().insert({
        'user_id': currentUserUid,
        'training_type': trainingType,
        'module': module,
        'progress': progress,
      });
      return result;
    }
  }

  // ==================== LEADERBOARD ====================

  /// Get leaderboard entries
  Future<List<LeaderboardEntriesRow>> getLeaderboard({String? clubId, String? competitionId}) async {
    final result = await LeaderboardEntriesTable().queryRows(
      queryFn: (q) {
        var query = q;
        if (clubId != null) {
          query = query.eqOrNull('club_id', clubId);
        }
        if (competitionId != null) {
          query = query.eqOrNull('competition_id', competitionId);
        }
        return query.order('score', ascending: false);
      },
    );
    return result;
  }

  // ==================== MEMBERSHIP CARDS ====================

  /// Get user's membership cards
  Future<List<MembershipCardsRow>> getUserMembershipCards() async {
    if (currentUserUid == null) return [];
    final result = await MembershipCardsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    return result;
  }

  // ==================== ACHIEVEMENTS ====================

  /// Get all achievements
  Future<List<AchievementsRow>> getAllAchievements() async {
    final result = await AchievementsTable().queryRows(
      queryFn: (q) => q.order('name'),
    );
    return result;
  }

  /// Get user's achievements
  Future<List<UserAchievementsRow>> getUserAchievements() async {
    if (currentUserUid == null) return [];
    final result = await UserAchievementsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', currentUserUid),
    );
    return result;
  }

  // ==================== RANGES ====================

  /// Get all shooting ranges
  Future<List<RangesRow>> getAllRanges({String? discipline}) async {
    final result = await RangesTable().queryRows(
      queryFn: (q) {
        var query = q;
        if (discipline != null && discipline.isNotEmpty) {
          query = query.eqOrNull('discipline', discipline);
        }
        return query.order('name');
      },
    );
    return result;
  }

  // ==================== LEADERBOARD (scoped) ====================

  /// Get leaderboard entries filtered by scope ('overall' | 'monthly' | 'club' | 'friends')
  /// Optionally filter by clubId if provided (requires club_id column on leaderboard_entries).
  Future<List<LeaderboardEntriesRow>> getLeaderboardByScope(
      String scope, {String? clubId}) async {
    final result = await LeaderboardEntriesTable().queryRows(
      queryFn: (q) {
        var query = q.eqOrNull('scope', scope);
        if (clubId != null) query = query.eqOrNull('club_id', clubId);
        return query.order('rank', ascending: true);
      },
    );
    return result;
  }

  // ==================== NOTIFICATIONS ====================

  /// Get all notifications for the current user, newest first
  Future<List<NotificationsRow>> getUserNotifications() async {
    if (currentUserUid.isEmpty) return [];
    final result = await NotificationsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .order('created_at', ascending: false),
    );
    return result;
  }

  /// Mark a single notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await NotificationsTable().update(
      data: {'is_read': true},
      matchingRows: (q) => q.eqOrNull('id', notificationId),
    );
  }

  // ==================== SESSIONS (recent) ====================

  /// Get the most recent N sessions for the current user
  Future<List<SessionsRow>> getRecentSessions({int limit = 3}) async {
    if (currentUserUid.isEmpty) return [];
    final result = await SessionsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .order('created_at', ascending: false)
          .limit(limit),
    );
    return result;
  }

  // ==================== SESSIONS (this week) ====================

  /// Returns sessions for the current user in the current calendar week
  /// (Monday 00:00 UTC → now). Used to drive the streak day-dot row.
  Future<List<SessionsRow>> getSessionsThisWeek() async {
    if (currentUserUid.isEmpty) return [];
    final now = DateTime.now().toUtc();
    // Monday of the current week at midnight UTC
    final weekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final result = await SessionsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', currentUserUid)
          .gte('created_at', weekStart.toIso8601String())
          .order('created_at', ascending: true),
    );
    return result;
  }

  // ==================== WEEKLY CHALLENGES ====================

  /// Returns the current user's active weekly challenges, joined with the
  /// weekly_challenge definition so title and xp_reward are available.
  /// Falls back to an empty list if either table doesn't exist yet.
  Future<List<Map<String, dynamic>>> getUserWeeklyChallenges(
      String userId) async {
    if (userId.isEmpty) return [];
    try {
      // Fetch user_challenges for this user that are not completed
      final userRows = await SupaFlow.client
          .from('user_challenges')
          .select('id, challenge_id, type, progress, target, completed')
          .eq('user_id', userId)
          .eq('completed', false)
          .limit(5);

      if (userRows is! List || userRows.isEmpty) return [];

      // Collect challenge_ids to fetch definitions
      final ids = userRows
          .map((r) => r['challenge_id'])
          .whereType<String>()
          .toList();

      Map<String, Map<String, dynamic>> defs = {};
      if (ids.isNotEmpty) {
        final defRows = await SupaFlow.client
            .from('weekly_challenges')
            .select('id, title, xp_reward')
            .inFilter('id', ids);
        if (defRows is List) {
          for (final d in defRows) {
            defs[d['id'] as String] = Map<String, dynamic>.from(d);
          }
        }
      }

      // Merge: user row + definition
      return userRows.map((r) {
        final def = defs[r['challenge_id'] as String?] ?? {};
        return {
          'title': def['title'] ?? r['type'] ?? 'Challenge',
          'progress': r['progress'] ?? 0,
          'target': r['target'] ?? 1,
          'xp_reward': def['xp_reward'] ?? 100,
          'type': r['type'] ?? '',
          'completed': r['completed'] ?? false,
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

/// Global instance for easy access
final databaseService = DatabaseService();
