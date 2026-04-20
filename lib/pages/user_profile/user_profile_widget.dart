import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/index.dart';
import '/services/database_service.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

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
  // ignore: unused_field
  late UserProfileModel _model;

  bool _loading = true;
  bool _followLoading = false;

  UsersRow? _user;
  List<SessionsRow> _sessions = [];
  List<AchievementsRow> _allAchievements = [];
  Set<String> _earnedIds = {};

  // Follow counts (best-effort — table may not exist yet)
  int _followers = 0;
  int _following = 0;
  bool _isFollowing = false;

  bool get _isOwn => (widget.userId ?? currentUserUid) == currentUserUid;
  String get _uid => widget.userId ?? currentUserUid ?? '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
    _load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _load() async {
    if (_uid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        databaseService.getUserById(_uid).catchError((_) => null),
        SessionsTable().queryRows(
          queryFn: (q) => q
              .eqOrNull('user_id', _uid)
              .order('created_at', ascending: false)
              .limit(5),
        ).catchError((_) => <SessionsRow>[]),
        AchievementsTable().queryRows(
          queryFn: (q) => q.order('name'),
        ).catchError((_) => <AchievementsRow>[]),
        UserAchievementsTable().queryRows(
          queryFn: (q) => q.eqOrNull('user_id', _uid),
        ).catchError((_) => <UserAchievementsRow>[]),
        _loadFollowData(),
      ]);

      final user = results[0] as UsersRow?;
      final sessions = results[1] as List<SessionsRow>;
      final allAch = results[2] as List<AchievementsRow>;
      final userAch = results[3] as List<UserAchievementsRow>;

      if (mounted) {
        setState(() {
          _user = user;
          _sessions = sessions;
          _allAchievements = allAch;
          _earnedIds =
              userAch.map((r) => r.achievementId ?? '').toSet();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadFollowData() async {
    try {
      final client = SupaFlow.client;
      final followersRes = await client
          .from('follows')
          .select('id')
          .eq('following_id', _uid);
      final followingRes = await client
          .from('follows')
          .select('id')
          .eq('follower_id', _uid);

      int isFollowingCount = 0;
      if (!_isOwn && currentUserUid != null) {
        final r = await client
            .from('follows')
            .select('id')
            .eq('follower_id', currentUserUid!)
            .eq('following_id', _uid);
        isFollowingCount = (r as List).length;
      }

      if (mounted) {
        setState(() {
          _followers = (followersRes as List).length;
          _following = (followingRes as List).length;
          _isFollowing = isFollowingCount > 0;
        });
      }
    } catch (_) {
      // follows table may not exist yet — ignore
    }
  }

  Future<void> _toggleFollow() async {
    if (_followLoading || currentUserUid == null) return;
    setState(() => _followLoading = true);
    // Optimistic update
    setState(() {
      _isFollowing = !_isFollowing;
      _followers += _isFollowing ? 1 : -1;
    });
    try {
      final client = SupaFlow.client;
      if (_isFollowing) {
        await client.from('follows').insert({
          'follower_id': currentUserUid,
          'following_id': _uid,
        });
      } else {
        await client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserUid!)
            .eq('following_id', _uid);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _followers += _isFollowing ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(ctx).secondaryBackground,
        title: Text('Sign Out',
            style: GoogleFonts.interTight(color: Colors.white)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out',
                style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await authManager.signOut();
      if (mounted) context.goNamed(OnboardingWidget.routeName);
    }
  }

  // ── Stats helpers ─────────────────────────────────────────────────────────

  String get _avgScore {
    if (_sessions.isEmpty) return '—';
    final vals = _sessions
        .where((s) => s.accuracy != null)
        .map((s) => s.accuracy!)
        .toList();
    if (vals.isEmpty) return '—';
    return '${(vals.reduce((a, b) => a + b) / vals.length).toStringAsFixed(1)}%';
  }

  String get _personalBest {
    if (_sessions.isEmpty) return '—';
    final vals = _sessions
        .where((s) => s.accuracy != null)
        .map((s) => s.accuracy!)
        .toList();
    if (vals.isEmpty) return '—';
    return '${vals.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}%';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _user == null
                ? _buildNotFound(theme)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: CustomScrollView(slivers: [
                      SliverToBoxAdapter(child: _buildHeader(theme)),
                      SliverToBoxAdapter(child: _buildStatsRow(theme)),
                      SliverToBoxAdapter(child: _buildAchievements(theme)),
                      SliverToBoxAdapter(child: _buildSessions(theme)),
                      if (_isOwn)
                        SliverToBoxAdapter(child: _buildOwnMenu(theme)),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ]),
                  ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(FlutterFlowTheme theme) {
    final u = _user!;
    final name = (u.fullName?.isNotEmpty == true)
        ? u.fullName!
        : u.username;
    final handle = '@${u.username}';
    final levelStr = u.level != null ? 'Level ${u.level}' : '';
    final sub = [
      if (u.preferredDiscipline?.isNotEmpty == true) u.preferredDiscipline!,
      if (levelStr.isNotEmpty) levelStr,
    ].join(' · ');

    return Container(
      color: theme.secondaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back row
        Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const Spacer(),
          if (_isOwn)
            GestureDetector(
              onTap: () => context.pushNamed('EditProfile'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.7), size: 17),
              ),
            ),
        ]),
        const SizedBox(height: 16),
        // Avatar + name
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Avatar(user: u, isOwn: _isOwn, size: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(name,
                    style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4)),
                const SizedBox(height: 3),
                Text(handle,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(sub,
                      style: GoogleFonts.inter(
                          color: theme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
                if (u.bio?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(u.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          height: 1.4)),
                ],
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // Followers / Following / Sessions row
        Row(children: [
          _StatPill(value: _followers.toString(), label: 'Followers'),
          const SizedBox(width: 20),
          _StatPill(value: _following.toString(), label: 'Following'),
          const SizedBox(width: 20),
          _StatPill(value: _sessions.length.toString(), label: 'Sessions'),
          const Spacer(),
          if (!_isOwn)
            GestureDetector(
              onTap: _toggleFollow,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: _isFollowing ? Colors.transparent : theme.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isFollowing
                        ? Colors.white.withOpacity(0.25)
                        : Colors.transparent,
                  ),
                ),
                child: _followLoading
                    ? SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: Colors.white))
                    : Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: GoogleFonts.inter(
                            color: _isFollowing
                                ? Colors.white.withOpacity(0.55)
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ]),
    );
  }

  // ── Stats 4-tile row ──────────────────────────────────────────────────────

  Widget _buildStatsRow(FlutterFlowTheme theme) {
    final xp = _user!.totalXp ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        _StatTile(label: 'Avg Score', value: _avgScore, theme: theme),
        const SizedBox(width: 8),
        _StatTile(label: 'Personal Best', value: _personalBest, theme: theme),
        const SizedBox(width: 8),
        _StatTile(
            label: 'XP',
            value: xp >= 1000 ? '${(xp / 1000).toStringAsFixed(1)}k' : '$xp',
            theme: theme),
        const SizedBox(width: 8),
        _StatTile(
            label: 'Sessions',
            value: _sessions.length.toString(),
            theme: theme),
      ]),
    );
  }

  // ── Achievements ──────────────────────────────────────────────────────────

  Widget _buildAchievements(FlutterFlowTheme theme) {
    if (_allAchievements.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text('Achievements',
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
      ),
      SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _allAchievements.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final a = _allAchievements[i];
            final earned = _earnedIds.contains(a.id);
            return Opacity(
              opacity: earned ? 1.0 : 0.35,
              child: Container(
                width: 110,
                decoration: BoxDecoration(
                  color: earned
                      ? theme.primary.withOpacity(0.1)
                      : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: earned
                        ? theme.primary.withOpacity(0.3)
                        : theme.borderColor,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: earned
                            ? theme.primary.withOpacity(0.15)
                            : theme.alternate,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        earned
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: earned ? theme.primary : Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    if (a.description != null) ...[
                      const SizedBox(height: 2),
                      Text(a.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 9,
                              height: 1.3)),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ── Recent Sessions ───────────────────────────────────────────────────────

  Widget _buildSessions(FlutterFlowTheme theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(children: [
          Text('Recent Sessions',
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          if (_isOwn && _sessions.isNotEmpty)
            GestureDetector(
              onTap: () => context.pushNamed('AllSessions'),
              child: Text('See All',
                  style: GoogleFonts.inter(
                      color: theme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
      if (_sessions.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('No sessions yet.',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13)),
        )
      else
        ...(_sessions.map((s) => _buildSessionRow(theme, s))),
    ]);
  }

  Widget _buildSessionRow(FlutterFlowTheme theme, SessionsRow s) {
    final date = s.createdAt != null
        ? DateFormat('d MMM y').format(s.createdAt!)
        : '';
    final score = s.accuracy != null
        ? '${s.accuracy!.toStringAsFixed(1)}%'
        : '${s.hits ?? 0}/${s.totalShots ?? 0}';
    final isBest = s.isPersonalBest == true;

    return GestureDetector(
      onTap: () => context.pushNamed('SessionSummary',
          queryParameters: {'sessionId': s.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBest ? theme.primary.withOpacity(0.3) : theme.borderColor,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.gps_fixed_rounded,
                color: theme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(s.discipline ?? s.location ?? 'Session',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('PB',
                          style: GoogleFonts.inter(
                              color: theme.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                ]),
                const SizedBox(height: 2),
                Text(
                  [
                    if (s.location?.isNotEmpty == true) s.location!,
                    if (date.isNotEmpty) date,
                  ].join(' · '),
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(score,
              style: GoogleFonts.interTight(
                  color: theme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }

  // ── Own profile menu ──────────────────────────────────────────────────────

  Widget _buildOwnMenu(FlutterFlowTheme theme) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.borderColor),
          ),
          child: Column(children: [
            _MenuRow(
              icon: Icons.fitness_center_rounded,
              label: 'My Sessions',
              onTap: () => context.pushNamed('AllSessions'),
              theme: theme,
              showDivider: true,
            ),
            _MenuRow(
              icon: Icons.leaderboard_rounded,
              label: 'Leaderboard',
              onTap: () => context.pushNamed('Leaderboard'),
              theme: theme,
              showDivider: true,
            ),
            _MenuRow(
              icon: Icons.settings_outlined,
              label: 'Edit Profile',
              onTap: () => context.pushNamed('EditProfile'),
              theme: theme,
              showDivider: false,
            ),
          ]),
        ),
      ),
      // Sign Out
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: GestureDetector(
          onTap: _signOut,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: Center(
              child: Text('Sign Out',
                  style: GoogleFonts.interTight(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Not found ─────────────────────────────────────────────────────────────

  Widget _buildNotFound(FlutterFlowTheme theme) {
    return Column(children: [
      SXBackHeader(title: 'Profile'),
      Expanded(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: theme.alternate, shape: BoxShape.circle),
              child: Icon(Icons.person_rounded,
                  color: Colors.white.withOpacity(0.3), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
                widget.displayName?.isNotEmpty == true
                    ? widget.displayName!
                    : 'Unknown User',
                style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Profile not available',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ]),
        ),
      ),
    ]);
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.user, required this.isOwn, required this.size});
  final UsersRow user;
  final bool isOwn;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final hasImg =
        user.profileImg != null && user.profileImg!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isOwn
            ? const LinearGradient(
                colors: [Color(0xFF3DD162), Color(0xFF006E2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isOwn ? null : theme.alternate,
      ),
      padding: isOwn ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
      child: ClipOval(
        child: hasImg
            ? CachedNetworkImage(
                imageUrl: user.profileImg!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(theme),
              )
            : _placeholder(theme),
      ),
    );
  }

  Widget _placeholder(FlutterFlowTheme theme) {
    return Container(
      color: theme.alternate,
      child: Icon(Icons.person_rounded,
          color: Colors.white.withOpacity(0.4), size: size * 0.45),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800)),
      Text(label,
          style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11)),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.label, required this.value, required this.theme});
  final String label;
  final String value;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

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
    return Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: theme.primary, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ]),
        ),
      ),
      if (showDivider) Divider(color: theme.borderColor, height: 1),
    ]);
  }
}
