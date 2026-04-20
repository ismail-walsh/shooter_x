import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/sx_ranks.dart';

// ─── RANK XP BAR ─────────────────────────────────────────────────────────────
class SXRankXPBar extends StatefulWidget {
  const SXRankXPBar({
    super.key,
    required this.level,
    required this.xp,
    required this.xpMax,
  });
  final int level;
  final int xp;
  final int xpMax;

  @override
  State<SXRankXPBar> createState() => _SXRankXPBarState();
}

class _SXRankXPBarState extends State<SXRankXPBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final target = widget.xpMax > 0 ? widget.xp / widget.xpMax : 0.0;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = Tween<double>(begin: 0, end: target.clamp(0.0, 1.0)).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final rank = getRank(widget.level);
    final xpToNext = (widget.xpMax - widget.xp).clamp(0, widget.xpMax);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rank.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(rank.icon, color: rank.color, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank.label,
                      style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Level ${widget.level}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.xp} XP',
                    style: GoogleFonts.interTight(
                      color: theme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/ ${widget.xpMax} XP',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress.value,
                minHeight: 6,
                backgroundColor: theme.alternate,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$xpToNext XP to next rank',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STREAK CARD ─────────────────────────────────────────────────────────────
class SXStreakCard extends StatefulWidget {
  const SXStreakCard({
    super.key,
    required this.streak,
    required this.bestStreak,
    this.activeDays = const {},
  });
  final int streak;
  final int bestStreak;
  /// Set of weekday indices (0=Mon … 6=Sun) that had a session this week.
  final Set<int> activeDays;

  @override
  State<SXStreakCard> createState() => _SXStreakCardState();
}

class _SXStreakCardState extends State<SXStreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const orange = Color(0xFFF97316);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _scale,
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.streak} Week Streak',
                  style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              // Best streak pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Best: ${widget.bestStreak}',
                  style: GoogleFonts.inter(
                    color: orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 7 day dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done = widget.activeDays.contains(i);
              final isToday = i == (DateTime.now().weekday - 1);
              return Column(
                children: [
                  _DayDot(done: done, isToday: isToday, orange: orange),
                  const SizedBox(height: 4),
                  Text(
                    _days[i],
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.done,
    required this.isToday,
    required this.orange,
  });
  final bool done;
  final bool isToday;
  final Color orange;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: orange,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
      );
    }
    if (isToday) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: orange,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(painter: _DashedCirclePainter(color: orange)),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The Container already draws the solid border; this is intentionally empty
    // to avoid double-drawing. The dashed look comes from the parent border.
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── WEEKLY CHALLENGE CARD ───────────────────────────────────────────────────
/// Pass [liveData] from Supabase (joined user_challenges + weekly_challenges rows).
/// Falls back to placeholder challenges when [liveData] is empty.
class SXWeeklyChallengeCard extends StatelessWidget {
  const SXWeeklyChallengeCard({super.key, this.liveData = const []});

  /// Each map should contain: title, progress (int), target (int), xp_reward (int)
  final List<Map<String, dynamic>> liveData;

  static const _fallback = [
    _Challenge(
      title: 'Shoot 3 sessions this week',
      current: 0,
      target: 3,
      xp: 500,
      icon: Icons.my_location_rounded,
    ),
    _Challenge(
      title: 'Score 90%+ in a session',
      current: 0,
      target: 1,
      xp: 350,
      icon: Icons.emoji_events_rounded,
    ),
    _Challenge(
      title: 'Try a new range',
      current: 0,
      target: 1,
      xp: 200,
      icon: Icons.location_on_rounded,
    ),
  ];

