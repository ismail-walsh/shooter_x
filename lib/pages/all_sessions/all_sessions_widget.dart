import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class AllSessionsWidget extends StatefulWidget {
  const AllSessionsWidget({super.key});
  static const String routeName = 'AllSessions';
  static const String routePath = '/allSessions';

  @override
  State<AllSessionsWidget> createState() => _AllSessionsWidgetState();
}

class _AllSessionsWidgetState extends State<AllSessionsWidget> {
  bool _loading = true;
  List<SessionsRow> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sessions = await databaseService.getUserSessions();
      if (mounted) setState(() { _sessions = sessions; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Stats derived from loaded sessions ────────────────────────────────────
  int get _count => _sessions.length;
  String get _avgAccuracy {
    if (_sessions.isEmpty) return '—';
    final avg = _sessions.map((s) => s.accuracy ?? 0).reduce((a, b) => a + b)
        / _sessions.length;
    return '${avg.toStringAsFixed(0)}%';
  }
  String get _bestAccuracy {
    if (_sessions.isEmpty) return '—';
    final best = _sessions.map((s) => s.accuracy ?? 0).reduce((a, b) => a > b ? a : b);
    return '${best.toStringAsFixed(0)}%';
  }

  // ── Formatters ────────────────────────────────────────────────────────────
  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  static const _tints = [
    Color(0xFF1E2A1E), Color(0xFF1E201E), Color(0xFF1A2020),
    Color(0xFF201E20), Color(0xFF1E2A1E), Color(0xFF201A1E),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'All Sessions'),
          Expanded(child: _loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _buildStats(context, theme)),
                  if (_sessions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('No sessions yet — log your first shot!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14)),
                      ),
                    )
                  else
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
        _statTile(theme, '$_count', 'Sessions'),
        const SizedBox(width: 8),
        _statTile(theme, _avgAccuracy, 'Average'),
        const SizedBox(width: 8),
        _statTile(theme, _bestAccuracy, 'Personal Best'),
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
      SessionsRow s, int i) {
    final isPb = s.isPersonalBest == true;
    return GestureDetector(
      onTap: () => context.pushNamed('SessionSummary',
          queryParameters: {'sessionId': s.id}),
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
              color: _tints[i % _tints.length],
              borderRadius: BorderRadius.circular(11),
            ),
            child: CustomPaint(painter: _MiniTargetPainter()),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.location ?? s.discipline ?? '—',
                  style: GoogleFonts.inter(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${_fmtDate(s.createdAt)}  ·  ${s.totalShots ?? 0} shots',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(s.accuracy ?? 0).toStringAsFixed(0)}%',
                style: GoogleFonts.interTight(color: Colors.white,
                    fontSize: 20, fontWeight: FontWeight.w800,
                    letterSpacing: -1)),
            if (isPb)
              Text('PB',
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
