import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

enum _Phase { ready, processing, result }

class ScanTargetWidget extends StatefulWidget {
  const ScanTargetWidget({super.key});
  static const String routeName = 'ScanTarget';
  static const String routePath = '/scanTarget';

  @override
  State<ScanTargetWidget> createState() => _ScanTargetWidgetState();
}

class _ScanTargetWidgetState extends State<ScanTargetWidget> {
  _Phase _phase = _Phase.ready;
  File? _photo;
  int _shotCount = 5;
  int _hitCount = 5;

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null) return; // user cancelled
    setState(() {
      _phase = _Phase.processing;
      _photo = File(file.path);
    });
    // Brief pause so the transition feels deliberate
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _phase = _Phase.result);
  }

  double get _accuracy =>
      _shotCount > 0 ? (_hitCount / _shotCount) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.ready => _buildReadyView(context),
      _Phase.processing => _buildProcessingView(context),
      _Phase.result => _buildResultView(context),
    };
  }

  // ── Ready view ───────────────────────────────────────────────────────────────
  Widget _buildReadyView(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [Color(0xFF0A1A0A), Colors.black],
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Text('Scan Target',
                    style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
            ),
            const Spacer(),
            // Viewfinder frame
            SizedBox(
              width: 260, height: 260,
              child: Stack(children: [
                ..._corners(theme.primary),
                Center(child: Opacity(
                  opacity: 0.12,
                  child: CustomPaint(
                      size: const Size(200, 200),
                      painter: _RingsPainter()),
                )),
              ]),
            ),
            const SizedBox(height: 24),
            Text('Point your camera at the target',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const Spacer(),
            // Shutter button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: GestureDetector(
                onTap: _openCamera,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 4),
                    boxShadow: [
                      BoxShadow(
                          color: theme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Processing view ──────────────────────────────────────────────────────────
  Widget _buildProcessingView(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: theme.primary, strokeWidth: 3),
          const SizedBox(height: 20),
          Text('Analysing target…',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6), fontSize: 15)),
        ]),
      ),
    );
  }

  // ── Result view ──────────────────────────────────────────────────────────────
  Widget _buildResultView(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Scan Result'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Photo card
                Container(
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Column(children: [
                    // Captured image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: _photo != null
                          ? Image.file(_photo!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : Container(
                              height: 220,
                              color: const Color(0xFF1A2A1A),
                              child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.white24, size: 48)),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_accuracy.toStringAsFixed(0)}% accuracy  ·  $_hitCount / $_shotCount hits',
                            style: GoogleFonts.interTight(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 16),
                          // Shot count row
                          _CountRow(
                            label: 'Total shots',
                            value: _shotCount,
                            onChanged: (v) => setState(() {
                              _shotCount = v;
                              if (_hitCount > _shotCount) _hitCount = _shotCount;
                            }),
                            max: 50,
                          ),
                          const SizedBox(height: 10),
                          _CountRow(
                            label: 'Hits',
                            value: _hitCount,
                            onChanged: (v) => setState(() => _hitCount = v),
                            max: _shotCount,
                          ),
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
                  onTap: () => setState(() {
                    _phase = _Phase.ready;
                    _photo = null;
                    _shotCount = 5;
                    _hitCount = 5;
                  }),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _corners(Color color) {
    Widget corner(AlignmentGeometry align, bool flipH, bool flipV) =>
        Align(
          alignment: align,
          child: Transform.scale(
            scaleX: flipH ? -1 : 1,
            scaleY: flipV ? -1 : 1,
            child: SizedBox(
                width: 32, height: 32,
                child: CustomPaint(painter: _CornerPainter(color))),
          ),
        );
    return [
      corner(Alignment.topLeft, false, false),
      corner(Alignment.topRight, true, false),
      corner(Alignment.bottomLeft, false, true),
      corner(Alignment.bottomRight, true, true),
    ];
  }
}

// ── Shot count stepper ─────────────────────────────────────────────────────────
class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.max,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(children: [
      Text(label,
          style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6), fontSize: 13)),
      const Spacer(),
      GestureDetector(
        onTap: value > 0 ? () => onChanged(value - 1) : null,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: theme.alternate,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.remove_rounded,
              color: value > 0 ? Colors.white : Colors.white24, size: 18),
        ),
      ),
      SizedBox(
        width: 40,
        child: Text('$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      GestureDetector(
        onTap: value < max ? () => onChanged(value + 1) : null,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: theme.alternate,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add_rounded,
              color: value < max ? Colors.white : Colors.white24, size: 18),
        ),
      ),
    ]);
  }
}

// ── Painters ───────────────────────────────────────────────────────────────────
class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final c = Offset(size.width / 2, size.height / 2);
    for (final f in [0.9, 0.7, 0.5, 0.3, 0.12]) {
      canvas.drawCircle(c, size.width / 2 * f, p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
