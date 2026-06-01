import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/sx_gamification_service.dart';
import '/services/database_service.dart';
import '/services/photo_upload_service.dart';
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

  void _onSaveTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionDetailSheet(
        shots: _shots,
        durationSeconds: _stopwatch.elapsed.inSeconds,
        onSaved: () => setState(() => _saved = true),
      ),
    );
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
          onTap: _onSaveTapped,
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

// ── Detail sheet shown before saving ─────────────────────────────────────────

class _SessionDetailSheet extends StatefulWidget {
  const _SessionDetailSheet({
    required this.shots,
    required this.durationSeconds,
    required this.onSaved,
  });
  final int shots;
  final int durationSeconds;
  final VoidCallback onSaved;

  @override
  State<_SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<_SessionDetailSheet> {
  final _firearmCtrl = TextEditingController();
  final _ammoCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final TextEditingController _hitsCtrl;

  String? _discipline;
  String? _weather;
  File? _photo;
  bool _saving = false;
  bool _uploadingPhoto = false;

  static const _disciplines = [
    'Target Shooting', 'Pistol', 'Rifle', 'Shotgun',
    'Sporting Clays', 'Hunting', 'Competition', 'Tactical',
  ];
  static const _weatherOptions = ['Clear', 'Sunny', 'Cloudy', 'Overcast', 'Light Rain'];

  @override
  void initState() {
    super.initState();
    _hitsCtrl = TextEditingController(text: '${widget.shots}');
  }

  @override
  void dispose() {
    _firearmCtrl.dispose();
    _ammoCtrl.dispose();
    _distanceCtrl.dispose();
    _notesCtrl.dispose();
    _hitsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null && mounted) setState(() => _photo = File(file.path));
  }

  Future<void> _save(BuildContext ctx) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        setState(() => _uploadingPhoto = true);
        photoUrl = await photoUploadService.uploadFile(
          file: _photo!,
          bucket: 'session-photos',
          folder: 'targets',
        );
        setState(() => _uploadingPhoto = false);
      }

      final hits = int.tryParse(_hitsCtrl.text) ?? widget.shots;
      final dist = int.tryParse(_distanceCtrl.text);
      final accuracy = widget.shots > 0 ? (hits / widget.shots) * 100 : 0.0;

      await databaseService.createSession(
        discipline: _discipline ?? 'Target Shooting',
        firearm: _firearmCtrl.text.trim(),
        ammoType: _ammoCtrl.text.trim(),
        distance: dist ?? 0,
        hits: hits,
        totalShots: widget.shots,
        targetImageUrl: photoUrl,
        conditions: {
          'duration_seconds': widget.durationSeconds,
          if (_weather != null) 'weather': _weather,
          if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
        },
      );

      await SXGamificationService.onSessionCompleted(currentUserUid);

      if (ctx.mounted) {
        Navigator.pop(ctx);
        widget.onSaved();
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() { _saving = false; _uploadingPhoto = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Session Details',
                    style: GoogleFonts.interTight(
                        color: Colors.white, fontSize: 17,
                        fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded,
                        color: Colors.white.withOpacity(0.6), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('All fields are optional',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.35), fontSize: 12)),
            const SizedBox(height: 18),

            // Hits
            _SheetField(
              ctrl: _hitsCtrl,
              hint: 'Hits on target',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // Discipline
            _SheetDropdown(
              value: _discipline,
              hint: 'Discipline',
              options: _disciplines,
              onChanged: (v) => setState(() => _discipline = v),
              theme: theme,
            ),
            const SizedBox(height: 10),

            // Firearm
            _SheetField(ctrl: _firearmCtrl, hint: 'Firearm (e.g. Remington 700)'),
            const SizedBox(height: 10),

            // Ammo
            _SheetField(ctrl: _ammoCtrl, hint: 'Ammo type (e.g. .308 Win)'),
            const SizedBox(height: 10),

            // Distance
            _SheetField(
              ctrl: _distanceCtrl,
              hint: 'Distance (metres)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // Weather
            _SheetDropdown(
              value: _weather,
              hint: 'Weather conditions',
              options: _weatherOptions,
              onChanged: (v) => setState(() => _weather = v),
              theme: theme,
            ),
            const SizedBox(height: 10),

            // Notes
            _SheetField(ctrl: _notesCtrl, hint: 'Notes', maxLines: 3),
            const SizedBox(height: 14),

            // Photo picker
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_photo!, fit: BoxFit.cover,
                            width: double.infinity))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              color: Colors.white.withOpacity(0.4), size: 20),
                          const SizedBox(width: 8),
                          Text('Add session photo',
                              style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // Save button
            GestureDetector(
              onTap: _saving ? null : () => _save(context),
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  color: _saving ? theme.primary.withOpacity(0.5) : theme.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Save Session',
                        style: GoogleFonts.interTight(
                            color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.ctrl, required this.hint,
      this.keyboardType, this.maxLines = 1});
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      cursorColor: theme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.3), fontSize: 14),
        filled: true,
        fillColor: theme.secondaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: theme.primary.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _SheetDropdown extends StatelessWidget {
  const _SheetDropdown({
    required this.value, required this.hint,
    required this.options, required this.onChanged, required this.theme,
  });
  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.3), fontSize: 14)),
          dropdownColor: const Color(0xFF1A1A1A),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.4), size: 20),
          isExpanded: true,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          items: options.map((o) => DropdownMenuItem(
            value: o,
            child: Text(o),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
