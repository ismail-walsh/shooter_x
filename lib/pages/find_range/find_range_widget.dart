// find_range_widget.dart  — NEW SCREEN
// Add to lib/pages/find_range/find_range_widget.dart
// Uses flutter_map + latlong2 for the map, falls back gracefully if not available.
// Add to pubspec.yaml:
//   flutter_map: ^6.1.0
//   latlong2: ^0.9.0
//   geolocator: ^12.0.0

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/sx_shared_widgets.dart';

class FindRangeWidget extends StatefulWidget {
  const FindRangeWidget({super.key});
  static const String routeName = 'FindRange';
  static const String routePath = '/findRange';

  @override
  State<FindRangeWidget> createState() => _FindRangeWidgetState();
}

class _FindRangeWidgetState extends State<FindRangeWidget> {
  int? _selected;

  static const _ranges = [
    _Range('OD Tactical Range', '2.1 miles', 'Rifle / Pistol', true),
    _Range('Luton Shooting Club', '4.8 miles', 'Clay / Rifle', true),
    _Range('SD Clay Ground', '6.3 miles', 'Clay Shooting', false),
    _Range('Marin Long Range', '9.1 miles', 'Long Range Rifle', true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Find a Range'),
          // Map placeholder (swap for flutter_map MapWidget in production)
          _buildMapPlaceholder(context, theme),
          // Range list
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _ranges.length,
            itemBuilder: (ctx, i) => _buildRangeTile(ctx, theme, i),
          )),
        ]),
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      height: 260,
      color: const Color(0xFF0A1A0F),
      child: Stack(children: [
        // Grid lines
        CustomPaint(
          size: const Size(double.infinity, 260),
          painter: _MapGridPainter(),
        ),
        // Range pins
        ..._ranges.asMap().entries.map((e) {
          final positions = [
            const Offset(0.52, 0.28), const Offset(0.38, 0.55),
            const Offset(0.68, 0.42), const Offset(0.58, 0.65),
          ];
          return _buildPin(theme, e.key, positions[e.key]);
        }),
        // User location dot
        Positioned(
          left: MediaQuery.of(context).size.width * 0.5 - 7,
          top: 260 * 0.48 - 7,
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: theme.primary.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPin(FlutterFlowTheme theme, int i, Offset frac) {
    final r = _ranges[i];
    final sel = _selected == i;
    return Positioned(
      left: MediaQuery.of(context).size.width * frac.dx - 30,
      top: 260 * frac.dy - 32,
      child: GestureDetector(
        onTap: () => setState(() => _selected = _selected == i ? null : i),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: sel
                  ? theme.primary
                  : r.open
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFF3A2222),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel
                    ? theme.primary
                    : r.open
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFEF4444),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 8)
              ],
            ),
            child: Text(r.name.split(' ').first,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          Container(width: 2, height: 6,
              color: Colors.white.withOpacity(0.3)),
        ]),
      ),
    );
  }

  Widget _buildRangeTile(BuildContext context, FlutterFlowTheme theme, int i) {
    final r = _ranges[i];
    final sel = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = _selected == i ? null : i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: sel
              ? theme.primary.withOpacity(0.08)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: sel ? theme.primary : theme.borderColor,
          ),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.name,
                  style: GoogleFonts.inter(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${r.discipline} · ${r.distance}',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: r.open
                  ? theme.primary.withOpacity(0.15)
                  : const Color(0xFFEF4444).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(r.open ? 'OPEN' : 'CLOSED',
                style: GoogleFonts.inter(
                    color: r.open ? theme.primary : const Color(0xFFEF4444),
                    fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _Range {
  const _Range(this.name, this.distance, this.discipline, this.open);
  final String name, distance, discipline;
  final bool open;
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (var i = 0; i <= 5; i++) {
      canvas.drawLine(Offset(size.width / 5 * i, 0),
          Offset(size.width / 5 * i, size.height), paint);
    }
    for (var i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(0, size.height / 4 * i),
          Offset(size.width, size.height / 4 * i), paint);
    }
    // Decorative road lines
    paint.color = Colors.white.withOpacity(0.06);
    canvas.drawLine(Offset(0, size.height * 0.45),
        Offset(size.width, size.height * 0.42), paint);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.42, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
