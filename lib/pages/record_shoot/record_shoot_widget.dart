// record_shoot_widget.dart  — NEW SCREEN
// Add to lib/pages/record_shoot/record_shoot_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/sx_gamification_service.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class RecordShootWidget extends StatefulWidget {
  const RecordShootWidget({super.key});
  static const String routeName = 'RecordShoot';
  static const String routePath = '/recordShoot';

  @override
  State<RecordShootWidget> createState() => _RecordShootWidgetState();
}

class _RecordShootWidgetState extends State<RecordShootWidget> {
  final _stopwatch = Stopwatch();
  Timer? _timer;
  int _shots = 0;
  bool _saved = false;

  String get _elapsed {
    final s = _stopwatch.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void _start() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _stop() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _reset() {
    _stopwatch.reset();
    setState(() => _shots = 0);
  }

  Future<void> _save() async {
    final elapsed = _stopwatch.elapsed.inSeconds;
    try {
      await SessionsTable().insert({
        'user_id': currentUserUid,
        'total_shots': _shots,
        'hits': _shots,
        'accuracy': 0.0,
        'created_at': DateTime.now().toIso8601String(),
        'conditions': {'duration_seconds': elapsed},
      });
      // Award XP and update streak
      await SXGamificationService.onSessionCompleted(currentUserUid);
    } catch (_) {
      // Non-blocking: session saves best-effort
    }
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_saved) return _buildSavedView(context, theme);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Record Shoot'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
            child: Column(children: [
              _buildTimer(context, theme),
              const SizedBox(height: 24),
              _buildShotCounter(context, theme),
              const SizedBox(height: 24),
              _buildControls(context, theme),
              if (!_stopwatch.isRunning && _stopwatch.elapsed.inSeconds > 0) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _reset,
                  child: Text('Reset',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.4), fontSize: 13)),
                ),
              ],
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildTimer(BuildContext context, FlutterFlowTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 200, height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _stopwatch.isRunning ? theme.primary : theme.borderColor,
          width: 4,
        ),
        boxShadow: _stopwatch.isRunning
            ? [BoxShadow(color: theme.primary.withOpacity(0.2), blurRadius: 30)]
            : null,
      ),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_elapsed,
            style: GoogleFonts.interTight(color: Colors.white,
                fontSize: 46, fontWeight: FontWeight.w800,
                letterSpacing: -2,
                fontFeatures: [const FontFeature.tabularFigures()])),
        const SizedBox(height: 4),
        Text(_stopwatch.isRunning ? 'Recording…' : 'Stopped',
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ]),
    );
  }

  Widget _buildShotCounter(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(children: [
        Text('SHOTS FIRED',
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text('$_shots',
            style: GoogleFonts.interTight(color: Colors.white,
                fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _stopwatch.isRunning
              ? () => setState(() => _shots++)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: _stopwatch.isRunning
                  ? theme.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _stopwatch.isRunning ? theme.primary : theme.borderColor,
              ),
            ),
            child: Text('+ Log Shot',
                style: GoogleFonts.inter(
                    color: _stopwatch.isRunning
                        ? theme.primary : Colors.white.withOpacity(0.3),
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _buildControls(BuildContext context, FlutterFlowTheme theme) {
    return Row(children: [
      if (!_stopwatch.isRunning)
        Expanded(child: GestureDetector(
          onTap: _start,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text('Start', style: GoogleFonts.interTight(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
        ))
      else
        Expanded(child: GestureDetector(
          onTap: _stop,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444)),
            ),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.stop_rounded, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 6),
              Text('Stop', style: GoogleFonts.interTight(
                  color: const Color(0xFFEF4444),
                  fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
        )),
      if (!_stopwatch.isRunning && _stopwatch.elapsed.inSeconds > 0) ...[
        const SizedBox(width: 12),
        Expanded(child: GestureDetector(
          onTap: () => _save(),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.borderColor),
            ),
            alignment: Alignment.center,
            child: Text('Save', style: GoogleFonts.interTight(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        )),
      ],
    ]);
  }

  Widget _buildSavedView(BuildContext context, FlutterFlowTheme theme) {
    final elapsed = _stopwatch.elapsed.inSeconds;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Record Shoot'),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: theme.primary, size: 36),
                ),
                const SizedBox(height: 16),
                Text('Session Saved!',
                    style: GoogleFonts.interTight(color: Colors.white,
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Column(children: [
                    _summaryRow(theme, 'Duration',
                        '${(elapsed ~/ 60).toString().padLeft(2, '0')}:${(elapsed % 60).toString().padLeft(2, '0')}'),
                    const SizedBox(height: 8),
                    _summaryRow(theme, 'Shots', '$_shots'),
                    const SizedBox(height: 8),
                    _summaryRow(theme, 'Avg / shot',
                        _shots > 0 ? '${(elapsed / _shots).round()}s' : '—'),
                  ]),
                ),
                const SizedBox(height: 24),
                SXGreenButton(label: 'Done', onTap: () => context.pop()),
              ],
            ),
          )),
        ]),
      ),
    );
  }

  Widget _summaryRow(FlutterFlowTheme theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5), fontSize: 13)),
        Text(value, style: GoogleFonts.inter(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
