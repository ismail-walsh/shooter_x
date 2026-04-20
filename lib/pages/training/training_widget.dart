import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class TrainingWidget extends StatefulWidget {
  const TrainingWidget({super.key});
  static const String routeName = 'Training';
  static const String routePath = '/training';

  @override
  State<TrainingWidget> createState() => _TrainingWidgetState();
}

class _TrainingWidgetState extends State<TrainingWidget> {
  bool _loading = true;
  Map<String, List<TrainingModulesRow>> _grouped = {};
  List<String> _cats = [];
  String? _activeCat;

  // Fallback static data when DB is empty
  static const _fallbackCats = [
    'Deer Stalking', 'Game Shooting', 'Clay Shooting', 'Precision',
  ];
  static const _fallbackCourses = {
    'Deer Stalking': [
      {'title': 'Deer Stalking Cert. Level 1', 'desc': 'Nationally recognised entry-level qualification for newly engaging stalkers in the UK.', 'level': 'Beginner'},
      {'title': 'Deer Stalking Cert. Level 2', 'desc': 'Practising stalkers focusing on practical fieldcraft and deer species identification.', 'level': 'Intermediate'},
      {'title': 'Game Meat Hygiene Level 1', 'desc': 'Required alongside Level 1 for those engaging specifically in stalking activities.', 'level': 'Beginner'},
      {'title': 'Firearms Awareness & Safety', 'desc': 'Thorough grounding in the safe management and care of firearms, offered by BASC.', 'level': 'Beginner'},
    ],
    'Game Shooting': [
      {'title': 'Gamekeeper Foundations', 'desc': 'Essential knowledge covering rearing, habitat management and predator control.', 'level': 'Beginner'},
      {'title': 'Driven Game Shooting Skills', 'desc': 'Advanced techniques for driven game, including gun mount and safe handling.', 'level': 'Intermediate'},
      {'title': 'BASC Young Shots Course', 'desc': 'Designed for newcomers aged 14–24, covering safety and fieldcraft.', 'level': 'Beginner'},
    ],
    'Clay Shooting': [
      {'title': 'Clay Shooting Fundamentals', 'desc': 'Consistent technique for English Sporting, Skeet and Trap disciplines.', 'level': 'Beginner'},
      {'title': 'CPSA Coach Qualification', 'desc': 'Nationally recognised instructor qualification from the CPSA.', 'level': 'Advanced'},
      {'title': 'Sporting Clays — Intermediate', 'desc': 'Teal, crossing and rabbit presentations — extend your shot repertoire.', 'level': 'Intermediate'},
    ],
    'Precision': [
      {'title': 'Long Range Fundamentals', 'desc': 'External ballistics, wind reading and positional shooting at extended range.', 'level': 'Beginner'},
      {'title': 'PRS Competitor Prep', 'desc': 'Practical Rifle Series stage reading and time management under pressure.', 'level': 'Intermediate'},
      {'title': 'Reloading for Accuracy', 'desc': 'Load development, primer selection and seating depth for maximum precision.', 'level': 'Advanced'},
    ],
  };

  static const _levelColors = <String, Color>{
    'beginner': Color(0xFF3DD162),
    'intermediate': Color(0xFFF59E0B),
    'advanced': Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final modules = await TrainingModulesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('is_active', true)
            .order('discipline')
            .order('title'),
      );
      if (mounted) {
        if (modules.isEmpty) {
          // Use fallback static data
          setState(() {
            _cats = List.from(_fallbackCats);
            _activeCat = _fallbackCats.first;
            _loading = false;
          });
        } else {
          final grouped = <String, List<TrainingModulesRow>>{};
          for (final m in modules) {
            final key = m.discipline ?? m.category ?? 'General';
            grouped.putIfAbsent(key, () => []).add(m);
          }
          final cats = grouped.keys.toList();
          setState(() {
            _grouped = grouped;
            _cats = cats;
            _activeCat = cats.isNotEmpty ? cats.first : null;
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _cats = List.from(_fallbackCats);
          _activeCat = _fallbackCats.first;
          _loading = false;
        });
      }
    }
  }

  Color _levelColor(String? level) {
    if (level == null) return const Color(0xFF3DD162);
    return _levelColors[level.toLowerCase()] ?? const Color(0xFF3DD162);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, theme)),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildCategoryPills(context, theme)),
            if (_grouped.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final modules = _grouped[_activeCat] ?? [];
                    return _buildModuleCard(ctx, theme, modules[i]);
                  },
                  childCount: (_grouped[_activeCat] ?? []).length,
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final courses =
                        (_fallbackCourses[_activeCat] as List?) ?? [];
                    return _buildFallbackCard(ctx, theme, courses[i] as Map, i);
                  },
                  childCount:
                      ((_fallbackCourses[_activeCat] as List?) ?? []).length,
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        Text('Training',
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const Spacer(),
        SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': currentUserUid ?? ''})),
      ]),
    );
  }

  Widget _buildCategoryPills(BuildContext context, FlutterFlowTheme theme) {
    final cats = _cats.isNotEmpty ? _cats : _fallbackCats;
    return Column(children: [
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final active = cats[i] == _activeCat;
            return GestureDetector(
              onTap: () => setState(() => _activeCat = cats[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? theme.primary : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(cats[i],
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  Widget _buildModuleCard(BuildContext context, FlutterFlowTheme theme,
      TrainingModulesRow module) {
    final color = _levelColor(module.level);
    final hasImg = module.imageUrl != null && module.imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: () => context.pushNamed('CourseDetail',
          queryParameters: {'courseId': module.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: hasImg
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl: module.imageUrl!,
                      width: 56, height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.school_rounded, color: color, size: 22),
                    ),
                  )
                : Icon(Icons.school_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title ?? 'Module',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                        module.level != null
                            ? _capitalize(module.level!)
                            : 'Beginner',
                        style: GoogleFonts.inter(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (module.duration != null) ...[
                    const SizedBox(width: 6),
                    Text('${module.duration} min',
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10)),
                  ],
                ]),
                if (module.description != null &&
                    module.description!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(module.description!,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          height: 1.45)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3), size: 18),
        ]),
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context, FlutterFlowTheme theme,
      Map course, int index) {
    final levelStr = course['level'] as String? ?? 'Beginner';
    final color = _levelColor(levelStr);
    return GestureDetector(
      onTap: () => context.pushNamed('CourseDetail',
          queryParameters: {'courseId': 'course_$index'}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.school_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course['title'] as String,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(levelStr,
                      style: GoogleFonts.inter(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 5),
                Text(course['desc'] as String,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        height: 1.45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3), size: 18),
        ]),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
