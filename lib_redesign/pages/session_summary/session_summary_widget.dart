// session_summary_widget.dart
// Replaces lib/pages/session_summary/session_summary_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class SessionSummaryWidget extends StatelessWidget {
  const SessionSummaryWidget({super.key, this.sessionId});
  final String? sessionId;
  static const String routeName = 'SessionSummary';
  static const String routePath = '/sessionSummary';

  // Simulated shot coordinates (normalised -1..1 from centre)
  static const _shots = [
    Offset(0.00, -0.06), Offset(0.06, 0.04), Offset(-0.04, 0.00),
    Offset(0.02, -0.12), Offset(-0.08, 0.06), Offset(0.10, -0.02),
    Offset(-0.02, 0.10), Offset(0.04, -0.04), Offset(-0.06, 0.02),
    Offset(0.08, -0.08),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: SXBackHeader(
            title: 'Session Detail',
            trailing: GestureDetector(
              onTap: () {},
              child: Text('Share',
                  style: GoogleFonts.inter(
                      color: theme.primary, fontSize: 13)),
            ),
          )),
          SliverToBoxAdapter(child: _buildTargetDiagram(context, theme)),
          SliverToBoxAdapter(child: _buildStatsRow(context, theme)),
          SliverToBoxAdapter(child: _buildMetaCard(context, theme)),
          SliverToBoxAdapter(child: _buildAddShotButton(context, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  Widget _buildTargetDiagram(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Center(
        child: SizedBox(
          width: 220, height: 220,
          child: CustomPaint(
            painter: _TargetWithShotsPainter(
              shots: _shots,
              ringColor: Colors.white.withOpacity(0.12),
              bullseyeColor: theme.primary,
              dotColor: theme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, FlutterFlowTheme theme) {
    final stats = [
      ['Score', '96%'],
      ['Shots', '10'],
      ['Group', '18mm'],
      ['Best', 'X Ring'],
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: stats.asMap().entries.map((e) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: e.key < stats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(children: [
                Text(e.value[0],
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
                const SizedBox(height: 4),
                Text(e.value[1],
                    style: GoogleFonts.interTight(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context, FlutterFlowTheme theme) {
    final rows = [
      ['Date', '14 Apr 2025'],
      ['Location', 'OD Range – Marin'],
      ['Firearm', 'Tikka T3x .308'],
      ['Ammo', 'Federal 168gr Sierra'],
      ['Distance', '100m'],
      ['Conditions', 'Light wind, overcast'],
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: e.key < rows.length - 1
                  ? Border(bottom: BorderSide(color: theme.borderColor))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value[0],
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 13)),
                Text(e.value[1],
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddShotButton(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.pushNamed('AddSession'),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          alignment: Alignment.center,
          child: Text('Add Another Shot',
              style: GoogleFonts.inter(color: Colors.white,
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── Shot grouping target painter ─────────────────────────────────────────────
class _TargetWithShotsPainter extends CustomPainter {
  const _TargetWithShotsPainter({
    required this.shots,
    required this.ringColor,
    required this.bullseyeColor,
    required this.dotColor,
  });
  final List<Offset> shots;
  final Color ringColor;
  final Color bullseyeColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    // Background
    canvas.drawCircle(c, maxR,
        Paint()..color = const Color(0xFF1A2A1A));

    // Rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final frac in [0.92, 0.7, 0.5, 0.3]) {
      ringPaint.color = ringColor;
      canvas.drawCircle(c, maxR * frac, ringPaint);
    }
    // Bullseye ring
    ringPaint
      ..color = bullseyeColor
      ..strokeWidth = 1.5;
    canvas.drawCircle(c, maxR * 0.13, ringPaint);

    // Crosshairs
    final chPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, maxR * 0.18), chPaint);
    canvas.drawLine(Offset(c.dx, size.height - maxR * 0.18),
        Offset(c.dx, size.height), chPaint);
    canvas.drawLine(Offset(0, c.dy), Offset(maxR * 0.18, c.dy), chPaint);
    canvas.drawLine(Offset(size.width - maxR * 0.18, c.dy),
        Offset(size.width, c.dy), chPaint);

    // Shot dots
    final dotPaint = Paint()
      ..color = dotColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    for (final shot in shots) {
      // shot is normalised -1..1, map to canvas coords
      final px = c.dx + shot.dx * maxR;
      final py = c.dy + shot.dy * maxR;
      canvas.drawCircle(Offset(px, py), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