  List<_Challenge> get _challenges {
    if (liveData.isEmpty) return _fallback;
    return liveData.map((row) {
      final type = row['type'] as String? ?? '';
      IconData icon;
      if (type.contains('session')) icon = Icons.my_location_rounded;
      else if (type.contains('accuracy') || type.contains('score')) icon = Icons.emoji_events_rounded;
      else if (type.contains('range')) icon = Icons.location_on_rounded;
      else icon = Icons.bolt_rounded;
      return _Challenge(
        title: row['title'] as String? ?? row['type'] as String? ?? 'Challenge',
        current: (row['progress'] as int?) ?? 0,
        target: (row['target'] as int?) ?? 1,
        xp: (row['xp_reward'] as int?) ?? 100,
        icon: icon,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final items = _challenges;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Weekly Challenges',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Resets Sun',
                    style: GoogleFonts.inter(
                      color: theme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) {
            return _ChallengeRow(
              challenge: e.value,
              theme: theme,
              showDivider: e.key < items.length - 1,
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.challenge,
    required this.theme,
    required this.showDivider,
  });
  final _Challenge challenge;
  final FlutterFlowTheme theme;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final completed = challenge.current >= challenge.target;
    final progress =
        challenge.target > 0 ? challenge.current / challenge.target : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: completed
                          ? theme.primary.withOpacity(0.15)
                          : theme.alternate,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      challenge.icon,
                      color: completed
                          ? theme.primary
                          : Colors.white.withOpacity(0.5),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: GoogleFonts.inter(
                        color: completed
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // XP pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${challenge.xp} XP',
                      style: GoogleFonts.inter(
                        color: theme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: theme.alternate,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completed
                              ? theme.primary
                              : theme.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${challenge.current}/${challenge.target}',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: theme.borderColor,
            indent: 14,
            endIndent: 14,
          ),
        if (showDivider) const SizedBox(height: 10),
      ],
    );
  }
}

class _Challenge {
  const _Challenge({
    required this.title,
    required this.current,
    required this.target,
    required this.xp,
    required this.icon,
  });
  final String title;
  final int current;
  final int target;
  final int xp;
  final IconData icon;
}

// ─── ACTIVITY HEATMAP ────────────────────────────────────────────────────────
class SXActivityHeatmap extends StatelessWidget {
  const SXActivityHeatmap({super.key});

  // 12 weeks × 7 days of fake activity data (0–3)
  static final _data = List.generate(
    84,
    (i) {
      final r = math.Random(i * 7 + 13);
      if (i > 70) return 0; // recent weeks sparser
      if (r.nextDouble() > 0.55) return 0;
      return r.nextInt(3) + 1;
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final green = theme.primary;

    Color cellColor(int level) {
      switch (level) {
        case 1:
          return green.withOpacity(0.20);
        case 2:
          return green.withOpacity(0.55);
        case 3:
          return green;
        default:
          return theme.alternate;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Shooting Activity · 12 weeks',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid: 12 cols × 7 rows
          LayoutBuilder(
            builder: (context, constraints) {
              const cols = 12;
              const rows = 7;
              const gap = 3.0;
              final cellSize =
                  (constraints.maxWidth - (cols - 1) * gap) / cols;

              return SizedBox(
                height: rows * cellSize + (rows - 1) * gap,
                child: Row(
                  children: List.generate(cols, (col) {
                    return Expanded(
                      child: Column(
                        children: List.generate(rows, (row) {
                          final idx = col * rows + row;
                          final level = idx < _data.length ? _data[idx] : 0;
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: row < rows - 1 ? gap : 0,
                                right: col < cols - 1 ? gap : 0,
                              ),
                              decoration: BoxDecoration(
                                color: cellColor(level),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 4),
              ...List.generate(4, (i) {
                return Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: cellColor(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              Text(
                'More',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── ACHIEVEMENT TOAST ───────────────────────────────────────────────────────
class SXAchievementToast extends StatefulWidget {
  const SXAchievementToast({
    super.key,
    required this.label,
    required this.desc,
    required this.onDone,
  });
  final String label;
  final String desc;
  final VoidCallback onDone;

  /// Shows the toast as an overlay. Call this instead of adding to widget tree directly.
  static void show(
    BuildContext context, {
    required String label,
    required String desc,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => SXAchievementToast(
        label: label,
        desc: desc,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<SXAchievementToast> createState() => _SXAchievementToastState();
}

class _SXAchievementToastState extends State<SXAchievementToast>
    with TickerProviderStateMixin {
  late AnimationController _slide;
  late AnimationController _pulse;
  late Animation<Offset> _offset;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slide, curve: Curves.easeOutBack));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slide,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _slide.forward();
    Future.delayed(const Duration(milliseconds: 3500), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _slide.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _slide.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF3DD162);
    const darkGreen = Color(0xFF0D2010);

    return Positioned(
      bottom: 32,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _offset,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF122612), darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: green.withOpacity(0.4), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: green.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: green,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievement Unlocked!',
                          style: GoogleFonts.inter(
                            color: green,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.label,
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.desc,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
