import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class ClubsWidget extends StatefulWidget {
  const ClubsWidget({super.key});
  static const String routeName = 'Clubs';
  static const String routePath = '/clubs';

  @override
  State<ClubsWidget> createState() => _ClubsWidgetState();
}

class _ClubsWidgetState extends State<ClubsWidget> {
  bool _loading = true;
  List<ClubsRow> _myClubs = [];
  List<ClubsRow> _discover = [];
  String? _activeClubId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        databaseService.getUserClubs(),
        databaseService.getAllClubs(),
      ]);
      final myClubs = results[0] as List<ClubsRow>;
      final allClubs = results[1] as List<ClubsRow>;
      final myClubIds = myClubs.map((c) => c.id).toSet();
      final discover = allClubs.where((c) => !myClubIds.contains(c.id)).toList();
      if (mounted) {
        setState(() {
          _myClubs = myClubs;
          _discover = discover;
          _activeClubId = myClubs.isNotEmpty ? myClubs.first.id : null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  ClubsRow? get _activeClub =>
      _myClubs.where((c) => c.id == _activeClubId).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, theme)),
          SliverToBoxAdapter(child: _buildDiscover(context, theme)),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (_myClubs.isEmpty)
            SliverToBoxAdapter(child: _buildNoClubs(context, theme))
          else ...[
            SliverToBoxAdapter(child: _buildMyClubsTabs(context, theme)),
            SliverToBoxAdapter(child: _buildActiveClubCard(context, theme)),
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
        Text('Clubs',
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const Spacer(),
        SXIconButton(
            icon: Icons.search_rounded,
            onTap: () => context.pushNamed('FindClubs')),
        const SizedBox(width: 8),
        SXAvatarButton(
            onTap: () => context.pushNamed('UserProfile',
                queryParameters: {'userId': currentUserUid ?? ''})),
      ]),
    );
  }

  Widget _buildDiscover(BuildContext context, FlutterFlowTheme theme) {
    if (_loading) {
      return const SizedBox(
        height: 188,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_discover.isEmpty) return const SizedBox.shrink();

    const tints = [
      Color(0xFF1E2E2E), Color(0xFF2E1E2E), Color(0xFF2E2E1E),
      Color(0xFF1E2A2E), Color(0xFF2E1E28), Color(0xFF281E2E),
    ];

    return Column(children: [
      SXSectionTitle(
          label: 'Discover New Clubs',
          actionLabel: 'See All',
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
                  queryParameters: {'clubId': cl.id}),
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
                      color: tints[i % tints.length],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                    child: cl.profileImg != null && cl.profileImg!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(13)),
                            child: CachedNetworkImage(
                              imageUrl: cl.profileImg!,
                              width: 145,
                              height: 72,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _clubIconPlaceholder(theme),
                            ),
                          )
                        : _clubIconPlaceholder(theme),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cl.name,
                            maxLines: 2,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.3)),
                        const SizedBox(height: 3),
                        Text(
                            cl.discipline != null
                                ? '${cl.discipline} · Join →'
                                : 'Join →',
                            style: GoogleFonts.inter(
                                color: theme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
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

  Widget _clubIconPlaceholder(FlutterFlowTheme theme) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.location_on_rounded, color: theme.primary, size: 18),
      ),
    );
  }

  Widget _buildNoClubs(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        const SXSectionTitle(label: 'My Clubs'),
        Text("You haven't joined any clubs yet.",
            style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.4), fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.pushNamed('FindClubs'),
          child: Text('Find clubs →',
              style: GoogleFonts.inter(
                  color: theme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
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
            final active = _myClubs[i].id == _activeClubId;
            return GestureDetector(
              onTap: () => setState(() => _activeClubId = _myClubs[i].id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? theme.primary : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                    _myClubs[i].name.length > 14
                        ? '${_myClubs[i].name.substring(0, 13)}…'
                        : _myClubs[i].name,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildActiveClubCard(BuildContext context, FlutterFlowTheme theme) {
    final club = _activeClub;
    if (club == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.pushNamed('ClubProfile',
          queryParameters: {'clubId': club.id}),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: club.profileImg != null && club.profileImg!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: club.profileImg!,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(
                              Icons.location_on_rounded,
                              color: theme.primary,
                              size: 24),
                        ),
                      )
                    : Icon(Icons.location_on_rounded,
                        color: theme.primary, size: 24),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                        [
                          if (club.discipline != null) club.discipline!,
                          if (club.location != null) club.location!,
                        ].join(' · '),
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 20),
            ]),
          ),
          // Action grid
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                SXActionButton(
                    label: 'Membership',
                    icon: Icons.credit_card_rounded,
                    onTap: () => context.pushNamed('MembershipCard',
                        queryParameters: {
                          'userId': currentUserUid ?? ''
                        })),
                const SizedBox(width: 8),
                SXActionButton(
                    label: 'Schedule',
                    icon: Icons.calendar_month_rounded,
                    onTap: () => context.pushNamed('EventCard',
                        queryParameters: {'clubId': club.id})),
                const SizedBox(width: 8),
                SXActionButton(
                    label: 'Find Range',
                    icon: Icons.location_on_rounded,
                    onTap: () => context.pushNamed('FindRange')),
                const SizedBox(width: 8),
                SXActionButton(
                    label: 'Compete',
                    icon: Icons.emoji_events_rounded,
                    onTap: () => context.pushNamed('EventCard',
                        queryParameters: {'clubId': club.id})),
              ]),
              if (club.description != null && club.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  club.description!,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.5),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
