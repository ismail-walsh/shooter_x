// activity_widget.dart
// Replaces lib/pages/activity/activity_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({super.key});
  static const String routeName = 'Activity';
  static const String routePath = '/activity';

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  String _sport = 'Target Shooting';
  bool _showPicker = false;

  static const _sports = [
    'Target Shooting', 'Deer Stalking', 'Clay Shooting', 'Game Shooting',
  ];
  static const _sessions = [
    {'date': '14 Apr', 'location': 'OD Range', 'score': '96%', 'badge': 'PB', 'tint': Color(0xFF1E2A1E)},
    {'date': '31 Mar', 'location': 'SD Clay', 'score': '87%', 'badge': '12d', 'tint': Color(0xFF1E201E)},
    {'date': '12 Mar', 'location': 'Luton Range', 'score': '91%', 'badge': '3w', 'tint': Color(0xFF1A2020)},
  ];
  static const _comps = [
    {'name': 'Schmeisser Steel Challenge', 'due': 'Live – 67% complete', 'live': true},
    {'name': 'OD Tactical Shoot', 'due': 'Starts in 3 days', 'live': false},
    {'name': 'Club Night Challenge', 'due': 'Due next week', 'live': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, theme)),
                SliverToBoxAdapter(child: _buildSportPicker(context, theme)),
                SliverToBoxAdapter(child: _buildActionGrid(context, theme)),
                SliverToBoxAdapter(child: _buildRecentSessions(context, theme)),
                SliverToBoxAdapter(child: _buildCompetitions(context, theme)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            // Record Shoot FAB
            Positioned(
              bottom: 16,
              left: 0, right: 0,
              child: Center(child: _buildRecordFAB(context, theme)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return SXPageHeader(
      title: Text('Activity',
          style: GoogleFonts.interTight(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
              letterSpacing: -0.5)),
      actions: [
        SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': 'me'})),
      ],
    );
  }

  Widget _buildSportPicker(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPicker = !_showPicker),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_sport,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: theme.mutedText, size: 18),
                ],
              ),
            ),
          ),
          if (_showPicker)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                children: _sports.map((s) => GestureDetector(
                  onTap: () => setState(() { _sport = s; _showPicker = false; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: s == _sports.last
                                  ? Colors.transparent
                                  : theme.borderColor)),
                    ),
                    child: Row(children: [
                      Expanded(child: Text(s,
                          style: GoogleFonts.inter(
                              color: s == _sport ? theme.primary : Colors.white,
                              fontSize: 14,
                              fontWeight: s == _sport
                                  ? FontWeight.w600 : FontWeight.normal))),
                      if (s == _sport)
                        Icon(Icons.check_rounded, color: theme.primary, size: 16),
                    ]),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(children: [
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
      ]),
    );
  }

  Widget _buildRecentSessions(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      SXSectionTitle(label: 'Recent', actionLabel: 'See All',
          onAction: () => context.pushNamed('AllSessions')),
      SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          itemCount: _sessions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
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
    ]);
  }

  Widget _buildCompetitions(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      const SXSectionTitle(label: 'Competitions'),
      ..._comps.map((c) => GestureDetector(
        onTap: () => context.pushNamed('EventDetails',
            queryParameters: {'eventId': 'comp_0'}),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['name'] as String,
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(c['due'] as String,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            )),
            if (c['live'] == true) ...[
              const SXLiveBadge(),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildRecordFAB(BuildContext context, FlutterFlowTheme theme) {
    return GestureDetector(
      onTap: () => context.pushNamed('RecordShoot'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.borderColor),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
                color: theme.primary, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Record Shoot',
              style: GoogleFonts.inter(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
