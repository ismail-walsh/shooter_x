import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import '/utils/sx_ranks.dart';

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key, this.clubId});
  final String? clubId;
  static const String routeName = 'Leaderboard';
  static const String routePath = '/leaderboard';

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  String _filter = 'Overall';
  static const _filters = ['Overall', 'Monthly', 'Club', 'Friends'];
  static const _scopeMap = {
    'Overall': 'overall',
    'Monthly': 'monthly',
    'Club': 'club',
    'Friends': 'friends',
  };

  bool _loading = true;
  List<LeaderboardEntriesRow> _entries = [];

  @override
  void initState() {
    super.initState();
    if (widget.clubId != null) _filter = 'Club';
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    try {
      final scope = _scopeMap[_filter] ?? 'overall';
      final entries = await databaseService.getLeaderboardByScope(
          scope, clubId: widget.clubId);
      if (mounted) setState(() { _entries = entries; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _fmtXp(int? xp) {
    if (xp == null) return '0 XP';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k XP';
    return '$xp XP';
  }

  static ({Color color, String label}) _podiumMeta(int podiumIndex) {
    // podiumIndex: 0=2nd, 1=1st, 2=3rd
    const metas = [
      (color: Color(0xFFC0C0C0), label: '2ND'),
      (color: Color(0xFFFFD700), label: '1ST'),
      (color: Color(0xFFCD7F32), label: '3RD'),
    ];
    return metas[podiumIndex];
  }

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
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else if (_entries.length >= 3) ...[
              SliverToBoxAdapter(child: _buildPodium(context, theme)),
              SliverToBoxAdapter(child: _buildList(context, theme)),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No entries yet for this category.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.4), fontSize: 14)),
                ),
              ),
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
            onTap: () {
              if (_filters[i] != _filter) {
                setState(() => _filter = _filters[i]);
                _loadLeaderboard();
              }
            },
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
    // Display order: 2nd place (left), 1st place (centre), 3rd place (right)
    final podiumOrder = [_entries[1], _entries[0], _entries[2]];
    final heights = [100.0, 130.0, 85.0];
    final labels = ['2nd', '1st', '3rd'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (pi) {
          final entry = podiumOrder[pi];
          final isMe = entry.userId == currentUserUid;
          return Expanded(
            child: GestureDetector(
              onTap: isMe
                  ? null
                  : () => context.pushNamed('UserProfile',
                      queryParameters: {
                        'userId': entry.userId ?? '',
                        'displayName': entry.displayName ?? '',
                      }),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    child: ClipOval(
                      child: entry.profileImg != null &&
                              entry.profileImg!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: entry.profileImg!,
                              width: 44, height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(
                                  Icons.person_rounded,
                                  color: isMe
                                      ? theme.primary
                                      : Colors.white.withOpacity(0.5),
                                  size: 22),
                            )
                          : Icon(Icons.person_rounded,
                              color: isMe
                                  ? theme.primary
                                  : Colors.white.withOpacity(0.5),
                              size: 22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Builder(builder: (_) {
                    final meta = _podiumMeta(pi);
                    return Icon(Icons.military_tech_rounded,
                        color: meta.color, size: 22);
                  }),
                  const SizedBox(height: 4),
                  Text((entry.displayName ?? '—').split(' ').first,
                      style: GoogleFonts.inter(
                          color: isMe ? theme.primary : Colors.white,
                          fontSize: 10, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Builder(builder: (_) {
                    final rank = getRank(entry.level ?? 0);
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(rank.icon, color: rank.color, size: 9),
                      const SizedBox(width: 2),
                      Text('Lvl ${entry.level ?? 0}',
                          style: GoogleFonts.inter(
                              color: rank.color,
                              fontSize: 8, fontWeight: FontWeight.w600)),
                    ]);
                  }),
                  const SizedBox(height: 6),
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
    if (rest.isEmpty) return const SizedBox.shrink();
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
          final isMe = r.userId == currentUserUid;
          return GestureDetector(
            onTap: isMe
                ? null
                : () => context.pushNamed('UserProfile',
                    queryParameters: {
                      'userId': r.userId ?? '',
                      'displayName': r.displayName ?? '',
                    }),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.primary.withOpacity(0.05)
                    : Colors.transparent,
                border: i < rest.length - 1
                    ? Border(bottom: BorderSide(color: theme.borderColor))
                    : null,
                borderRadius: i == rest.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(13))
                    : null,
              ),
              child: Row(children: [
                SizedBox(
                  width: 24,
                  child: Text('${r.rank ?? (i + 4)}',
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
                  child: ClipOval(
                    child: r.profileImg != null && r.profileImg!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: r.profileImg!,
                            width: 28, height: 28,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.person_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 14),
                          )
                        : Icon(Icons.person_rounded,
                            color: Colors.white.withOpacity(0.4), size: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        isMe
                            ? '${r.displayName ?? 'You'} (you)'
                            : (r.displayName ?? '—'),
                        style: GoogleFonts.inter(
                            color: isMe ? theme.primary : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Builder(builder: (_) {
                      final rank = getRank(r.level ?? 0);
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(rank.icon, color: rank.color, size: 10),
                        const SizedBox(width: 3),
                        Text('${rank.label} · Lvl ${r.level ?? 0}',
                            style: GoogleFonts.inter(
                                color: rank.color,
                                fontSize: 9, fontWeight: FontWeight.w500)),
                      ]);
                    }),
                  ],
                )),
                Text(_fmtXp(r.xp),
                    style: GoogleFonts.inter(
                        color: theme.primary,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 36,
                  child: Text('${(r.score ?? 0).toStringAsFixed(0)}%',
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
