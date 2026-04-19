// club_profile_widget.dart
// Replaces lib/pages/club_profile/club_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  static const _feedPosts = [
    {'author': 'Club Admin', 'msg': 'Range day this Saturday — booking is open. Max 20 slots.', 'time': '1h'},
    {'author': 'Mike T.', 'msg': 'Great session yesterday, thanks to everyone who joined.', 'time': '3h'},
    {'author': 'Sarah D.', 'msg': 'New targets just arrived for the precision bay.', 'time': '1d'},
  ];
  static const _events = [
    {'name': 'Monthly Medal Round', 'date': 'Sat 7 Jun', 'spots': 12},
    {'name': 'Steel Challenge Night', 'date': 'Thu 12 Jun', 'spots': 6},
    {'name': 'Junior Shoot Day', 'date': 'Sun 22 Jun', 'spots': 18},
  ];
  static const _members = [
    {'name': 'Mike Thornton', 'role': 'Range Officer'},
    {'name': 'Sarah Daley', 'role': 'Member'},
    {'name': 'Alex Reid', 'role': 'Committee'},
    {'name': 'Tom Walsh', 'role': 'Member'},
    {'name': 'Rachel Fox', 'role': 'Member'},
  ];
  static const _about = [
    ['Founded', '2004'],
    ['Location', 'Luton, Bedfordshire'],
    ['Disciplines', 'Rifle · Pistol · Steel'],
    ['Membership', 'Open'],
    ['Website', 'doubledeuce.co.uk'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Double Deuce'),
          _buildClubHeader(context, theme),
          _buildTabBar(context, theme),
          Expanded(child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildFeedTab(context, theme),
              _buildEventsTab(context, theme),
              _buildMembersTab(context, theme),
              _buildAboutTab(context, theme),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildClubHeader(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF172817), theme.primaryBackground],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.location_on_rounded, color: theme.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Double Deuce',
                style: GoogleFonts.interTight(color: Colors.white,
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('247 members · Firing Range',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text('MEMBER',
                  style: GoogleFonts.inter(color: theme.primary,
                      fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        )),
      ]),
    );
  }

  Widget _buildTabBar(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.borderColor)),
      ),
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
          Tab(text: 'Members'),
          Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildFeedTab(BuildContext context, FlutterFlowTheme theme) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._feedPosts.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 30, height: 30,
                decoration: BoxDecoration(
                    color: theme.alternate, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['author']!, style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(p['time']!, style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5), fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 8),
          Text(p['msg']!, style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5)),
        ]),
      )),
    ]);
  }

  Widget _buildEventsTab(BuildContext context, FlutterFlowTheme theme) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._events.map((ev) => GestureDetector(
        onTap: () => context.pushNamed('EventDetails',
            queryParameters: {'eventId': 'event_0'}),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev['name'] as String,
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(ev['date'] as String,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            )),
            Text('${ev['spots']} spots',
                style: GoogleFonts.inter(color: theme.primary,
                    fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildMembersTab(BuildContext context, FlutterFlowTheme theme) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._members.map((m) => GestureDetector(
        onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': 'member_0'}),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          child: Row(children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: theme.alternate, shape: BoxShape.circle),
                child: Icon(Icons.person_rounded,
                    color: Colors.white.withOpacity(0.4), size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name']!, style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
                Text(m['role']!, style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            )),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildAboutTab(BuildContext context, FlutterFlowTheme theme) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          children: _about.asMap().entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: e.key < _about.length - 1
                  ? Border(bottom: BorderSide(color: theme.borderColor))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.value[0], style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 13)),
                Text(e.value[1], style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500)),
              ],
            ),
          )).toList(),
        ),
      ),
    ]);
  }
}
