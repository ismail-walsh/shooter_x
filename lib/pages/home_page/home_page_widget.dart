import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  static const String routeName = 'HomePage';
  static const String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  bool _loading = true;
  List<SessionsRow> _sessions = [];
  List<LeaderboardEntriesRow> _board = [];
  List<EventsRow> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Load each source independently — a failure in one won't blank the others.
    final results = await Future.wait([
      databaseService.getRecentSessions(limit: 3).catchError((_) => <SessionsRow>[]),
      databaseService.getLeaderboardByScope('overall').catchError((_) => <LeaderboardEntriesRow>[]),
      databaseService.getUpcomingEvents().catchError((_) => <EventsRow>[]),
    ]);
    if (mounted) {
      setState(() {
        _sessions = results[0] as List<SessionsRow>;
        _board = (results[1] as List<LeaderboardEntriesRow>).take(3).toList();
        _events = (results[2] as List<EventsRow>).take(3).toList();
        _loading = false;
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]}';
  }

  static String _badge(SessionsRow s) {
    if (s.isPersonalBest == true) return 'PB';
    final diff = DateTime.now().difference(s.createdAt ?? DateTime.now());
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 30).floor()}mo';
  }

  static String _score(SessionsRow s) =>
      '${(s.accuracy ?? 0).toStringAsFixed(0)}%';

  static const _tints = [
    Color(0xFF1E2A1E), Color(0xFF1E201E), Color(0xFF1A2020),
  ];

  static String _fmtXp(int? xp) {
    if (xp == null) return '0 XP';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }

  static String _eventDate(EventsRow e) {
    if (e.date == null) return e.location ?? '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${e.date!.day} ${m[e.date!.month - 1]} · ${e.location ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, theme)),
            SliverToBoxAdapter(child: _buildRecentSessions(context, theme)),
            SliverToBoxAdapter(child: _buildActionGrid(context, theme)),
            SliverToBoxAdapter(child: _buildLeaderboard(context, theme)),
            SliverToBoxAdapter(child: _buildEvents(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          SXBrandText(fontSize: 22),
          const Spacer(),
          SXIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => context.pushNamed('Notifications'),
          ),
          const SizedBox(width: 8),
          SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
              queryParameters: {'userId': currentUserUid})),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      children: [
        SXSectionTitle(
          label: 'Recent Sessions',
          actionLabel: 'See All',
          onAction: () => context.pushNamed('AllSessions'),
        ),
        if (_loading)
          const SizedBox(height: 152, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Text('No sessions yet — log your first shot!',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.4), fontSize: 13)),
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              itemCount: _sessions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final s = _sessions[i];
                return SXSessionCard(
                  date: _fmtDate(s.createdAt),
                  location: s.location ?? s.discipline ?? '—',
                  score: _score(s),
                  badge: _badge(s),
                  tintColor: _tints[i % _tints.length],
                  onTap: () => context.pushNamed('SessionSummary',
                      queryParameters: {'sessionId': s.id}),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          SXActionButton(label: 'Log Shot', icon: Icons.adjust_rounded,
              onTap: () => context.pushNamed('AddSession')),
          const SizedBox(width: 8),
          SXActionButton(label: 'Scan Target', icon: Icons.qr_code_scanner_rounded,
              onTap: () => context.pushNamed('ScanTarget')),
          const SizedBox(width: 8),
          SXActionButton(label: 'Find Range', icon: Icons.location_on_rounded,
              onTap: () => context.pushNamed('FindRange')),
          const SizedBox(width: 8),
          SXActionButton(label: 'Compete', icon: Icons.emoji_events_rounded,
              onTap: () => context.pushNamed('EventCard')),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, FlutterFlowTheme theme) {
    return SXCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              Text('OD Tactical Leaderboard',
                  style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.pushNamed('Leaderboard'),
                child: Text('Full Board',
                    style: GoogleFonts.inter(
                        color: theme.primary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_board.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No leaderboard data yet.',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4), fontSize: 12)),
            )
          else
            ...List.generate(_board.length, (i) {
              final r = _board[i];
              final isMe = r.userId == currentUserUid;
              return Column(
                children: [
                  SXLeaderboardRow(
                    rank: r.rank ?? (i + 1),
                    name: r.displayName ?? 'Unknown',
                    level: (r.xp ?? 0) ~/ 1600,
                    xp: _fmtXp(r.xp),
                    time: '${(r.score ?? 0).toStringAsFixed(0)}%',
                    profileImg: r.profileImg,
                    isMe: isMe,
                    onTap: isMe
                        ? null
                        : () => context.pushNamed('UserProfile',
                            queryParameters: {
                              'userId': r.userId ?? '',
                              'displayName': r.displayName ?? '',
                            }),
                  ),
                  if (i < _board.length - 1)
                    Divider(color: theme.borderColor, height: 1),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEvents(BuildContext context, FlutterFlowTheme theme) {
    if (_events.isEmpty && !_loading) return const SizedBox.shrink();
    return Column(
      children: [
        const SXSectionTitle(label: 'Upcoming Events'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          ..._events.map((ev) => SXEventTile(
                name: ev.name,
                subtitle: ev.discipline ?? ev.status ?? 'Event',
                detail: _eventDate(ev),
                onTap: () => context.pushNamed('EventDetails',
                    queryParameters: {'eventId': ev.id}),
              )),
      ],
    );
  }
}
