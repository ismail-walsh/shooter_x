import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/components/sx_gamification_widgets.dart';
import '/services/database_service.dart';
import '/utils/sx_ranks.dart';
import '/utils/sx_discipline_theme.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  static const String routeName = 'HomePage';
  static const String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  bool _loading = true;

  // User
  UsersRow? _user;

  // Gamification
  int _currentStreak = 0;
  int _bestStreak = 0;
  Set<int> _streakActiveDays = {};
  List<Map<String, dynamic>> _weeklyChallenges = [];

  // Content
  List<SessionsRow> _sessions = [];
  List<LeaderboardEntriesRow> _board = [];
  List<EventsRow> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = currentUserUid;
    try {
      final results = await Future.wait([
        // 0 — user profile (returns UsersRow? directly)
        databaseService.getCurrentUserProfile()
            .catchError((_) => null),
        // 1 — streak row
        SupaFlow.client
            .from('user_streaks')
            .select()
            .eq('user_id', uid)
            .maybeSingle()
            .catchError((_) => null),
        // 2 — recent sessions
        databaseService.getRecentSessions(limit: 6)
            .catchError((_) => <SessionsRow>[]),
        // 3 — leaderboard top 3
        databaseService.getLeaderboardByScope('overall')
            .catchError((_) => <LeaderboardEntriesRow>[]),
        // 4 — upcoming events
        databaseService.getUpcomingEvents()
            .catchError((_) => <EventsRow>[]),
        // 5 — sessions this week for streak dots (last 7 days)
        databaseService.getSessionsThisWeek()
            .catchError((_) => <SessionsRow>[]),
        // 6 — user's weekly challenges (joined with definitions)
        databaseService.getUserWeeklyChallenges(uid)
            .catchError((_) => <Map<String, dynamic>>[]),
      ]).timeout(const Duration(seconds: 12), onTimeout: () => [
        null, null, <SessionsRow>[], <LeaderboardEntriesRow>[], <EventsRow>[],
        <SessionsRow>[], <Map<String, dynamic>>[],
      ]);

      if (!mounted) return;

      final streak = results[1] as Map<String, dynamic>?;
      final weeklySessions = results[5] as List<SessionsRow>;

      // Calculate which days (0=Mon…6=Sun) had a session this week
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final activeDays = <int>{};
      for (final s in weeklySessions) {
        final d = s.createdAt;
        if (d != null && d.isAfter(weekStart)) {
          activeDays.add(d.weekday - 1); // 0=Mon
        }
      }

      setState(() {
        _user = results[0] as UsersRow?;
        _currentStreak = (streak?['current_streak'] as int?) ?? 0;
        _bestStreak = (streak?['best_streak'] as int?) ?? 0;
        _streakActiveDays = activeDays;
        _sessions = results[2] as List<SessionsRow>;
        _board = (results[3] as List<LeaderboardEntriesRow>).take(3).toList();
        _events = (results[4] as List<EventsRow>).take(3).toList();
        _weeklyChallenges = results[6] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month - 1]}';
  }

  static String _sessionBadge(SessionsRow s) {
    if (s.isPersonalBest == true) return 'PB';
    final diff = DateTime.now().difference(s.createdAt ?? DateTime.now());
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 30).floor()}mo';
  }

  static String _fmtXp(int? xp) {
    if (xp == null) return '0 XP';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }

  static String _eventDateLine(EventsRow e) {
    if (e.date == null) return e.location ?? '';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = e.date!;
    final loc = e.location?.isNotEmpty == true ? ' · ${e.location}' : '';
    return '${d.day} ${m[d.month - 1]}$loc';
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final level = _user?.level ?? 0;
    final xp = _user?.totalXp ?? 0;
    // XP needed per level = 500 + level * 100 (simple curve)
    final xpMax = 500 + level * 100;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildHeader(context, theme),
            ),

            // ── Rank / XP bar ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SXRankXPBar(level: level, xp: xp, xpMax: xpMax),
              ),
            ),

            // ── Streak ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SXStreakCard(
                streak: _currentStreak,
                bestStreak: _bestStreak,
                activeDays: _streakActiveDays,
              ),
            ),

            // ── Weekly Challenges ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: SXWeeklyChallengeCard(liveData: _weeklyChallenges),
            ),

            // ── Recent Sessions ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  SXSectionTitle(
                    label: 'Recent Sessions',
                    actionLabel: 'See All',
                    onAction: () => context.pushNamed('AllSessions'),
                  ),
                  if (_loading)
                    const SizedBox(
                      height: 170,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: Text(
                        'No sessions yet — log your first shot!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (ctx, i) {
                          final s = _sessions[i];
                          final discipline =
                              s.discipline ?? s.location ?? '';
                          final dt = getDisciplineTheme(discipline);
                          return _SessionCard(
                            session: s,
                            badge: _sessionBadge(s),
                            date: _fmtDate(s.createdAt),
                            disciplineTheme: dt,
                            onTap: () => context.pushNamed(
                              'SessionSummary',
                              queryParameters: {'sessionId': s.id},
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Leaderboard ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildLeaderboard(context, theme),
            ),

            // ── Upcoming Events ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildEvents(context, theme),
            ),

            // ── Bottom padding for nav bar ────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const SXBrandText(fontSize: 22),
          const Spacer(),
          // Bell with unread dot
          GestureDetector(
            onTap: () => context.pushNamed('Notifications'),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.75),
                    size: 18,
                  ),
                ),
                // Unread badge dot
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.primaryBackground, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          GestureDetector(
            onTap: () => context.pushNamed(
              'UserProfile',
              queryParameters: {'userId': currentUserUid},
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor),
              ),
              child: ClipOval(
                child: _user?.profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: _user!.profileImg!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(0.5),
                          size: 18,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Leaderboard ────────────────────────────────────────────────────────────

  Widget _buildLeaderboard(BuildContext context, FlutterFlowTheme theme) {
    return SXCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Top Shooters',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed('Leaderboard'),
                child: Text(
                  'Full Board',
                  style: GoogleFonts.inter(
                    color: theme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_board.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No leaderboard data yet.',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            )
          else
            ...List.generate(_board.length, (i) {
              final entry = _board[i];
              final isMe = entry.userId == currentUserUid;
              final lvl = entry.level ?? (entry.xp ?? 0) ~/ 1600;
              final rank = getRank(lvl);
              return Column(
                children: [
                  _LeaderboardRow(
                    position: entry.rank ?? (i + 1),
                    rankInfo: rank,
                    name: entry.displayName ?? 'Unknown',
                    level: lvl,
                    xpLabel: _fmtXp(entry.xp),
                    timeLabel:
                        '${(entry.score ?? 0).toStringAsFixed(0)}%',
                    profileImg: entry.profileImg,
                    isMe: isMe,
                    theme: theme,
                    onTap: isMe
                        ? null
                        : () => context.pushNamed(
                              'UserProfile',
                              queryParameters: {
                                'userId': entry.userId ?? '',
                                'displayName': entry.displayName ?? '',
                              },
                            ),
                  ),
                  if (i < _board.length - 1)
                    Divider(height: 1, color: theme.borderColor),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ── Upcoming Events ────────────────────────────────────────────────────────

  Widget _buildEvents(BuildContext context, FlutterFlowTheme theme) {
    if (!_loading && _events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SXSectionTitle(label: 'Upcoming Events'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          ..._events.map(
            (ev) => _EventTile(
              event: ev,
              dateLabel: _eventDateLine(ev),
              theme: theme,
              onTap: () => context.pushNamed(
                'EventDetails',
                queryParameters: {'eventId': ev.id},
              ),
            ),
          ),
      ],
    );
  }
}

// ─── SESSION CARD ─────────────────────────────────────────────────────────────
// Uses discipline gradient + icon from getDisciplineTheme instead of plain tint.

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.badge,
    required this.date,
    required this.disciplineTheme,
    this.onTap,
  });
  final SessionsRow session;
  final String badge;
  final String date;
  final DisciplineTheme disciplineTheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dt = disciplineTheme;
    final score =
        '${(session.accuracy ?? 0).toStringAsFixed(0)}%';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient hero
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: dt.grad,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Center(
                    child: Icon(dt.icon, color: dt.accent, size: 28),
                  ),
                ),
                // Badge
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        color: badge == 'PB'
                            ? theme.primary
                            : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.location ??
                        session.discipline ??
                        '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    score,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LEADERBOARD ROW ──────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.position,
    required this.rankInfo,
    required this.name,
    required this.level,
    required this.xpLabel,
    required this.timeLabel,
    required this.isMe,
    required this.theme,
    this.profileImg,
    this.onTap,
  });
  final int position;
  final RankInfo rankInfo;
  final String name;
  final int level;
  final String xpLabel;
  final String timeLabel;
  final bool isMe;
  final FlutterFlowTheme theme;
  final String? profileImg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isMe
            ? theme.primary.withOpacity(0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 22,
              child: Text(
                '$position',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Rank icon
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: rankInfo.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(rankInfo.icon, color: rankInfo.color, size: 12),
            ),
            const SizedBox(width: 8),
            // Avatar
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: profileImg!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 13,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 13,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Name + level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe ? '$name (you)' : name,
                    style: GoogleFonts.inter(
                      color: isMe ? theme.primary : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${rankInfo.label} · Lvl $level',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // XP
            Text(
              xpLabel,
              style: GoogleFonts.inter(
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            // Score/time
            Text(
              timeLabel,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EVENT TILE ───────────────────────────────────────────────────────────────

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.dateLabel,
    required this.theme,
    this.onTap,
  });
  final EventsRow event;
  final String dateLabel;
  final FlutterFlowTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.calendar_month_rounded,
                  color: theme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (event.discipline?.isNotEmpty == true)
                    Text(
                      event.discipline!,
                      style: GoogleFonts.inter(
                        color: theme.primary,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 1),
                  Text(
                    dateLabel,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25), size: 18),
          ],
        ),
      ),
    );
  }
}
