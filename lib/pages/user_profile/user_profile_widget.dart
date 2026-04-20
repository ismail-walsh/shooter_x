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
import '/pages/onboarding/onboarding_widget.dart';

// ─── Achievement definitions ──────────────────────────────────────────────────

class _AchievementDef {
  const _AchievementDef({
    required this.key,
    required this.label,
    required this.desc,
    required this.icon,
  });
  final String key;   // matches achievements.name (case-insensitive)
  final String label;
  final String desc;
  final IconData icon;
}

const _kAchievements = [
  _AchievementDef(
    key: 'First Blood',
    label: 'First Blood',
    desc: 'Complete your first session',
    icon: Icons.adjust_rounded,
  ),
  _AchievementDef(
    key: 'Sharp Shooter',
    label: 'Sharp Shooter',
    desc: 'Score 90%+ in a session',
    icon: Icons.emoji_events_rounded,
  ),
  _AchievementDef(
    key: 'On Fire',
    label: 'On Fire',
    desc: 'Hit a 4-week streak',
    icon: Icons.local_fire_department_rounded,
  ),
  _AchievementDef(
    key: 'Century Club',
    label: 'Century Club',
    desc: 'Log 100 sessions',
    icon: Icons.numbers_rounded,
  ),
  _AchievementDef(
    key: 'Club Captain',
    label: 'Club Captain',
    desc: 'Enter a competition',
    icon: Icons.military_tech_rounded,
  ),
  _AchievementDef(
    key: 'Sniper Elite',
    label: 'Sniper Elite',
    desc: 'Hit the X-ring 10 times',
    icon: Icons.gps_fixed_rounded,
  ),
];

