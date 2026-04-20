import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/sx_shared_widgets.dart';

// ── Level colours ─────────────────────────────────────────────────────────────
const _kBeginner = Color(0xFF3DD162);
const _kIntermediate = Color(0xFFF59E0B);
const _kAdvanced = Color(0xFFEF4444);

Color _levelColor(String? level) {
  switch ((level ?? '').toLowerCase()) {
    case 'intermediate':
      return _kIntermediate;
    case 'advanced':
      return _kAdvanced;
    default:
      return _kBeginner;
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// ── Fallback course data ──────────────────────────────────────────────────────

const _fallbackCourses = [
  {
    'title': 'Deer Stalking Cert. Level 1',
    'description':
        'The DSC Level 1 is the nationally recognised entry-level qualification for anyone engaging in deer stalking in the UK.',
    'level': 'Beginner',
    'discipline': 'Deer Stalking',
    'duration': 120,
    'topics': [
      'UK Deer Species Identification',
      'Deer Behaviour & Biology',
      'Legal Framework (Deer Acts)',
      'Rifle Safety & Handling',
      'Safe Shot Placement',
      'Larder Hygiene Basics',
    ],
  },
  {
    'title': 'Deer Stalking Cert. Level 2',
    'description':
        'DSC Level 2 is for practising stalkers wishing to demonstrate competency in all aspects of deer management.',
    'level': 'Intermediate',
    'discipline': 'Deer Stalking',
    'duration': 240,
    'topics': [
      'Advanced Fieldcraft & Approach',
      'Deer Management Planning',
      'Woodland & Open Ground Technique',
      'Carcass Inspection & Grading',
      'Deer Management Legislation',
      'Stalking Equipment & Maintenance',
    ],
  },
  {
    'title': 'Game Meat Hygiene Level 1',
    'description':
        'Required for those supplying game to the food chain. Covers hygiene standards for handling game meat.',
    'level': 'Beginner',
    'discipline': 'Deer Stalking',
    'duration': 90,
    'topics': [
      'Food Hygiene Legislation',
      'Ante- & Post-mortem Inspection',
      'Carcass Chilling & Storage',
      'Transportation Requirements',
      'Record Keeping',
    ],
  },
  {
    'title': 'Firearms Awareness & Safety',
    'description':
        'A thorough grounding in the safe management and care of firearms, offered by BASC.',
    'level': 'Beginner',
    'discipline': 'Deer Stalking',
    'duration': 90,
    'topics': [
      'Safe Handling & Storage',
      'The Law on Firearms Certificates',
      'Choosing the Right Calibre',
      'Cleaning & Maintenance',
      'Range Safety & Protocol',
    ],
  },
  {
    'title': 'Gamekeeper Foundations',
    'description':
        'Essential knowledge covering rearing, habitat management and legal predator control.',
    'level': 'Beginner',
    'discipline': 'Game Shooting',
    'duration': 120,
    'topics': [
      'Game Rearing & Release',
      'Habitat & Cover Management',
      'Legal Predator Control',
      'Vermin Management',
      'Estate Law & Liability',
    ],
  },
  {
    'title': 'Driven Game Shooting Skills',
    'description':
        'Advanced techniques for driven game days, covering correct gun mount and safe muzzle awareness.',
    'level': 'Intermediate',
    'discipline': 'Game Shooting',
    'duration': 180,
    'topics': [
      'Gun Fit & Mount Technique',
      'Driven Bird Presentations',
      'Safe Zone of Fire',
      'Etiquette & Safety',
      'Shot Selection & Timing',
    ],
  },
  {
    'title': 'BASC Young Shots Course',
    'description':
        'Designed for newcomers aged 14–24, covering safety and fieldcraft basics.',
    'level': 'Beginner',
    'discipline': 'Game Shooting',
    'duration': 90,
    'topics': [
      'Firearm Safety Fundamentals',
      'Countryside Awareness',
      'Basic Fieldcraft',
      'Wildlife Identification',
      'Introduction to Clay & Live Quarry',
    ],
  },
  {
    'title': 'Clay Shooting Fundamentals',
    'description':
        'Develop a consistent technique for English Sporting, Skeet and Trap disciplines.',
    'level': 'Beginner',
    'discipline': 'Clay Shooting',
    'duration': 120,
    'topics': [
      'Safe Gun Handling',
      'Stance & Foot Position',
      'Gun Mount & Cheek Weld',
      'Eye Dominance Assessment',
      'English Sporting Targets',
      'DTL & Skeet Introduction',
    ],
  },
  {
    'title': 'CPSA Coach Qualification',
    'description':
        'Nationally recognised instructor qualification from the Clay Pigeon Shooting Association.',
    'level': 'Advanced',
    'discipline': 'Clay Shooting',
    'duration': 300,
    'topics': [
      'Coaching Methodology',
      'Shot Analysis & Fault Correction',
      'Range Management',
      'Risk Assessment',
      'Child Protection & Safeguarding',
      'CPSA Rules & Regulations',
    ],
  },
  {
    'title': 'Sporting Clays — Intermediate',
    'description':
        'Extend your shot repertoire to teal, crossing rabbits, high driven birds and simultaneous pairs.',
    'level': 'Intermediate',
    'discipline': 'Clay Shooting',
    'duration': 150,
    'topics': [
      'Reading Target Trajectory',
      'Teal & Springing Teal',
      'Crossing & Going-away Rabbits',
      'High Driven Bird Approach',
      'Simultaneous Pair Strategy',
      'Mental Management Between Stands',
    ],
  },
  {
    'title': 'Long Range Fundamentals',
    'description':
        'External ballistics, wind reading and positional shooting at extended ranges (300–1000 m).',
    'level': 'Beginner',
    'discipline': 'Precision',
    'duration': 180,
    'topics': [
      'External Ballistics & Trajectory',
      'Ballistic Coefficient & BC Selection',
      'Wind Reading & Estimation',
      'Prone, Bipod & Bagged Positions',
      'Scope Setup & Zeroing',
      'Data Book Use',
    ],
  },
  {
    'title': 'PRS Competitor Prep',
    'description':
        'Practical Rifle Series stage reading, time management and match-day mindset.',
    'level': 'Intermediate',
    'discipline': 'Precision',
    'duration': 210,
    'topics': [
      'Stage Planning & Walk-through',
      'Positional Shooting (Barricades, Kneeling, Sitting)',
      'Time Management Under Pressure',
      'Cold Bore & First-round Hits',
      'Gear Setup & Equipment Check',
      'Match-day Mental Preparation',
    ],
  },
  {
    'title': 'Reloading for Accuracy',
    'description':
        'Load development focused on accuracy — primer selection, seating depth and bullet jump.',
    'level': 'Advanced',
    'discipline': 'Precision',
    'duration': 180,
    'topics': [
      'Case Preparation & Trimming',
      'Primer Types & Seating Depth',
      'Powder Selection & Weighing',
      'Bullet Jump & COAL Measurement',
      'Load Development Ladder Tests',
      'Record Keeping & Load Books',
    ],
  },
];

// ── Widget ────────────────────────────────────────────────────────────────────

class CourseDetailWidget extends StatefulWidget {
  const CourseDetailWidget({super.key, this.courseId});
  final String? courseId;

  static const String routeName = 'CourseDetail';
  static const String routePath = '/courseDetail';

  @override
  State<CourseDetailWidget> createState() => _CourseDetailWidgetState();
}

class _CourseDetailWidgetState extends State<CourseDetailWidget> {
  bool _loading = true;
  bool _enrolling = false;

  TrainingModulesRow? _module;
  TrainingProgressRow? _progress; // null = not enrolled
  Set<String> _completedLessons = {}; // set of lesson keys

  // ── Derived helpers ──────────────────────────────────────────────────────

  bool get _isFallback =>
      (widget.courseId ?? '').startsWith('course_');

  Map<String, dynamic>? get _fallbackData {
    if (!_isFallback) return null;
    final idx = int.tryParse(
        (widget.courseId ?? '').replaceFirst('course_', ''));
    if (idx == null || idx >= _fallbackCourses.length) return null;
    return _fallbackCourses[idx];
  }

  String get _title =>
      _module?.title ?? _fallbackData?['title'] as String? ?? 'Course';
  String get _description =>
      _module?.description ??
      _fallbackData?['description'] as String? ??
      '';
  String get _level =>
      _module?.level ?? _fallbackData?['level'] as String? ?? 'Beginner';
  String get _discipline =>
      _module?.discipline ?? _fallbackData?['discipline'] as String? ?? '';
  int? get _duration =>
      _module?.duration ?? _fallbackData?['duration'] as int?;
  String? get _imageUrl => _module?.imageUrl;

  List<String> get _topics {
    if (_isFallback) {
      final list = _fallbackData?['topics'];
      if (list is List) return list.cast<String>();
    }
    // DB module: generate from discipline/level
    return _genericTopics(_discipline, _level);
  }

  static List<String> _genericTopics(String discipline, String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return [
          'Expert Theory & Principles',
          'Advanced Practical Skills',
          'Scenario-based Training',
          'Performance Analysis',
          'Certification Assessment',
        ];
      case 'intermediate':
        return [
          'Review of Fundamentals',
          'Intermediate Techniques',
          'Applied Practice',
          'Scenario Training',
          'Progress Assessment',
        ];
      default: // beginner
        return [
          'Introduction & Safety',
          'Core Concepts',
          'Practical Skills',
          'Fieldwork Basics',
          'Foundation Assessment',
        ];
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.courseId ?? '';
    try {
      // Load module from DB (skip for fallback IDs)
      TrainingModulesRow? module;
      if (!_isFallback && id.isNotEmpty) {
        final rows = await TrainingModulesTable().queryRows(
          queryFn: (q) => q.eqOrNull('id', id),
        );
        module = rows.isNotEmpty ? rows.first : null;
      }

      // Check enrollment
      TrainingProgressRow? progress;
      Set<String> completed = {};
      final uid = currentUserUid;
      if (uid != null && uid.isNotEmpty) {
        final progressRows = await TrainingProgressTable().queryRows(
          queryFn: (q) => q
              .eqOrNull('user_id', uid)
              .eqOrNull('module', id),
        );
        if (progressRows.isNotEmpty) {
          progress = progressRows.first;
          // Load completed lessons for this enrollment
          final detailRows = await ProgressDetailsTable().queryRows(
            queryFn: (q) => q
                .eqOrNull('user_id', uid)
                .eqOrNull('training_id', progress!.id)
                .eqOrNull('status', 'completed'),
          );
          completed = detailRows.map((r) => r.lesson ?? '').toSet();
        }
      }

      if (mounted) {
        setState(() {
          _module = module;
          _progress = progress;
          _completedLessons = completed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Enrol / Unenrol ──────────────────────────────────────────────────────

  Future<void> _toggleEnrolment() async {
    final uid = currentUserUid;
    if (uid == null || uid.isEmpty || _enrolling) return;

    setState(() => _enrolling = true);
    try {
      if (_progress == null) {
        // Enrol
        final rows = await TrainingProgressTable().insert({
          'user_id': uid,
          'training_type': _discipline,
          'module': widget.courseId,
          'progress': 0.0,
        });
        if (mounted) setState(() => _progress = rows);
      } else {
        // Unenrol — delete progress + details
        await ProgressDetailsTable().delete(
          matchingRows: (q) => q.eqOrNull('training_id', _progress!.id),
        );
        await TrainingProgressTable().delete(
          matchingRows: (q) => q.eqOrNull('id', _progress!.id),
        );
        if (mounted) {
          setState(() {
            _progress = null;
            _completedLessons = {};
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong — please try again.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ));
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Future<void> _toggleLesson(int index) async {
    if (_progress == null) return; // must be enrolled
    final key = 'lesson_$index';
    final uid = currentUserUid;
    if (uid == null) return;

    setState(() {
      if (_completedLessons.contains(key)) {
        _completedLessons.remove(key);
      } else {
        _completedLessons.add(key);
      }
    });

    try {
      if (_completedLessons.contains(key)) {
        await ProgressDetailsTable().insert({
          'user_id': uid,
          'training_id': _progress!.id,
          'lesson': key,
          'status': 'completed',
        });
      } else {
        await ProgressDetailsTable().delete(
          matchingRows: (q) => q
              .eqOrNull('user_id', uid)
              .eqOrNull('training_id', _progress!.id)
              .eqOrNull('lesson', key),
        );
      }
      // Update overall progress
      final done = _completedLessons.length;
      final total = _topics.length;
      final pct = total > 0 ? done / total : 0.0;
      await TrainingProgressTable().update(
        data: {'progress': pct},
        matchingRows: (q) => q.eqOrNull('id', _progress!.id),
      );
    } catch (_) {
      // Revert optimistic update on failure
      if (mounted) {
        setState(() {
          if (_completedLessons.contains(key)) {
            _completedLessons.remove(key);
          } else {
            _completedLessons.add(key);
          }
        });
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Course Details'),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(theme),
                    const SizedBox(height: 16),
                    if (_description.isNotEmpty) ...[
                      Text(_description,
                          style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 13,
                              height: 1.6)),
                      const SizedBox(height: 20),
                    ],
                    _buildModulesSection(theme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildEnrolButton(theme),
          ],
        ]),
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────────────

  Widget _buildHeroBanner(FlutterFlowTheme theme) {
    final color = _levelColor(_level);
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2E1A), Color(0xFF0D1A0D)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _imageUrl != null && _imageUrl!.isNotEmpty
          ? Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _imageUrl!,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _bannerContent(color),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: _bannerTextRow(color),
              ),
            ])
          : _bannerContent(color),
    );
  }

  Widget _bannerContent(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.school_rounded, color: color, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: _bannerTextRow(color)),
      ]),
    );
  }

  Widget _bannerTextRow(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_title,
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1.25)),
        const SizedBox(height: 6),
        Row(children: [
          _LevelBadge(level: _level),
          if (_discipline.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(_discipline,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ),
          ],
          if (_duration != null) ...[
            const SizedBox(width: 6),
            Row(children: [
              Icon(Icons.schedule_rounded,
                  color: Colors.white.withOpacity(0.4), size: 11),
              const SizedBox(width: 3),
              Text('$_duration min',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10)),
            ]),
          ],
        ]),
      ],
    );
  }

  // ── Modules list ─────────────────────────────────────────────────────────

  Widget _buildModulesSection(FlutterFlowTheme theme) {
    final topics = _topics;
    final enrolled = _progress != null;
    final done = _completedLessons.length;
    final total = topics.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Section title + progress
      Row(children: [
        Text('Course Modules',
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        if (enrolled)
          Text('$done/$total',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
      ]),
      if (enrolled) ...[
        const SizedBox(height: 8),
        _ProgressBar(value: total > 0 ? done / total : 0.0),
      ],
      const SizedBox(height: 10),
      // Module cards
      Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          children: List.generate(topics.length, (i) {
            final key = 'lesson_$i';
            final completed = _completedLessons.contains(key);
            final isLast = i == topics.length - 1;
            return _ModuleRow(
              index: i + 1,
              title: topics[i],
              completed: completed,
              locked: !enrolled && !completed,
              showDivider: !isLast,
              onTap: enrolled ? () => _toggleLesson(i) : null,
              theme: theme,
            );
          }),
        ),
      ),
    ]);
  }

  // ── Enrol button ─────────────────────────────────────────────────────────

  Widget _buildEnrolButton(FlutterFlowTheme theme) {
    final enrolled = _progress != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: GestureDetector(
        onTap: _enrolling ? null : _toggleEnrolment,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: enrolled ? Colors.transparent : theme.primary,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: enrolled
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: _enrolling
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            enrolled ? Colors.white.withOpacity(0.6) : Colors.white),
                  )
                : Text(
                    enrolled ? 'Unenrol from Course' : 'Enrol Now',
                    style: GoogleFonts.interTight(
                        color: enrolled
                            ? Colors.white.withOpacity(0.55)
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(_capitalize(level),
          style: GoogleFonts.inter(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: theme.alternate,
        valueColor: const AlwaysStoppedAnimation<Color>(_kBeginner),
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.index,
    required this.title,
    required this.completed,
    required this.locked,
    required this.showDivider,
    required this.theme,
    this.onTap,
  });
  final int index;
  final String title;
  final bool completed;
  final bool locked;
  final bool showDivider;
  final FlutterFlowTheme theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            // Circle icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: completed
                    ? _kBeginner.withOpacity(0.15)
                    : theme.alternate,
                shape: BoxShape.circle,
              ),
              child: completed
                  ? const Icon(Icons.check_rounded,
                      color: _kBeginner, size: 16)
                  : Text(
                      index.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(
                              locked ? 0.25 : 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                    color: Colors.white
                        .withOpacity(locked ? 0.3 : (completed ? 0.6 : 0.9)),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.white.withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 8),
            // Trailing icon
            if (completed)
              Icon(Icons.check_circle_rounded,
                  color: _kBeginner.withOpacity(0.7), size: 16)
            else if (locked)
              Icon(Icons.lock_outline_rounded,
                  color: Colors.white.withOpacity(0.2), size: 16)
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 18),
          ]),
        ),
      ),
      if (showDivider) Divider(color: theme.borderColor, height: 1),
    ]);
  }
}
