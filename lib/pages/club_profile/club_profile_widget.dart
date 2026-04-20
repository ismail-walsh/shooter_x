import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class ClubProfileWidget extends StatefulWidget {
  const ClubProfileWidget({super.key, this.clubId});
  final String? clubId;
  static const String routeName = 'ClubProfile';
  static const String routePath = '/clubProfile';

  @override
  State<ClubProfileWidget> createState() => _ClubProfileWidgetState();
}

class _ClubProfileWidgetState extends State<ClubProfileWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  bool _loading = true;
  ClubsRow? _club;
  List<ClubPostsRow> _clubPosts = [];
  List<EventsRow> _events = [];
  int _memberCount = 0;
  bool _isMember = false;
  bool _joiningLeaving = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final clubId = widget.clubId;
    if (clubId == null || clubId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        databaseService.getClubById(clubId),
        databaseService.getClubPosts(clubId),
        databaseService.getAllEvents(clubId: clubId),
        databaseService.isClubMember(clubId),
        ClubMembershipsTable().queryRows(
          queryFn: (q) => q.eqOrNull('club_id', clubId),
        ),
      ]);
      if (mounted) {
        setState(() {
          _club = results[0] as ClubsRow?;
          _clubPosts = results[1] as List<ClubPostsRow>;
          _events = results[2] as List<EventsRow>;
          _isMember = results[3] as bool;
          _memberCount = (results[4] as List).length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMembership() async {
    final clubId = widget.clubId;
    if (clubId == null) return;
    setState(() => _joiningLeaving = true);
    try {
      if (_isMember) {
        await databaseService.leaveClub(clubId);
        setState(() { _isMember = false; _memberCount--; });
      } else {
        await databaseService.joinClub(clubId);
        setState(() { _isMember = true; _memberCount++; });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _joiningLeaving = false);
    }
  }

  static String _relTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dow = days[dt.weekday - 1];
    return '$dow ${dt.day} ${m[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_loading) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(children: [
            SXBackHeader(title: 'Club'),
            const Expanded(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ]),
        ),
      );
    }

    if (_club == null) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(children: [
            SXBackHeader(title: 'Club'),
            Expanded(
              child: Center(
                child: Text('Club not found',
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4), fontSize: 14)),
              ),
            ),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: _club!.name),
          _buildClubHeader(context, theme),
          _buildTabBar(context, theme),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildFeedTab(context, theme),
                _buildEventsTab(context, theme),
                _buildAboutTab(context, theme),
                _buildActionsTab(context, theme),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildClubHeader(BuildContext context, FlutterFlowTheme theme) {
    final club = _club!;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        image: club.coverImg != null && club.coverImg!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(club.coverImg!), fit: BoxFit.cover)
            : null,
        gradient: club.coverImg == null
            ? LinearGradient(
                colors: [const Color(0xFF172817), theme.primaryBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: club.coverImg != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ))
            : null,
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: club.profileImg != null && club.profileImg!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: club.profileImg!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                          Icons.location_on_rounded,
                          color: theme.primary,
                          size: 26),
                    ),
                  )
                : Icon(Icons.location_on_rounded, color: theme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(club.name,
                    style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                    '$_memberCount members'
                    '${club.discipline != null ? ' · ${club.discipline}' : ''}',
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: _joiningLeaving ? null : _toggleMembership,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isMember
                          ? theme.primary.withOpacity(0.15)
                          : theme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                        _joiningLeaving
                            ? '…'
                            : (_isMember ? 'MEMBER' : 'JOIN'),
                        style: GoogleFonts.inter(
                            color: theme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: theme.borderColor))),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: theme.primary,
        indicatorWeight: 2,
        labelColor: theme.primary,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        tabs: const [
          Tab(text: 'Feed'),
          Tab(text: 'Events'),
          Tab(text: 'About'),
          Tab(text: 'Actions'),
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context, FlutterFlowTheme theme) {
    if (_clubPosts.isEmpty) {
      return Center(
        child: Text('No posts yet.',
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4), fontSize: 13)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _clubPosts.map((p) {
        final isOwn = p.createdBy == currentUserUid;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: theme.alternate, shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded,
                      color: isOwn
                          ? theme.primary
                          : Colors.white.withOpacity(0.4),
                      size: 15)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isOwn ? 'You' : 'Club Member',
                    style: GoogleFonts.inter(
                        color: isOwn ? theme.primary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(_relTime(p.createdAt),
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 10)),
              ]),
            ]),
            const SizedBox(height: 8),
            Text(p.content,
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.5)),
            if (p.mediaUrl != null && p.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(p.mediaUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ],
          ]),
        );
      }).toList(),
    );
  }

  Widget _buildEventsTab(BuildContext context, FlutterFlowTheme theme) {
    if (_events.isEmpty) {
      return Center(
        child: Text('No events scheduled.',
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4), fontSize: 13)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _events.map((ev) {
        return GestureDetector(
          onTap: () => context.pushNamed('EventDetails',
              queryParameters: {'eventId': ev.id}),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.borderColor),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ev.name,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(_fmtDate(ev.date),
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11)),
                  ],
                ),
              ),
              if (ev.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(ev.status!.toUpperCase(),
                      style: GoogleFonts.inter(
                          color: theme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 18),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutTab(BuildContext context, FlutterFlowTheme theme) {
    final club = _club!;
    final rows = <List<String>>[
      if (club.location != null) ['Location', club.location!],
      if (club.discipline != null) ['Discipline', club.discipline!],
      ['Membership', club.isPrivate == true ? 'Invite Only' : 'Open'],
      if (club.websiteUrl != null) ['Website', club.websiteUrl!],
      if (club.createdAt != null) [
        'Founded',
        club.createdAt!.year.toString()
      ],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (club.description != null && club.description!.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: theme.borderColor),
            ),
            child: Text(club.description!,
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.55)),
          ),
        ],
        if (rows.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: theme.borderColor),
            ),
            child: Column(
              children: rows.asMap().entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    border: e.key < rows.length - 1
                        ? Border(
                            bottom: BorderSide(color: theme.borderColor))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.value[0],
                          style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13)),
                      Flexible(
                        child: Text(e.value[1],
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildActionsTab(BuildContext context, FlutterFlowTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          SXActionButton(
              label: 'Membership',
              icon: Icons.credit_card_rounded,
              onTap: () => context.pushNamed('MembershipCard',
                  queryParameters: {'userId': currentUserUid ?? ''})),
          const SizedBox(width: 8),
          SXActionButton(
              label: 'Schedule',
              icon: Icons.calendar_month_rounded,
              onTap: () => context.pushNamed('EventCard')),
          const SizedBox(width: 8),
          SXActionButton(
              label: 'Find Range',
              icon: Icons.location_on_rounded,
              onTap: () => context.pushNamed('FindRange')),
          const SizedBox(width: 8),
          SXActionButton(
              label: 'Compete',
              icon: Icons.emoji_events_rounded,
              onTap: () => context.pushNamed('EventCard')),
        ]),
      ],
    );
  }
}
