// clubs_widget.dart
// Replaces lib/pages/clubs/clubs_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class ClubsWidget extends StatefulWidget {
  const ClubsWidget({super.key});
  static const String routeName = 'Clubs';
  static const String routePath = '/clubs';

  @override
  State<ClubsWidget> createState() => _ClubsWidgetState();
}

class _ClubsWidgetState extends State<ClubsWidget> {
  String _activeClub = 'Double Deuce';

  static const _myClubs = ['Double Deuce', 'Les Monston', 'Stacy Prec...'];
  static const _discover = [
    {'name': 'Wednesdary Marksmen', 'members': '312', 'tint': Color(0xFF1E2E2E)},
    {'name': 'Clay Shooting UK', 'members': '1.4k', 'tint': Color(0xFF2E1E2E)},
    {'name': 'Precision Rifle Society', 'members': '892', 'tint': Color(0xFF2E2E1E)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, theme)),
          SliverToBoxAdapter(child: _buildDiscover(context, theme)),
          SliverToBoxAdapter(child: _buildMyClubsTabs(context, theme)),
          SliverToBoxAdapter(child: _buildActiveClubCard(context, theme)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        Text('Clubs', style: GoogleFonts.interTight(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
            letterSpacing: -0.5)),
        const Spacer(),
        SXIconButton(icon: Icons.search_rounded,
            onTap: () => context.pushNamed('FindClubs')),
        const SizedBox(width: 8),
        SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': 'me'})),
      ]),
    );
  }

  Widget _buildDiscover(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      SXSectionTitle(label: 'Discover New Clubs', actionLabel: 'See All',
          onAction: () => context.pushNamed('FindClubs')),
      SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          itemCount: _discover.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final cl = _discover[i];
            return GestureDetector(
              onTap: () => context.pushNamed('ClubProfile',
                  queryParameters: {'clubId': 'club_$i'}),
              child: Container(
                width: 145,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(children: [
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: cl['tint'] as Color,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13)),
                    ),
                    child: Center(
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on_rounded,
                            color: theme.primary, size: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cl['name'] as String,
                            maxLines: 2,
                            style: GoogleFonts.inter(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w600,
                                height: 1.3)),
                        const SizedBox(height: 3),
                        Text('${cl['members']} members · Join →',
                            style: GoogleFonts.inter(color: theme.primary,
                                fontSize: 10, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildMyClubsTabs(BuildContext context, FlutterFlowTheme theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SXSectionTitle(label: 'My Clubs'),
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _myClubs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final active = _myClubs[i] == _activeClub;
            return GestureDetector(
              onTap: () => setState(() => _activeClub = _myClubs[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? theme.primary : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(_myClubs[i],
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildActiveClubCard(BuildContext context, FlutterFlowTheme theme) {
    return GestureDetector(
      onTap: () => context.pushNamed('ClubProfile',
          queryParameters: {'clubId': 'club_0'}),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(children: [
          // Club header banner
          Container(
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF172817), Color(0xFF0D1A0D)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_rounded,
                    color: theme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_activeClub,
                      style: GoogleFonts.interTight(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Firing Range · 247 members',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              )),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 20),
            ]),
          ),
          // Action grid
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                SXActionButton(label: 'Membership',
                    icon: Icons.credit_card_rounded,
                    onTap: () => context.pushNamed('MembershipCard',
                        queryParameters: {'userId': 'me'})),
                const SizedBox(width: 8),
                SXActionButton(label: 'Schedule',
                    icon: Icons.calendar_month_rounded,
                    onTap: () => context.pushNamed('EventCard')),
                const SizedBox(width: 8),
                SXActionButton(label: 'Find Range',
                    icon: Icons.location_on_rounded,
                    onTap: () => context.pushNamed('FindRange')),
                const SizedBox(width: 8),
                SXActionButton(label: 'Compete',
                    icon: Icons.emoji_events_rounded,
                    onTap: () => context.pushNamed('EventDetails',
                        queryParameters: {'eventId': 'comp_0'})),
              ]),
              const SizedBox(height: 12),
              Text(
                'Advice for tighter groupings — join the discussion with '
                'fellow members on the club feed.',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 12,
                    height: 1.5),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
