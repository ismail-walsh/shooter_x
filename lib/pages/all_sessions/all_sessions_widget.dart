// all_sessions_widget.dart  — NEW SCREEN
// Add to lib/pages/all_sessions/all_sessions_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class AllSessionsWidget extends StatelessWidget {
  const AllSessionsWidget({super.key});
  static const String routeName = 'AllSessions';
  static const String routePath = '/allSessions';

  static const _sessions = [
    {'date': '14 Apr 2025', 'location': 'OD Range – Marin', 'score': '96%', 'shots': 10, 'badge': 'PB', 'tint': Color(0xFF1E2A1E)},
    {'date': '31 Mar 2025', 'location': 'SD Clay – Breather', 'score': '87%', 'shots': 8, 'badge': '', 'tint': Color(0xFF1E201E)},
    {'date': '12 Mar 2025', 'location': 'Luton Range', 'score': '91%', 'shots': 12, 'badge': '', 'tint': Color(0xFF1A2020)},
    {'date': '24 Feb 2025', 'location': 'Double Deuce Club', 'score': '89%', 'shots': 10, 'badge': '', 'tint': Color(0xFF201E20)},
    {'date': '10 Feb 2025', 'location': 'Marin Long Range', 'score': '93%', 'shots': 5, 'badge': '', 'tint': Color(0xFF1E2A1E)},
    {'date': '28 Jan 2025', 'location': 'OD Range', 'score': '88%', 'shots': 10, 'badge': '', 'tint': Color(0xFF201A1E)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'All Sessions'),
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildStats(context, theme)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildSessionRow(ctx, theme, _sessions[i], i),
              childCount: _sessions.length,
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildStats(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(children: [
        _statTile(theme, '47', 'Sessions'),
        const SizedBox(width: 8),
        _statTile(theme, '91%', 'Average'),
        const SizedBox(width: 8),
        _statTile(theme, '98%', 'Personal Best'),
      ]),
    );
  }

  Widget _statTile(FlutterFlowTheme theme, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.interTight(color: Colors.white,
                  fontSize: 17, fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildSessionRow(BuildContext context, FlutterFlowTheme theme,
      Map s, int i) {
    return GestureDetector(
      onTap: () => context.pushNamed('SessionSummary',
          queryParameters: {'sessionId': 'session_$i'}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: s['tint'] as Color,
              borderRadius: BorderRadius.circular(11),
            ),
            child: CustomPaint(painter: _MiniTargetPainter()),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['location'] as String,
                  style: GoogleFonts.inter(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${s['date']}  ·  ${s['shots']} shots',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(s['score'] as String,
                style: GoogleFonts.interTight(color: Colors.white,
                    fontSize: 20, fontWeight: FontWeight.w800,
                    letterSpacing: -1)),
            if ((s['badge'] as String).isNotEmpty)
              Text(s['badge'] as String,
                  style: GoogleFonts.inter(color: theme.primary,
                      fontSize: 9, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

class _MiniTargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * 0.42, paint);
    canvas.drawCircle(c, size.width * 0.26, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(c, size.width * 0.09, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
