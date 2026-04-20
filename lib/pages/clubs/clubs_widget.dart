import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import '/utils/sx_discipline_theme.dart';
import '/utils/sx_ranks.dart';

class ClubsWidget extends StatefulWidget {
  const ClubsWidget({super.key});
  static const String routeName = 'Clubs';
  static const String routePath = '/clubs';

  @override
  State<ClubsWidget> createState() => _ClubsWidgetState();
}

class _ClubsWidgetState extends State<ClubsWidget> {
  // Loading flags
  bool _loadingBase = true;
  bool _loadingClub = false;

  // Base data
  List<ClubsRow> _myClubs = [];
  List<ClubsRow> _discoverClubs = [];
  Set<String> _myClubIds = {};
  UsersRow? _user;

  // Active club
  String? _activeClubId;
  ClubsRow? get _activeClub =>
      _myClubs.isEmpty ? null : _myClubs.firstWhere(
        (c) => c.id == (_activeClubId ?? _myClubs.first.id),
        orElse: () => _myClubs.first,
      );

  // Active club detail
  int _memberCount = 0;
  List<ClubPostsRow> _posts = [];
  List<EventsRow> _events = [];
  List<EventsRow> _competitions = [];
  List<LeaderboardEntriesRow> _leaderboard = [];
  Map<String, UsersRow> _authorCache = {};

  @override
  void initState() {
    super.initState();
    _loadBase();
  }

  // ── Base load (memberships + discover) ────────────────────────────────────

  Future<void> _loadBase() async {
    try {
      final results = await Future.wait([
        databaseService.getCurrentUserProfile().catchError((_) => null),
        databaseService.getUserClubs().catchError((_) => <ClubsRow>[]),
        databaseService.getAllClubs().catchError((_) => <ClubsRow>[]),
      ]).timeout(const Duration(seconds: 12),
          onTimeout: () => [null, <ClubsRow>[], <ClubsRow>[]]);

      if (!mounted) return;

      final myClubs = results[1] as List<ClubsRow>;
      final allClubs = results[2] as List<ClubsRow>;
      final myIds = myClubs.map((c) => c.id).toSet();

      setState(() {
        _user = results[0] as UsersRow?;
        _myClubs = myClubs;
        _myClubIds = myIds;
        _discoverClubs =
            allClubs.where((c) => !myIds.contains(c.id)).take(8).toList();
        _loadingBase = false;
        if (myClubs.isNotEmpty) _activeClubId = myClubs.first.id;
      });

      if (myClubs.isNotEmpty) {
        _loadClubDetail(myClubs.first.id);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBase = false);
    }
  }

  // ── Club detail load ──────────────────────────────────────────────────────

  Future<void> _loadClubDetail(String clubId) async {
    if (!mounted) return;
    setState(() => _loadingClub = true);

    final results = await Future.wait([
      // Member count
      ClubMembershipsTable()
          .queryRows(queryFn: (q) => q.eq('club_id', clubId))
          .catchError((_) => <ClubMembershipsRow>[]),
      // Posts
      ClubPostsTable()
          .queryRows(
            queryFn: (q) =>
                q.eq('club_id', clubId).order('created_at').limit(2),
          )
          .catchError((_) => <ClubPostsRow>[]),
      // Events (upcoming)
      EventsTable()
          .queryRows(
            queryFn: (q) => q
                .eq('club_id', clubId)
                .order('date')
                .limit(5),
          )
          .catchError((_) => <EventsRow>[]),
      // Leaderboard (overall — no club_id column on leaderboard_entries)
      databaseService
          .getLeaderboardByScope('overall')
          .catchError((_) => <LeaderboardEntriesRow>[]),
    ]);

    if (!mounted) return;

    final memberships = results[0] as List<ClubMembershipsRow>;
    final posts = results[1] as List<ClubPostsRow>;
    final allEvents = results[2] as List<EventsRow>;
    final board = results[3] as List<LeaderboardEntriesRow>;

    // Split events vs competitions
    final upcoming = allEvents
        .where((e) =>
            e.status != 'live' &&
            (e.date == null || e.date!.isAfter(DateTime.now())))
        .take(3)
        .toList();
    final comps = allEvents
        .where((e) =>
            e.status == 'live' ||
            e.status == 'open' ||
            e.status == 'upcoming')
        .take(4)
        .toList();

    // Fetch post authors
    final authorIds = posts
        .map((p) => p.createdBy)
        .whereType<String>()
        .where((id) => id != currentUserUid)
        .toSet()
        .toList();
    Map<String, UsersRow> authorMap = {};
    if (authorIds.isNotEmpty) {
      final authors = await UsersTable()
          .queryRows(queryFn: (q) => q.inFilter('id', authorIds))
          .catchError((_) => <UsersRow>[]);
      authorMap = {for (final u in authors) u.id: u};
    }

    if (!mounted) return;
    setState(() {
      _memberCount = memberships.length;
      _posts = posts;
      _events = upcoming;
      _competitions = comps;
      _leaderboard = board.take(4).toList();
      _authorCache = authorMap;
      _loadingClub = false;
    });
  }

