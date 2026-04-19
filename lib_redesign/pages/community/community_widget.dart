// community_widget.dart
// Replaces lib/pages/community/community_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({super.key});
  static const String routeName = 'Community';
  static const String routePath = '/community';

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  final Set<int> _liked = {};

  static const _communities = [
    {'name': 'Deer Stalking UK', 'members': '4.2k', 'tint': Color(0xFF1E2E1E)},
    {'name': 'Clay Shooting UK', 'members': '8.1k', 'tint': Color(0xFF2E1E1E)},
    {'name': 'Precision Rifle', 'members': '2.9k', 'tint': Color(0xFF1E1E2E)},
  ];

  static const _posts = [
    {
      'id': 0, 'name': 'John Wick', 'handle': '@john_wick',
      'content': "Advice for tighter groupings — been working on my stance and it's made a huge difference to consistency at 100m. Happy to share what's working.",
      'time': '2h', 'comments': 14, 'hasMedia': true,
    },
    {
      'id': 1, 'name': 'Jason Bourne', 'handle': '@jason_b',
      'content': 'First time shooting a Tikka T3x this weekend. Incredible rifle — tight groups straight out of the box.',
      'time': '4h', 'comments': 7, 'hasMedia': false,
    },
    {
      'id': 2, 'name': 'Fox Bucks', 'handle': '@foxbucks',
      'content': "Finally got my first clean score at the club last night. Couldn't be happier with the progress this month!",
      'time': '6h', 'comments': 3, 'hasMedia': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, theme)),
          SliverToBoxAdapter(child: _buildCommunities(context, theme)),
          SliverToBoxAdapter(child: _buildComposeBar(context, theme)),
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => _buildPost(ctx, theme, _posts[i]),
            childCount: _posts.length,
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(children: [
        Text('Community', style: GoogleFonts.interTight(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
            letterSpacing: -0.5)),
        const Spacer(),
        SXAvatarButton(onTap: () => context.pushNamed('UserProfile',
            queryParameters: {'userId': 'me'})),
      ]),
    );
  }

  Widget _buildCommunities(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      SXSectionTitle(label: 'Communities', actionLabel: 'See All',
          onAction: () => context.pushNamed('AllCommunities')),
      SizedBox(
        height: 158,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          itemCount: _communities.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final c = _communities[i];
            return GestureDetector(
              onTap: () => context.pushNamed('CommunityPage',
                  queryParameters: {'communityId': 'comm_$i'}),
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(children: [
                  Container(
                    height: 78,
                    decoration: BoxDecoration(
                      color: c['tint'] as Color,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13)),
                    ),
                    child: Center(
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name'] as String,
                            style: GoogleFonts.inter(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text('${c['members']} members',
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10)),
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

  Widget _buildComposeBar(BuildContext context, FlutterFlowTheme theme) {
    return GestureDetector(
      onTap: () => context.pushNamed('CreatePost'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: theme.alternate,
                  shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text('Share something with the community…',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.3), fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildPost(BuildContext context, FlutterFlowTheme theme,
      Map post) {
    final id = post['id'] as int;
    final liked = _liked.contains(id);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Author row
        GestureDetector(
          onTap: () => context.pushNamed('UserProfile',
              queryParameters: {'userId': 'user_$id'}),
          child: Row(children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: theme.alternate, shape: BoxShape.circle),
                child: Icon(Icons.person_rounded,
                    color: Colors.white.withOpacity(0.4), size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['name'] as String,
                    style: GoogleFonts.inter(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(post['handle'] as String,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            )),
            Text(post['time'] as String,
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 10),
        // Content
        GestureDetector(
          onTap: () => context.pushNamed('PostDetail',
              queryParameters: {'postId': 'post_$id'}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post['content'] as String,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 13, height: 1.55)),
              if (post['hasMedia'] == true) ...[
                const SizedBox(height: 10),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.play_circle_outline_rounded,
                          color: Colors.white.withOpacity(0.4), size: 28),
                      const SizedBox(width: 8),
                      Text('video clip',
                          style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Actions row
        Row(children: [
          _PostAction(
            icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: liked ? 'Liked' : 'Like',
            color: liked ? theme.primary : Colors.white.withOpacity(0.5),
            onTap: () => setState(() {
              liked ? _liked.remove(id) : _liked.add(id);
            }),
          ),
          const SizedBox(width: 18),
          _PostAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${post['comments']} Comments',
            color: Colors.white.withOpacity(0.5),
            onTap: () => context.pushNamed('PostDetail',
                queryParameters: {'postId': 'post_$id'}),
          ),
          const SizedBox(width: 18),
          _PostAction(
            icon: Icons.share_outlined,
            label: 'Share',
            color: Colors.white.withOpacity(0.5),
            onTap: () {},
          ),
        ]),
      ]),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(color: color, fontSize: 12)),
      ]),
    );
  }
}
