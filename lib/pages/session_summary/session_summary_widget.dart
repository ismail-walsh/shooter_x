import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import '/services/photo_upload_service.dart';

class SessionSummaryWidget extends StatefulWidget {
  const SessionSummaryWidget({super.key, this.sessionId});
  final String? sessionId;
  static const String routeName = 'SessionSummary';
  static const String routePath = '/sessionSummary';

  @override
  State<SessionSummaryWidget> createState() => _SessionSummaryWidgetState();
}

class _SessionSummaryWidgetState extends State<SessionSummaryWidget> {
  bool _loading = true;
  SessionsRow? _session;
  bool _uploadingPhoto = false;

  static const _placeholderShots = [
    Offset(0.00, -0.06), Offset(0.06, 0.04), Offset(-0.04, 0.00),
    Offset(0.02, -0.12), Offset(-0.08, 0.06), Offset(0.10, -0.02),
    Offset(-0.02, 0.10), Offset(0.04, -0.04), Offset(-0.06, 0.02),
    Offset(0.08, -0.08),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.sessionId;
    if (id == null || id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final session = await databaseService.getSessionById(id);
      if (mounted) setState(() { _session = session; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  Future<void> _uploadSessionPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 82);
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await photoUploadService.uploadFile(
        file: File(file.path),
        bucket: 'session-photos',
        folder: 'targets',
      );
      if (url != null && widget.sessionId != null) {
        await databaseService.updateSession(
          sessionId: widget.sessionId!,
          targetImageUrl: url,
        );
        if (mounted) await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showEditSheet() {
    if (_session == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSessionSheet(
        session: _session!,
        onSaved: (updated) => setState(() => _session = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: SXBackHeader(
              title: 'Session Detail',
              trailing: _session != null
                  ? GestureDetector(
                      onTap: _showEditSheet,
                      child: Text('Edit',
                          style: GoogleFonts.inter(
                              color: theme.primary, fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    )
                  : null,
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildPhotoCard(context, theme)),
            SliverToBoxAdapter(child: _buildStatsRow(context, theme)),
            SliverToBoxAdapter(child: _buildMetaCard(context, theme)),
            SliverToBoxAdapter(child: _buildAddShotButton(context, theme)),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, FlutterFlowTheme theme) {
    final imgUrl = _session?.targetImageUrl;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(children: [
        // Photo area or target diagram
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: imgUrl != null && imgUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imgUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => _targetDiagram(theme),
                )
              : _targetDiagram(theme),
        ),
        // Photo upload button
        GestureDetector(
          onTap: _uploadingPhoto ? null : _uploadSessionPhoto,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _uploadingPhoto
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      imgUrl != null && imgUrl.isNotEmpty
                          ? Icons.edit_outlined
                          : Icons.add_photo_alternate_rounded,
                      color: theme.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      imgUrl != null && imgUrl.isNotEmpty
                          ? 'Change photo'
                          : 'Add session photo',
                      style: GoogleFonts.inter(
                          color: theme.primary, fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  ]),
          ),
        ),
      ]),
    );
  }

  Widget _targetDiagram(FlutterFlowTheme theme) {
    return SizedBox(
      height: 220,
      child: Center(
        child: SizedBox(
          width: 180, height: 180,
          child: CustomPaint(
            painter: _TargetWithShotsPainter(
              shots: _placeholderShots,
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
    final s = _session;
    final score = s != null ? '${(s.accuracy ?? 0).toStringAsFixed(0)}%' : '—';
    final shots = s?.totalShots?.toString() ?? '—';
    final group = s?.groupSizeMm != null
        ? '${s!.groupSizeMm!.toStringAsFixed(0)}mm' : '—';
    final best = s?.bestRing ?? '—';

    final stats = [
      ['Score', score], ['Shots', shots],
      ['Group', group], ['Best', best],
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
                    style: GoogleFonts.interTight(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context, FlutterFlowTheme theme) {
    final s = _session;
    final rows = [
      ['Date', _fmtDate(s?.createdAt)],
      ['Discipline', s?.discipline ?? '—'],
      ['Firearm', s?.firearm ?? '—'],
      ['Ammo', s?.ammoType ?? '—'],
      ['Distance', s?.distance != null ? '${s!.distance}m' : '—'],
      ['Conditions', s?.weatherConditions ?? '—'],
      if (s?.notes?.isNotEmpty == true) ['Notes', s!.notes!],
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
                Flexible(
                  child: Text(e.value[1],
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
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
          child: Text('Add Another Session',
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ── Edit sheet ────────────────────────────────────────────────────────────────

class _EditSessionSheet extends StatefulWidget {
  const _EditSessionSheet({required this.session, required this.onSaved});
  final SessionsRow session;
  final ValueChanged<SessionsRow> onSaved;

  @override
  State<_EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<_EditSessionSheet> {
  late final TextEditingController _firearmCtrl;
  late final TextEditingController _ammoCtrl;
  late final TextEditingController _distanceCtrl;
  late final TextEditingController _hitsCtrl;
  late final TextEditingController _totalShotsCtrl;
  late final TextEditingController _notesCtrl;

  String? _discipline;
  String? _weather;
  bool _saving = false;

  static const _disciplines = [
    'Target Shooting', 'Pistol', 'Rifle', 'Shotgun',
    'Sporting Clays', 'Hunting', 'Competition', 'Tactical',
  ];
  static const _weatherOptions = [
    'Clear', 'Sunny', 'Cloudy', 'Overcast', 'Light Rain',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _firearmCtrl = TextEditingController(text: s.firearm ?? '');
    _ammoCtrl = TextEditingController(text: s.ammoType ?? '');
    _distanceCtrl = TextEditingController(
        text: s.distance != null ? '${s.distance}' : '');
    _hitsCtrl = TextEditingController(
        text: s.hits != null ? '${s.hits}' : '');
    _totalShotsCtrl = TextEditingController(
        text: s.totalShots != null ? '${s.totalShots}' : '');
    _notesCtrl = TextEditingController(text: s.notes ?? '');
    _discipline = s.discipline;
    _weather = s.weatherConditions;
  }

  @override
  void dispose() {
    _firearmCtrl.dispose();
    _ammoCtrl.dispose();
    _distanceCtrl.dispose();
    _hitsCtrl.dispose();
    _totalShotsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext ctx) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final hits = int.tryParse(_hitsCtrl.text);
      final totalShots = int.tryParse(_totalShotsCtrl.text);
      final updated = await databaseService.updateSession(
        sessionId: widget.session.id,
        discipline: _discipline,
        firearm: _firearmCtrl.text.trim().isEmpty ? null : _firearmCtrl.text.trim(),
        ammoType: _ammoCtrl.text.trim().isEmpty ? null : _ammoCtrl.text.trim(),
        distance: int.tryParse(_distanceCtrl.text),
        hits: hits,
        totalShots: totalShots,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        weatherConditions: _weather,
      );
      if (ctx.mounted) {
        Navigator.pop(ctx);
        if (updated != null) widget.onSaved(updated);
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
                Text('Edit Session',
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
            const SizedBox(height: 18),

            _EditField(ctrl: _totalShotsCtrl, hint: 'Total shots',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _EditField(ctrl: _hitsCtrl, hint: 'Hits on target',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _EditDropdown(
              value: _discipline, hint: 'Discipline',
              options: _disciplines, theme: theme,
              onChanged: (v) => setState(() => _discipline = v),
            ),
            const SizedBox(height: 10),
            _EditField(ctrl: _firearmCtrl, hint: 'Firearm'),
            const SizedBox(height: 10),
            _EditField(ctrl: _ammoCtrl, hint: 'Ammo type'),
            const SizedBox(height: 10),
            _EditField(ctrl: _distanceCtrl, hint: 'Distance (metres)',
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _EditDropdown(
              value: _weather, hint: 'Weather conditions',
              options: _weatherOptions, theme: theme,
              onChanged: (v) => setState(() => _weather = v),
            ),
            const SizedBox(height: 10),
            _EditField(ctrl: _notesCtrl, hint: 'Notes', maxLines: 3),
            const SizedBox(height: 18),

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
                    : Text('Save Changes',
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

class _EditField extends StatelessWidget {
  const _EditField({required this.ctrl, required this.hint,
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

class _EditDropdown extends StatelessWidget {
  const _EditDropdown({
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

// ── Target diagram painter ────────────────────────────────────────────────────
class _TargetWithShotsPainter extends CustomPainter {
  const _TargetWithShotsPainter({
    required this.shots, required this.ringColor,
    required this.bullseyeColor, required this.dotColor,
  });
  final List<Offset> shots;
  final Color ringColor;
  final Color bullseyeColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    canvas.drawCircle(c, maxR, Paint()..color = const Color(0xFF1A2A1A));
    final ringPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8;
    for (final frac in [0.92, 0.7, 0.5, 0.3]) {
      ringPaint.color = ringColor;
      canvas.drawCircle(c, maxR * frac, ringPaint);
    }
    ringPaint..color = bullseyeColor..strokeWidth = 1.5;
    canvas.drawCircle(c, maxR * 0.13, ringPaint);
    final chPaint = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 0.8;
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, maxR * 0.18), chPaint);
    canvas.drawLine(Offset(c.dx, size.height - maxR * 0.18),
        Offset(c.dx, size.height), chPaint);
    canvas.drawLine(Offset(0, c.dy), Offset(maxR * 0.18, c.dy), chPaint);
    canvas.drawLine(Offset(size.width - maxR * 0.18, c.dy),
        Offset(size.width, c.dy), chPaint);
    final dotPaint = Paint()..color = dotColor.withOpacity(0.85);
    for (final shot in shots) {
      canvas.drawCircle(
          Offset(c.dx + shot.dx * maxR, c.dy + shot.dy * maxR), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