  void _switchClub(String clubId) {
    if (clubId == _activeClubId) return;
    setState(() => _activeClubId = clubId);
    _loadClubDetail(clubId);
  }

  Future<void> _joinClub(ClubsRow club) async {
    try {
      await databaseService.joinClub(club.id);
      if (!mounted) return;
      setState(() {
        _myClubs = [..._myClubs, club];
        _myClubIds = {..._myClubIds, club.id};
        _discoverClubs = _discoverClubs.where((c) => c.id != club.id).toList();
        _activeClubId = club.id;
      });
      _loadClubDetail(club.id);
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _relTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  static String _fmtEventDate(EventsRow e) {
    if (e.date == null) return 'Date TBC';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = e.date!;
    return '${d.day} ${m[d.month - 1]}';
  }

  static String _fmtXp(int? xp) {
    if (xp == null) return '0 XP';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }

  // ── Root build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_loadingBase) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, theme)),
            if (_discoverClubs.isNotEmpty)
              SliverToBoxAdapter(
                  child: _buildDiscoverSection(context, theme)),
            if (_myClubs.length > 1)
              SliverToBoxAdapter(child: _buildMyClubPills(context, theme)),
            if (_myClubs.isNotEmpty) ...[
              SliverToBoxAdapter(
                  child: _buildActiveClubCard(context, theme)),
              SliverToBoxAdapter(
                  child: _buildClubFeed(context, theme)),
              SliverToBoxAdapter(
                  child: _buildUpcomingEvents(context, theme)),
              SliverToBoxAdapter(
                  child: _buildClubLeaderboard(context, theme)),
              SliverToBoxAdapter(
                  child: _buildClubCompetitions(context, theme)),
            ] else
              SliverToBoxAdapter(child: _buildNoClubs(context, theme)),
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
          Text(
            'Clubs',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pushNamed('FindClubs'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(Icons.search_rounded,
                  color: Colors.white.withOpacity(0.7), size: 18),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.pushNamed('UserProfile',
                queryParameters: {'userId': currentUserUid}),
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
                        errorWidget: (_, __, ___) => _avatarIcon(),
                      )
                    : _avatarIcon(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarIcon() => Icon(Icons.person_rounded,
      color: Colors.white.withOpacity(0.45), size: 17);

  // ── Discover Clubs ────────────────────────────────────────────────────────

  Widget _buildDiscoverSection(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(label: 'Discover Clubs'),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: _discoverClubs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) =>
                _DiscoverCard(
                  club: _discoverClubs[i],
                  theme: theme,
                  onJoin: () => _joinClub(_discoverClubs[i]),
                ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── My Club Pills ─────────────────────────────────────────────────────────

  Widget _buildMyClubPills(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SXSectionTitle(label: 'My Clubs'),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _myClubs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final club = _myClubs[i];
              final active = club.id ==
                  (_activeClubId ?? _myClubs.first.id);
              return GestureDetector(
                onTap: () => _switchClub(club.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active ? theme.primary : theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ? theme.primary
                          : theme.borderColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    club.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Active Club Card ──────────────────────────────────────────────────────

  Widget _buildActiveClubCard(BuildContext context, FlutterFlowTheme theme) {
    final club = _activeClub;
    if (club == null) return const SizedBox.shrink();
    final dt = getDisciplineTheme(club.discipline ?? '');

    return GestureDetector(
      onTap: () => context.pushNamed('ClubProfile',
          queryParameters: {'clubId': club.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          children: [
            // ── Banner ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dt.accent.withOpacity(0.18),
                    dt.accent.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Club icon / avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: dt.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: club.profileImg?.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: CachedNetworkImage(
                              imageUrl: club.profileImg!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  Icon(dt.icon, color: dt.accent, size: 26),
                            ),
                          )
                        : Icon(dt.icon, color: dt.accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (club.discipline?.isNotEmpty == true)
                          Text(
                            club.discipline!,
                            style: GoogleFonts.inter(
                              color: dt.accent,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // MEMBER badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: theme.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          'MEMBER',
                          style: GoogleFonts.inter(
                            color: theme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (!_loadingClub)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$_memberCount members',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Stats row ───────────────────────────────────────────────
            if (!_loadingClub)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: theme.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    _StatCol(
                        value: '$_memberCount',
                        label: 'Members',
                        theme: theme),
                    _Divider(theme: theme),
                    _StatCol(
                        value:
                            '${_events.length}',
                        label: 'Upcoming',
                        theme: theme),
                    _Divider(theme: theme),
                    _StatCol(
                        value: _competitions
                            .where((e) =>
                                e.date?.month == DateTime.now().month)
                            .length
                            .toString(),
                        label: 'Events / mo',
                        theme: theme),
                  ],
                ),
              ),

            // ── Action grid ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.badge_rounded,
                    label: 'Membership',
                    accent: dt.accent,
                    theme: theme,
                    onTap: () =>
                        context.pushNamed('MembershipCard',
                            queryParameters: {'clubId': club.id}),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.calendar_month_rounded,
                    label: 'Schedule',
                    accent: dt.accent,
                    theme: theme,
                    onTap: () => context.pushNamed('EventCard',
                        queryParameters: {'clubId': club.id}),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.location_on_rounded,
                    label: 'Find Range',
                    accent: dt.accent,
                    theme: theme,
                    onTap: () => context.pushNamed('FindRange'),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.emoji_events_rounded,
                    label: 'Compete',
                    accent: dt.accent,
                    theme: theme,
                    onTap: () {
                      final next = _competitions.isNotEmpty
                          ? _competitions.first
                          : null;
                      if (next != null) {
                        context.pushNamed('EventDetails',
                            queryParameters: {'eventId': next.id});
                      } else {
                        context.pushNamed('EventCard',
                            queryParameters: {'clubId': club.id});
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Club Feed ─────────────────────────────────────────────────────────────

  Widget _buildClubFeed(BuildContext context, FlutterFlowTheme theme) {
    final club = _activeClub;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(
          label: 'Club Feed',
          actionLabel: 'See All',
          onAction: () => club == null
              ? null
              : context.pushNamed('ClubProfile',
                  queryParameters: {'clubId': club.id}),
        ),
        if (_loadingClub)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_posts.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'No posts yet.',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
          )
        else
          ..._posts.map((p) => _PostTile(
                post: p,
                author: _authorCache[p.createdBy],
                isOwn: p.createdBy == currentUserUid,
                theme: theme,
              )),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Upcoming Events ───────────────────────────────────────────────────────

  Widget _buildUpcomingEvents(BuildContext context, FlutterFlowTheme theme) {
    final club = _activeClub;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(
          label: 'Upcoming Events',
          actionLabel: 'All',
          onAction: () => club == null
              ? null
              : context.pushNamed('EventCard',
                  queryParameters: {'clubId': club.id}),
        ),
        if (_loadingClub)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_events.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'No upcoming events.',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
          )
        else
          ..._events.map((e) => _EventTile(
                event: e,
                dateLabel: _fmtEventDate(e),
                theme: theme,
                onTap: () => context.pushNamed('EventDetails',
                    queryParameters: {'eventId': e.id}),
              )),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Club Leaderboard ──────────────────────────────────────────────────────

  Widget _buildClubLeaderboard(BuildContext context, FlutterFlowTheme theme) {
    final club = _activeClub;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(
          label: 'Club Leaderboard',
          actionLabel: 'Full Board',
          onAction: () => context.pushNamed('Leaderboard'),
        ),
        if (_loadingClub)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_leaderboard.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'No leaderboard data yet.',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
          )
        else
          SXCard(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: _leaderboard.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final isMe = r.userId == currentUserUid;
                final lvl = r.level ?? (r.xp ?? 0) ~/ 1600;
                final rank = getRank(lvl);
                return Column(
                  children: [
                    _LeaderboardRow(
                      position: r.rank ?? (i + 1),
                      rankInfo: rank,
                      name: r.displayName ?? 'Unknown',
                      level: lvl,
                      xpLabel: _fmtXp(r.xp),
                      scoreLabel:
                          '${(r.score ?? 0).toStringAsFixed(0)}%',
                      profileImg: r.profileImg,
                      isMe: isMe,
                      theme: theme,
                      onTap: isMe
                          ? null
                          : () => context.pushNamed('UserProfile',
                                queryParameters: {
                                  'userId': r.userId ?? '',
                                  'displayName': r.displayName ?? '',
                                }),
                    ),
                    if (i < _leaderboard.length - 1)
                      Divider(height: 1, color: theme.borderColor),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ── Club Competitions ─────────────────────────────────────────────────────

  Widget _buildClubCompetitions(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(
          label: 'Club Competitions',
          actionLabel: 'All',
          onAction: () => context.pushNamed('EventCard'),
        ),
        if (_loadingClub)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_competitions.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'No competitions scheduled.',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
          )
        else
          ..._competitions.map((e) {
            final isLive = e.status == 'live';
            return GestureDetector(
              onTap: () => context.pushNamed('EventDetails',
                  queryParameters: {'eventId': e.id}),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isLive
                        ? theme.primary.withOpacity(0.35)
                        : theme.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLive
                            ? theme.primary.withOpacity(0.12)
                            : theme.alternate,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: isLive
                            ? theme.primary
                            : Colors.white.withOpacity(0.4),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.name,
                            style: GoogleFonts.interTight(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtEventDate(e),
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLive) ...[
                      const SXLiveBadge(),
                      const SizedBox(width: 6),
                    ] else if (e.status != null) ...[
                      _StatusPill(status: e.status!, theme: theme),
                      const SizedBox(width: 6),
                    ],
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.25), size: 18),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── No clubs empty state ──────────────────────────────────────────────────

  Widget _buildNoClubs(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          Icon(Icons.groups_rounded,
              color: Colors.white.withOpacity(0.2), size: 48),
          const SizedBox(height: 12),
          Text(
            "You haven't joined any clubs yet.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
          const SizedBox(height: 16),
          SXGreenButton(
            label: 'Find a Club',
            height: 44,
            onTap: () => context.pushNamed('FindClubs'),
          ),
        ],
      ),
    );
  }
}

// ─── DISCOVER CARD ────────────────────────────────────────────────────────────

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.club,
    required this.theme,
    required this.onJoin,
  });
  final ClubsRow club;
  final FlutterFlowTheme theme;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final dt = getDisciplineTheme(club.discipline ?? '');

    return Container(
      width: 148,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            height: 78,
            decoration: BoxDecoration(
              gradient: dt.grad,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(dt.icon, color: dt.accent, size: 30)),
                if (club.isPrivate == true)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(Icons.lock_rounded,
                          color: Colors.white.withOpacity(0.6), size: 10),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  club.discipline ?? 'Shooting Club',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      color: dt.accent, fontSize: 10),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onJoin,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Join Club',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACTIVE CLUB ACTION BUTTON ────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.accent,
    required this.theme,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color accent;
  final FlutterFlowTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAT COLUMN ─────────────────────────────────────────────────────────────

class _StatCol extends StatelessWidget {
  const _StatCol({
    required this.value,
    required this.label,
    required this.theme,
  });
  final String value;
  final String label;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.45),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.theme});
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: theme.borderColor,
    );
  }
}

// ─── POST TILE ────────────────────────────────────────────────────────────────

class _PostTile extends StatelessWidget {
  const _PostTile({
    required this.post,
    required this.isOwn,
    required this.theme,
    this.author,
  });
  final ClubPostsRow post;
  final UsersRow? author;
  final bool isOwn;
  final FlutterFlowTheme theme;

  static String _relTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        isOwn ? 'You' : (author?.username ?? 'Member');
    final handle = isOwn
        ? '@you'
        : '@${author?.username ?? post.createdBy?.substring(0, 6) ?? 'member'}';
    final avatarUrl = isOwn ? null : author?.profileImg;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: avatarUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            color: Colors.white.withOpacity(0.4),
                            size: 16,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: isOwn
                              ? theme.primary
                              : Colors.white.withOpacity(0.4),
                          size: 16,
                        ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        color: isOwn ? theme.primary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      handle,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _relTime(post.createdAt),
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
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
    final spotsLeft = event.maxParticipants;

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_month_rounded,
                  color: theme.primary, size: 20),
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
            if (spotsLeft != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: spotsLeft == 0
                      ? Colors.red.withOpacity(0.12)
                      : theme.alternate,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  spotsLeft == 0 ? 'FULL' : '$spotsLeft spots',
                  style: GoogleFonts.inter(
                    color: spotsLeft == 0
                        ? const Color(0xFFEF4444)
                        : Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── STATUS PILL ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.theme});
  final String status;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    final label = status[0].toUpperCase() + status.substring(1);
    final isOpen = status == 'open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? theme.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isOpen ? theme.primary : Colors.white.withOpacity(0.55),
          fontSize: 10,
          fontWeight: FontWeight.w600,
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
    required this.scoreLabel,
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
  final String scoreLabel;
  final bool isMe;
  final FlutterFlowTheme theme;
  final String? profileImg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color:
            isMe ? theme.primary.withOpacity(0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
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
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: rankInfo.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child:
                  Icon(rankInfo.icon, color: rankInfo.color, size: 11),
            ),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: theme.alternate, shape: BoxShape.circle),
              child: ClipOval(
                child: profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: profileImg!,
                        width: 26,
                        height: 26,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 12,
                        ),
                      )
                    : Icon(Icons.person_rounded,
                        color: Colors.white.withOpacity(0.4), size: 12),
              ),
            ),
            const SizedBox(width: 8),
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
            Text(
              xpLabel,
              style: GoogleFonts.inter(
                color: theme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              scoreLabel,
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
