// scan_target_widget.dart  — NEW SCREEN
// Add to lib/pages/scan_target/scan_target_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

enum _ScanPhase { ready, scanning, result }

class ScanTargetWidget extends StatefulWidget {
  const ScanTargetWidget({super.key});
  static const String routeName = 'ScanTarget';
  static const String routePath = '/scanTarget';

  @override
  State<ScanTargetWidget> createState() => _ScanTargetWidgetState();
}

class _ScanTargetWidgetState extends State<ScanTargetWidget>
    with SingleTickerProviderStateMixin {
  _ScanPhase _phase = _ScanPhase.ready;
  late AnimationController _scanAnim;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() => _phase = _ScanPhase.scanning);
    _scanTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _phase = _ScanPhase.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _ScanPhase.result) return _buildResultView(context);
    return _buildScanView(context);
  }

  // ── Camera / scan view ────────────────────────────────────────────────────
  Widget _buildScanView(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // "Camera" viewfinder background
        Container(color: const Color(0xFF050F05)),

        // Header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              Text('Scan Target',
                  style: GoogleFonts.interTight(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              const SizedBox(width: 36),
            ]),
          ),
        ),

        // Viewfinder
        Center(
          child: SizedBox(
            width: 260, height: 260,
            child: Stack(children: [
              // Corner brackets
              ..._corners(),
              // Scan line (animated)
              if (_phase == _ScanPhase.scanning)
                AnimatedBuilder(
                  animation: _scanAnim,
                  builder: (_, __) => Positioned(
                    top: _scanAnim.value * 256,
                    left: 0, right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        boxShadow: [
                          BoxShadow(
                              color: theme.primary.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              // Target ring overlay
              Center(child: Opacity(
                opacity: 0.15,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _TargetRingsPainter(),
                ),
              )),
            ]),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _phase == _ScanPhase.ready
                        ? 'Point camera at your target'
                        : 'Scanning…',
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  if (_phase == _ScanPhase.ready)
                    GestureDetector(
                      onTap: _startScan,
                      child: Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 4),
                        ),
                        child: const Icon(Icons.circle,
                            color: Colors.white, size: 28),
                      ),
                    )
                  else
                    SizedBox(
                      width: 48, height: 48,
                      child: CircularProgressIndicator(
                        color: theme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _corners() {
    final green = const Color(0xFF3DD162);
    Widget corner(AlignmentGeometry align, bool flipH, bool flipV) {
      return Align(
        alignment: align,
        child: Transform.scale(
          scaleX: flipH ? -1 : 1,
          scaleY: flipV ? -1 : 1,
          child: SizedBox(
            width: 32, height: 32,
            child: CustomPaint(painter: _CornerPainter(green)),
          ),
        ),
      );
    }
    return [
      corner(Alignment.topLeft, false, false),
      corner(Alignment.topRight, true, false),
      corner(Alignment.bottomLeft, false, true),
      corner(Alignment.bottomRight, true, true),
    ];
  }

  // ── Result view ───────────────────────────────────────────────────────────
  Widget _buildResultView(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    // Simulated shot positions
    const shots = [
      Offset(-0.04, -0.06), Offset(0.06, 0.04), Offset(-0.02, 0.02),
      Offset(0.04, -0.10), Offset(-0.08, 0.04), Offset(0.08, -0.02),
      Offset(-0.02, 0.08),
    ];
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Scan Result'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Target with shots
              Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.borderColor),
                ),
                child: Column(children: [
                  Stack(alignment: Alignment.center, children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2A1A),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                    ),
                    SizedBox(
                      width: 140, height: 140,
                      child: CustomPaint(
                        painter: _ScanResultPainter(
                            shots: shots, dotColor: theme.primary),
                      ),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('SCANNED',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('94% — 7 shots detected',
                            style: GoogleFonts.interTight(color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 12),
                        Row(children: [
                          _resultStat(theme, 'Group', '22mm'),
                          const SizedBox(width: 10),
                          _resultStat(theme, 'Best', '9-ring'),
                          const SizedBox(width: 10),
                          _resultStat(theme, 'Spread', '28mm'),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              SXGreenButton(
                label: 'Save to Session',
                onTap: () => context.pushNamed('AddSession'),
              ),
              const SizedBox(height: 10),
              SXGreenButton(
                label: 'Scan Again',
                outlined: true,
                onTap: () => setState(() => _phase = _ScanPhase.ready),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _resultStat(FlutterFlowTheme theme, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 3),
          Text(value,
              style: GoogleFonts.interTight(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TargetRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final c = Offset(size.width / 2, size.height / 2);
    for (final f in [0.9, 0.7, 0.5, 0.3]) {
      canvas.drawCircle(c, size.width / 2 * f, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ScanResultPainter extends CustomPainter {
  const _ScanResultPainter({required this.shots, required this.dotColor});
  final List<Offset> shots;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;

    canvas.drawCircle(c, maxR,
        Paint()..color = const Color(0xFF1A2A1A));

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.15);
    for (final f in [0.9, 0.7, 0.5, 0.3]) {
      canvas.drawCircle(c, maxR * f, ringPaint);
    }
    ringPaint
      ..color = dotColor
      ..strokeWidth = 2.0;
    canvas.drawCircle(c, maxR * 0.12, ringPaint);

    final dotPaint = Paint()
      ..color = dotColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    for (final s in shots) {
      canvas.drawCircle(
          Offset(c.dx + s.dx * maxR, c.dy + s.dy * maxR), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
