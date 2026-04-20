import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import '/utils/sx_discipline_theme.dart';

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({super.key});
  static const String routeName = 'Activity';
  static const String routePath = '/activity';

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget>
    with SingleTickerProviderStateMixin {
  // Sport picker
  String? _selectedDiscipline; // null = All
  bool _showPicker = false;
  List<String> _disciplines = [];
  late AnimationController _pickerAnim;
  late Animation<double> _pickerFade;

  // Data
  bool _loading = true;
  UsersRow? _user;
  List<SessionsRow> _allSessions = [];
  List<EventsRow> _competitions = [];

  @override
  void initState() {
    super.initState();
    _pickerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _pickerFade = CurvedAnimation(
      parent: _pickerAnim,
      curve: Curves.easeOut,
    );
    _load();
  }

  @override
  void dispose() {
    _pickerAnim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        databaseService.getCurrentUserProfile().catchError((_) => null),
        DisciplinesTable()
            .queryRows(queryFn: (q) => q.order('discipline_name'))
            .catchError((_) => <DisciplinesRow>[]),
        databaseService.getRecentSessions(limit: 20)
            .catchError((_) => <SessionsRow>[]),
        databaseService.getAllEvents().catchError((_) => <EventsRow>[]),
      ]).timeout(const Duration(seconds: 12), onTimeout: () => [
        null, <DisciplinesRow>[], <SessionsRow>[], <EventsRow>[],
      ]);

      if (!mounted) return;

      final rawDiscs = results[1] as List<DisciplinesRow>;
      final allDiscs = rawDiscs
          .map((d) => d.disciplineName)
          .whereType<String>()
          .toList();

      final allEvents = results[3] as List<EventsRow>;
      allEvents.sort((a, b) {
        final aLive = a.status == 'live';
        final bLive = b.status == 'live';
        if (aLive && !bLive) return -1;
        if (!aLive && bLive) return 1;
        return (a.date ?? DateTime(2099)).compareTo(b.date ?? DateTime(2099));
      });

      setState(() {
        _user = results[0] as UsersRow?;
        _disciplines = allDiscs;
        _allSessions = results[2] as List<SessionsRow>;
        _competitions = allEvents.take(6).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _togglePicker() {
    setState(() => _showPicker = !_showPicker);
    if (_showPicker) {
      _pickerAnim.forward();
    } else {
      _pickerAnim.reverse();
    }
  }

  void _selectDiscipline(String? d) {
    setState(() {
      _selectedDiscipline = d;
      _showPicker = false;
    });
    _pickerAnim.reverse();
  }

  List<SessionsRow> get _filteredSessions {
    if (_selectedDiscipline == null) return _allSessions;
    return _allSessions
        .where((s) =>
            (s.discipline ?? '').toLowerCase() ==
            _selectedDiscipline!.toLowerCase())
        .toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${m[dt.month - 1]}';
  }

  static String _sessionBadge(SessionsRow s) {
    if (s.isPersonalBest == true) return 'PB';
    final diff = DateTime.now().difference(s.createdAt ?? DateTime.now());
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  static bool _isLive(EventsRow e) => e.status == 'live';

  String _competitionDueLabel(EventsRow e) {
    if (_isLive(e)) return 'Live now';
    if (e.date == null) return 'Coming soon';
    final diff = e.date!.difference(DateTime.now());
    if (diff.inDays <= 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays <= 7) return 'In ${diff.inDays} days';
    return _fmtDate(e.date);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable body ────────────────────────────────────────────
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, theme)),
                SliverToBoxAdapter(child: _buildSportPicker(context, theme)),
                SliverToBoxAdapter(child: _buildActionGrid(context, theme)),
                SliverToBoxAdapter(
                    child: _buildRecentSessions(context, theme)),
                SliverToBoxAdapter(
                    child: _buildCompetitions(context, theme)),
                // Pad above FAB + nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),

            // ── Record Shoot floating pill ─────────────────────────────────
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(child: _buildRecordFAB(context, theme)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'Activity',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pushNamed(
              'UserProfile',
              queryParameters: {'userId': currentUserUid},
            ),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor),
              ),
              child: ClipOval(
                child: _user?.profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: _user!.profileImg!,
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _avatarPlaceholder(),
                      )
                    : _avatarPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() => Icon(
        Icons.person_rounded,
        color: Colors.white.withOpacity(0.45),
        size: 17,
      );

  // ── Sport Picker ──────────────────────────────────────────────────────────

  Widget _buildSportPicker(BuildContext context, FlutterFlowTheme theme) {
    final label = _selectedDiscipline ?? 'All Sports';
    final options = <String?>[null, ..._disciplines];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill trigger
          GestureDetector(
            onTap: _togglePicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _showPicker
                    ? theme.alternate
                    : theme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showPicker
                      ? theme.primary.withOpacity(0.5)
                      : theme.borderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: _selectedDiscipline != null
                          ? theme.primary
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _showPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated dropdown list
          FadeTransition(
            opacity: _pickerFade,
            child: SizeTransition(
              sizeFactor: _pickerFade,
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: options.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final opt = entry.value;
                      final optLabel = opt ?? 'All Sports';
                      final isSelected = opt == _selectedDiscipline;
                      final isLast = idx == options.length - 1;

                      return GestureDetector(
                        onTap: () => _selectDiscipline(opt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primary.withOpacity(0.08)
                                : Colors.transparent,
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                        color: theme.borderColor,
                                        width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  optLabel,
                                  style: GoogleFonts.inter(
                                    color: isSelected
                                        ? theme.primary
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_rounded,
                                    color: theme.primary, size: 16),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Grid ───────────────────────────────────────────────────────────

  Widget _buildActionGrid(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          SXActionButton(
            label: 'Log Shot',
            icon: Icons.adjust_rounded,
            onTap: () => context.pushNamed('AddSession'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Scan Target',
            icon: Icons.qr_code_scanner_rounded,
            onTap: () => context.pushNamed('ScanTarget'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Find Range',
            icon: Icons.location_on_rounded,
            onTap: () => context.pushNamed('FindRange'),
          ),
          const SizedBox(width: 8),
          SXActionButton(
            label: 'Compete',
            icon: Icons.emoji_events_rounded,
            onTap: () => context.pushNamed('EventCard'),
          ),
        ],
      ),
    );
  }

  // ── Recent Sessions ───────────────────────────────────────────────────────

  Widget _buildRecentSessions(BuildContext context, FlutterFlowTheme theme) {
    final sessions = _filteredSessions.take(6).toList();
    final sectionLabel = _selectedDiscipline != null
        ? '$_selectedDiscipline Sessions'
        : 'Recent Sessions';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SXSectionTitle(
          label: sectionLabel,
          actionLabel: 'See All',
          onAction: () => context.pushNamed('AllSessions'),
        ),
        if (_loading)
          const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Text(
              _selectedDiscipline != null
                  ? 'No $_selectedDiscipline sessions yet.'
                  : 'No sessions yet — log your first shot!',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final s = sessions[i];
                final discipline = s.discipline ?? s.location ?? '';
                final dt = getDisciplineTheme(discipline);
                return _SessionCard(
                  session: s,
                  badge: _sessionBadge(s),
                  date: _fmtDate(s.createdAt),
                  disciplineTheme: dt,
                  onTap: () => context.pushNamed(
                    'SessionSummary',
                    queryParameters: {'sessionId': s.id},
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Competitions ──────────────────────────────────────────────────────────

  Widget _buildCompetitions(BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SXSectionTitle(label: 'Competitions'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_competitions.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'No upcoming competitions.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          )
        else
          ..._competitions.map(
            (e) => _CompetitionTile(
              event: e,
              dueLabel: _competitionDueLabel(e),
              isLive: _isLive(e),
              theme: theme,
              onTap: () => context.pushNamed(
                'EventDetails',
                queryParameters: {'eventId': e.id},
              ),
            ),
          ),
      ],
    );
  }

  // ── Record Shoot FAB ──────────────────────────────────────────────────────

  Widget _buildRecordFAB(BuildContext context, FlutterFlowTheme theme) {
    return GestureDetector(
      onTap: () => context.pushNamed('RecordShoot'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 24, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: theme.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Text(
              'Record Shoot',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SESSION CARD ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.badge,
    required this.date,
    required this.disciplineTheme,
    this.onTap,
  });
  final SessionsRow session;
  final String badge;
  final String date;
  final DisciplineTheme disciplineTheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dt = disciplineTheme;
    final score = '${(session.accuracy ?? 0).toStringAsFixed(0)}%';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient hero
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: dt.grad,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child:
                      Center(child: Icon(dt.icon, color: dt.accent, size: 28)),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          theme.primaryBackground.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        color: badge == 'PB'
                            ? theme.primary
                            : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.location ?? session.discipline ?? '—',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    score,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMPETITION TILE ─────────────────────────────────────────────────────────

class _CompetitionTile extends StatelessWidget {
  const _CompetitionTile({
    required this.event,
    required this.dueLabel,
    required this.isLive,
    required this.theme,
    this.onTap,
  });
  final EventsRow event;
  final String dueLabel;
  final bool isLive;
  final FlutterFlowTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isLive
                ? theme.primary.withOpacity(0.35)
                : theme.borderColor,
          ),
        ),
        child: Row(
          children: [
            // Icon square
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isLive
                    ? theme.primary.withOpacity(0.12)
                    : theme.alternate,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: isLive
                    ? theme.primary
                    : Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (event.discipline?.isNotEmpty == true)
                    Text(
                      event.discipline!,
                      style: GoogleFonts.inter(
                        color: theme.primary,
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    dueLabel,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Live badge or chevron
            if (isLive) ...[
              const SXLiveBadge(),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.25),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