// ─── Widget ───────────────────────────────────────────────────────────────────

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key, this.userId, this.displayName});
  final String? userId;
  final String? displayName;

  static const String routeName = 'UserProfile';
  static const String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool _loading = true;

  UsersRow? _user;

  // Stats
  int _sessionCount = 0;
  double _avgScore = 0;
  double _personalBest = 0;
  int _leaderboardRank = 0;

  // Gamification
  int _currentStreak = 0;
  int _bestStreak = 0;

  // Achievements
  Set<String> _earnedNames = {};

  // Club
  String? _primaryClubName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = currentUserUid;
    try {
    final results = await Future.wait([
      databaseService.getCurrentUserProfile().catchError((_) => null),
      databaseService.getUserSessions().catchError((_) => <SessionsRow>[]),
      databaseService
          .getLeaderboardByScope('overall')
          .catchError((_) => <LeaderboardEntriesRow>[]),
      UserAchievementsTable()
          .queryRows(queryFn: (q) => q.eq('user_id', uid))
          .catchError((_) => <UserAchievementsRow>[]),
      AchievementsTable()
          .queryRows(queryFn: (q) => q)
          .catchError((_) => <AchievementsRow>[]),
      SupaFlow.client
          .from('user_streaks')
          .select()
          .eq('user_id', uid)
          .maybeSingle()
          .catchError((_) => null),
      databaseService.getUserClubs().catchError((_) => <ClubsRow>[]),
    ]).timeout(const Duration(seconds: 12), onTimeout: () => [
      null, <SessionsRow>[], <LeaderboardEntriesRow>[], <UserAchievementsRow>[],
      <AchievementsRow>[], null, <ClubsRow>[],
    ]);

    if (!mounted) return;

    final user = results[0] as UsersRow?;
    final sessions = results[1] as List<SessionsRow>;
    final board = results[2] as List<LeaderboardEntriesRow>;
    final userAch = results[3] as List<UserAchievementsRow>;
    final allAch = results[4] as List<AchievementsRow>;
    final streak = results[5] as Map<String, dynamic>?;
    final clubs = results[6] as List<ClubsRow>;

    // Compute stats
    final count = sessions.length;
    double avg = 0;
    double pb = 0;
    for (final s in sessions) {
      final acc = s.accuracy ?? 0;
      avg += acc;
      if (acc > pb) pb = acc;
    }
    if (count > 0) avg = avg / count;

    int rank = 0;
    for (int i = 0; i < board.length; i++) {
      if (board[i].userId == uid) {
        rank = board[i].rank ?? (i + 1);
        break;
      }
    }

    final achById = {for (final a in allAch) a.id: a.name};
    final earnedNames = userAch
        .map((ua) =>
            ua.achievementId != null ? achById[ua.achievementId!] : null)
        .whereType<String>()
        .map((n) => n.toLowerCase())
        .toSet();

    setState(() {
      _user = user;
      _sessionCount = count;
      _avgScore = avg;
      _personalBest = pb;
      _leaderboardRank = rank;
      _currentStreak = (streak?['current_streak'] as int?) ?? 0;
      _bestStreak = (streak?['best_streak'] as int?) ?? 0;
      _earnedNames = earnedNames;
      _primaryClubName = clubs.isNotEmpty ? clubs.first.name : null;
      _loading = false;
    });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            FlutterFlowTheme.of(context).secondaryBackground,
        title: Text(
          'Sign Out',
          style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out',
                style: GoogleFonts.inter(
                    color: const Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await authManager.signOut();
    if (!mounted) return;
    context.goNamed(OnboardingWidget.routeName);
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  int get _level => _user?.level ?? 0;
  int get _xp => _user?.totalXp ?? 0;
  int get _xpMax => 500 + _level * 100;
  bool _isEarned(_AchievementDef def) =>
      _earnedNames.contains(def.key.toLowerCase());

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final rank = getRank(_level);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: const Center(
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildBackHeader(context, theme)),
            SliverToBoxAdapter(
                child: _buildAvatarSection(context, theme, rank)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SXRankXPBar(
                    level: _level, xp: _xp, xpMax: _xpMax),
              ),
            ),
            SliverToBoxAdapter(
                child: _buildStatsRow(context, theme)),
            SliverToBoxAdapter(
              child: SXStreakCard(
                  streak: _currentStreak, bestStreak: _bestStreak),
            ),
            const SliverToBoxAdapter(child: SXActivityHeatmap()),
            SliverToBoxAdapter(
                child: _buildAchievements(context, theme)),
            SliverToBoxAdapter(child: _buildMenu(context, theme)),
            SliverToBoxAdapter(
                child: _buildSignOut(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ── Back header ───────────────────────────────────────────────────────────

  Widget _buildBackHeader(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      color: theme.primaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left_rounded,
                      color: theme.primary, size: 24),
                  Text(
                    'Back',
                    style: GoogleFonts.inter(
                      color: theme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'My Profile',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.pushNamed('EditProfile'),
              child: Text(
                'Settings',
                style: GoogleFonts.inter(
                  color: theme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar section ────────────────────────────────────────────────────────

  Widget _buildAvatarSection(
      BuildContext context, FlutterFlowTheme theme, RankInfo rank) {
    final name = _user?.fullName ??
        _user?.username ??
        widget.displayName ??
        'Shooter';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Avatar + rank badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient border ring
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.primary, const Color(0xFF006E2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryBackground,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: _user?.profileImg?.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: _user!.profileImg!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _avatarFallback(theme),
                          )
                        : _avatarFallback(theme),
                  ),
                ),
              ),
              // Rank badge
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: rank.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: rank.color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rank.icon, color: rank.color, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        'Lv $_level',
                        style: GoogleFonts.inter(
                          color: rank.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rank.label,
            style: GoogleFonts.inter(
              color: rank.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentStreak > 0)
                _Pill(
                  icon: Icons.local_fire_department_rounded,
                  label: '$_currentStreak Week Streak',
                  accent: const Color(0xFFF97316),
                ),
              if (_currentStreak > 0 && _primaryClubName != null)
                const SizedBox(width: 8),
              if (_primaryClubName != null)
                _Pill(
                  icon: Icons.groups_rounded,
                  label: _primaryClubName!,
                  accent: theme.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(FlutterFlowTheme theme) => Container(
        width: 80,
        height: 80,
        color: theme.alternate,
        child: Icon(Icons.person_rounded,
            color: Colors.white.withOpacity(0.4), size: 36),
      );

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, FlutterFlowTheme theme) {
    final items = [
      ('$_sessionCount', 'Sessions'),
      (
        _avgScore > 0 ? '${_avgScore.toStringAsFixed(0)}%' : '—',
        'Avg'
      ),
      (
        _personalBest > 0
            ? '${_personalBest.toStringAsFixed(0)}%'
            : '—',
        'PB'
      ),
      (_leaderboardRank > 0 ? '#$_leaderboardRank' : '—', 'Rank'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  right: i < items.length - 1
                      ? BorderSide(color: theme.borderColor)
                      : BorderSide.none,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    item.$1,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$2,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Achievements ──────────────────────────────────────────────────────────

  Widget _buildAchievements(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SXSectionTitle(label: 'Achievements'),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: _kAchievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final def = _kAchievements[i];
              return _AchievementCard(
                def: def,
                earned: _isEarned(def),
                theme: theme,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Menu ──────────────────────────────────────────────────────────────────

  Widget _buildMenu(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: [
          _MenuRow(
            icon: Icons.history_rounded,
            label: 'My Sessions',
            theme: theme,
            showDivider: true,
            onTap: () => context.pushNamed('AllSessions'),
          ),
          _MenuRow(
            icon: Icons.leaderboard_rounded,
            label: 'Leaderboard',
            theme: theme,
            showDivider: true,
            onTap: () => context.pushNamed('Leaderboard'),
          ),
          _MenuRow(
            icon: Icons.settings_rounded,
            label: 'Settings',
            theme: theme,
            showDivider: false,
            onTap: () => context.pushNamed('EditProfile'),
          ),
        ],
      ),
    );
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Widget _buildSignOut(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: _signOut,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.25)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 17),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: const Color(0xFFEF4444),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PILL ─────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACHIEVEMENT CARD ─────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.def,
    required this.earned,
    required this.theme,
  });
  final _AchievementDef def;
  final bool earned;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3DD162);

    return Opacity(
      opacity: earned ? 1.0 : 0.38,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: earned
                ? green.withOpacity(0.4)
                : theme.borderColor,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: earned
                        ? green.withOpacity(0.12)
                        : theme.alternate,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    def.icon,
                    color: earned
                        ? green
                        : Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
              child: Text(
                def.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                def.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 9,
                  height: 1.3,
                ),
              ),
            ),
            // Green accent line (earned) or blank gap (unearned)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: earned ? green : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MENU ROW ─────────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
    required this.showDivider,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final FlutterFlowTheme theme;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon,
                      color: Colors.white.withOpacity(0.65), size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.25), size: 18),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.borderColor,
            indent: 62,
            endIndent: 16,
          ),
      ],
    );
  }
}
