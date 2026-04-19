// leaderboard_widget.dart  — NEW SCREEN
// Add to lib/pages/leaderboard/leaderboard_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});
  static const String routeName = 'Leaderboard';
  static const String routePath = '/leaderboard';

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  String _filter = 'Overall';
  static const _filters = ['Overall', 'Monthly', 'Club', 'Friends'];

  static const _entries = [
    {'rank': 1, 'name': 'Mike Thornton', 'score': '98%', 'xp': '24,500', 'badge': '🥇', 'isMe': false},
    {'rank': 2, 'name': 'Sarah Daley', 'score': '97%', 'xp': '22,100', 'badge': '🥈', 'isMe': false},
    {'rank': 3, 'name': 'Alex Reid', 'score': '95%', 'xp': '19,800', 'badge': '🥉', 'isMe': false},
    {'rank': 4, 'name': 'Tom Walsh', 'score': '94%', 'xp': '17,200', 'badge': '', 'isMe': false},
    {'rank': 5, 'name': 'Rachel Fox', 'score': '93%', 'xp': '15,600', 'badge': '', 'isMe': false},
    {'rank': 6, 'name': 'Dan Hughes', 'score': '92%', 'xp': '14,400', 'badge': '', 'isMe': false},
    {'rank': 7, 'name': 'Nina Patel', 'score': '91%', 'xp': '13,200', 'badge': '', 'isMe': false},
    {'rank': 8, 'name': 'Chris Bell', 'score': '90%', 'xp': '12,800', 'badge': '', 'isMe': false},
    {'rank': 9, 'name': 'You', 'score': '91%', 'xp': '12,400', 'badge': '', 'isMe': true},
    {'rank': 10, 'name': 'Jo Marsh', 'score': '89%', 'xp': '11,900', 'badge': '', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Leaderboard'),
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildFilters(context, theme)),
            SliverToBoxAdapter(child: _buildPodium(context, theme)),
            SliverToBoxAdapter(child: _buildList(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, FlutterFlowTheme theme) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final active = _filters[i] == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = _filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? theme.primary : theme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(_filters[i],
                  style: GoogleFonts.inter(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodium(BuildContext context, FlutterFlowTheme theme) {
    // Display order: 2nd, 1st, 3rd
    final podium = [_entries[1], _entries[0], _entries[2]];
    final heights = [100.0, 130.0, 85.0];
    final labels = ['2nd', '1st', '3rd'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (pi) {
          final entry = podium[pi];
          return Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed('UserProfile',
                  queryParameters: {'userId': 'user_${pi + 1}'}),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: pi == 1 ? theme.primary : theme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(Icons.person_rounded,
                        color: Colors.white.withOpacity(0.5), size: 22),
                  ),
                  const SizedBox(height: 6),
                  // Badge
                  if ((entry['badge'] as String).isNotEmpty)
                    Text(entry['badge'] as String,
                        style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text((entry['name'] as String).split(' ')[0],
                      style: GoogleFonts.inter(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  // Podium bar
                  Container(
                    height: heights[pi],
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.primary.withOpacity(0.2),
                          theme.primary.withOpacity(0.04),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8)),
                      border: Border.all(
                          color: theme.primary.withOpacity(0.15)),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(labels[pi],
                        style: GoogleFonts.interTight(
                            color: theme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList(BuildContext context, FlutterFlowTheme theme) {
    final rest = _entries.skip(3).toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        children: rest.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final isMe = r['isMe'] as bool;
          return GestureDetector(
            onTap: isMe
                ? null
                : () => context.pushNamed('UserProfile',
                    queryParameters: {'userId': 'user_${r['rank']}'}),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.primary.withOpacity(0.05)
                    : Colors.transparent,
                border: i < rest.length - 1
                    ? Border(
                        bottom: BorderSide(color: theme.borderColor))
                    : null,
                borderRadius: i == rest.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(13))
                    : null,
              ),
              child: Row(children: [
                SizedBox(
                  width: 24,
                  child: Text('${r['rank']}',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                      color: theme.alternate, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                    isMe ? '${r['name']} (you)' : r['name'] as String,
                    style: GoogleFonts.inter(
                        color: isMe ? theme.primary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600))),
                Text('${r['xp']} XP',
                    style: GoogleFonts.inter(
                        color: theme.primary,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 36,
                  child: Text(r['score'] as String,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11),
                      textAlign: TextAlign.right),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
