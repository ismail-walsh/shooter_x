// home_page_widget.dart
// Replaces lib/pages/home_page/home_page_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  static const String routeName = 'HomePage';
  static const String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  // TODO: Replace with real Supabase queries
  final _sessions = const [
    {'date': '14 Apr', 'location': 'OD Range – Marin', 'score': '96%', 'badge': 'PB', 'tint': Color(0xFF1E2A1E)},
    {'date': '31 Mar', 'location': 'SD Clay – Breather', 'score': '87%', 'badge': '12d ago', 'tint': Color(0xFF1E201E)},
    {'date': '12 Mar', 'location': 'Luton Range', 'score': '91%', 'badge': '3w ago', 'tint': Color(0xFF1A2020)},
  ];

  final _board = const [
    {'rank': 11, 'name': 'Edgar Muldane', 'level': 256, 'xp': '10,000 XP', 'time': '1:02'},
    {'rank': 12, 'name': 'Augustina V.', 'level': 7, 'xp': '500 XP', 'time': '2:21'},
    {'rank': 13, 'name': 'Jason Marsh', 'level': 183, 'xp': '10,000 XP', 'time': '2:22'},
  ];

  final _events = const [
    {'name': 'Schmeisser Steel Challenge', 'club': 'Double Deuce', 'date': 'June 2nd · Shooting Centre'},
    {'name': 'Tactical Shoot Night', 'club': 'Double Deuce', 'date': 'Thursday, 7th September'},
  ];

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

  // ── Header ────────────────────────────────────────────────────────────────
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
              queryParameters: {'userId': 'me'})),
        ],
      ),
    );
  }

  // ── Recent Sessions ───────────────────────────────────────────────────────
  Widget _buildRecentSessions(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      children: [
        SXSectionTitle(
          label: 'Recent Sessions',
          actionLabel: 'See All',
          onAction: () => context.pushNamed('AllSessions'),
        ),
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
                date: s['date'] as String,
                location: s['location'] as String,
                score: s['score'] as String,
                badge: s['badge'] as String,
                tintColor: s['tint'] as Color,
                onTap: () => context.pushNamed('SessionSummary',
                    queryParameters: {'sessionId': 'session_$i'}),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Action Grid ───────────────────────────────────────────────────────────
  Widget _buildActionGrid(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          SXActionButton(
            label: 'Log Shot',
            icon: Icons.adjust_rounded,
            onTap: () => context.pushNamed('AddSession'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Scan Target',
            icon: Icons.qr_code_scanner_rounded,
            onTap: () => context.pushNamed('ScanTarget'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Find Range',
            icon: Icons.location_on_rounded,
            onTap: () => context.pushNamed('FindRange'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Compete',
            icon: Icons.emoji_events_rounded,
            onTap: () => context.pushNamed('EventCard'),
          ),
        ],
      ),
    );
  }

  // ── Leaderboard ───────────────────────────────────────────────────────────
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
          ...List.generate(_board.length, (i) {
            final r = _board[i];
            return Column(
              children: [
                SXLeaderboardRow(
                  rank: r['rank'] as int,
                  name: r['name'] as String,
                  level: r['level'] as int,
                  xp: r['xp'] as String,
                  time: r['time'] as String,
                  onTap: () => context.pushNamed('UserProfile',
                      queryParameters: {'userId': 'user_$i'}),
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

  // ── Upcoming Events ───────────────────────────────────────────────────────
  Widget _buildEvents(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      children: [
        const SXSectionTitle(label: 'Upcoming Events'),
        ..._events.map((ev) => SXEventTile(
              name: ev['name']!,
              subtitle: ev['club']!,
              detail: ev['date']!,
              onTap: () => context.pushNamed('EventDetails',
                  queryParameters: {'eventId': 'event_0'}),
            )),
      ],
    );
  }
}
