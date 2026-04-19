// training_widget.dart
// Replaces lib/pages/training/training_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _cat = 'Deer Stalking';

  static const _cats = [
    'Deer Stalking', 'Game Shooting', 'Clay Shooting', 'Precision',
  ];

  static const _courses = {
    'Deer Stalking': [
      {'title': 'Deer Stalking Cert. Level 1', 'desc': 'Nationally recognised entry-level qualification for newly engaging stalkers in the UK.', 'level': 0},
      {'title': 'Deer Stalking Cert. Level 2', 'desc': 'Practising stalkers focusing on practical fieldcraft and deer species identification.', 'level': 1},
      {'title': 'Game Meat Hygiene Level 1', 'desc': 'Required alongside Level 1 for those engaging specifically in stalking activities.', 'level': 0},
      {'title': 'Firearms Awareness & Safety', 'desc': 'Thorough grounding in the safe management and care of firearms, offered by BASC.', 'level': 0},
    ],
    'Game Shooting': [
      {'title': 'Gamekeeper Foundations', 'desc': 'Essential knowledge covering rearing, habitat management and predator control.', 'level': 0},
      {'title': 'Driven Game Shooting Skills', 'desc': 'Advanced techniques for driven game, including gun mount and safe handling.', 'level': 1},
      {'title': 'BASC Young Shots Course', 'desc': 'Designed for newcomers aged 14–24, covering safety and fieldcraft.', 'level': 0},
    ],
    'Clay Shooting': [
      {'title': 'Clay Shooting Fundamentals', 'desc': 'Consistent technique for English Sporting, Skeet and Trap disciplines.', 'level': 0},
      {'title': 'CPSA Coach Qualification', 'desc': 'Nationally recognised instructor qualification from the CPSA.', 'level': 2},
      {'title': 'Sporting Clays — Intermediate', 'desc': 'Teal, crossing and rabbit presentations — extend your shot repertoire.', 'level': 1},
    ],
    'Precision': [
      {'title': 'Long Range Fundamentals', 'desc': 'External ballistics, wind reading and positional shooting at extended range.', 'level': 0},
      {'title': 'PRS Competitor Prep', 'desc': 'Practical Rifle Series stage reading and time management under pressure.', 'level': 1},
      {'title': 'Reloading for Accuracy', 'desc': 'Load development, primer selection and seating depth for maximum precision.', 'level': 2},
    ],
  };

  static const _levelColors = [
    Color(0xFF3DD162), Color(0xFFF59E0B), Color(0xFFEF4444),
  ];
  static const _levelLabels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final courses = _courses[_cat] ?? [];
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, theme)),
          SliverToBoxAdapter(child: _buildCategoryPills(context, theme)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildCourseCard(ctx, theme, courses[i], i),
              childCount: courses.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        Text('Training', style: GoogleFonts.interTight(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
            letterSpacing: -0.5)),
        const Spacer(),
        SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': 'me'})),
      ]),
    );
  }

  Widget _buildCategoryPills(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final active = _cats[i] == _cat;
            return GestureDetector(
              onTap: () => setState(() => _cat = _cats[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? theme.primary : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(_cats[i],
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  Widget _buildCourseCard(BuildContext context, FlutterFlowTheme theme,
      Map course, int index) {
    final level = course['level'] as int;
    final color = _levelColors[level.clamp(0, 2)];
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
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.school_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course['title'] as String,
                  style: GoogleFonts.inter(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(_levelLabels[level.clamp(0, 2)],
                    style: GoogleFonts.inter(color: color,
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              Text(course['desc'] as String,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11, height: 1.45)),
            ],
          )),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3), size: 18),
        ]),
      ),
    );
  }
}
