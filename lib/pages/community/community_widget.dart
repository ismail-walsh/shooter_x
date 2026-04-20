import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({super.key});
  static const String routeName = 'Community';
  static const String routePath = '/community';

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  bool _loading = true;
  List<PostsRow> _posts = [];
  final Set<String> _liked = {};
  // userId → UsersRow cache for post author names/avatars
  final Map<String, UsersRow> _userCache = {};

  // Static communities (no DB table yet)
  static const _communities = [
    {'name': 'Deer Stalking UK', 'members': '4.2k', 'tint': Color(0xFF1E2E1E)},
    {'name': 'Clay Shooting UK', 'members': '8.1k', 'tint': Color(0xFF2E1E1E)},
    {'name': 'Precision Rifle', 'members': '2.9k', 'tint': Color(0xFF1E1E2E)},
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    try {
      final posts = await databaseService.getAllPosts(limit: 30);

      // Batch-fetch authors for all posts in one query
      final otherIds = posts
          .map((p) => p.userId)
          .whereType<String>()
          .where((id) => id != currentUserUid)
          .toSet()
          .toList();
      if (otherIds.isNotEmpty) {
        final users = await UsersTable().queryRows(
          queryFn: (q) => q.inFilter('id', otherIds),
        );
        final cache = {for (final u in users) u.id: u};
        if (mounted) setState(() { _userCache.addAll(cache); });
      }

      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (_posts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No posts yet — be the first to share!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildPost(ctx, theme, _posts[i]),
                childCount: _posts.length,
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
        Text('Community',
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const Spacer(),
        SXAvatarButton(
            onTap: () => context.pushNamed('UserProfile',
                queryParameters: {'userId': currentUserUid ?? ''})),
      ]),
    );
  }

  Widget _buildCommunities(BuildContext context, FlutterFlowTheme theme) {
    return Column(children: [
      SXSectionTitle(
          label: 'Communities',
          actionLabel: 'See All',
          onAction: () {}),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.people_rounded,
                            color: theme.primary, size: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name'] as String,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
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
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: theme.alternate, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text('Share something with the community…',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.3), fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildPost(BuildContext context, FlutterFlowTheme theme, PostsRow post) {
    final isOwn = post.userId == currentUserUid;
    final liked = _liked.contains(post.id);
    final author = isOwn ? null : _userCache[post.userId];
    final displayName = isOwn
        ? 'You'
        : (author?.username ?? 'Shooter');
    final handle = isOwn
        ? '@you'
        : '@${(author?.username ?? post.userId?.substring(0, 6) ?? 'member')}';
    final avatarUrl = isOwn ? null : author?.profileImg;

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
          onTap: isOwn
              ? null
              : () => context.pushNamed('UserProfile',
                  queryParameters: {'userId': post.userId ?? ''}),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: theme.alternate, shape: BoxShape.circle),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          width: 36, height: 36,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(Icons.person_rounded,
                              color: Colors.white.withOpacity(0.4), size: 18),
                        )
                      : Icon(Icons.person_rounded,
                          color: isOwn
                              ? theme.primary
                              : Colors.white.withOpacity(0.4),
                          size: 18),
                )),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: GoogleFonts.inter(
                          color: isOwn ? theme.primary : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  Text(handle,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
            Text(_relTime(post.createdAt),
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 10),
        // Content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content ?? '',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 13,
                    height: 1.55)),
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.mediaUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.borderColor),
                    ),
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.white.withOpacity(0.3), size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Actions row
        Row(children: [
          _PostAction(
            icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: liked
                ? 'Liked'
                : (post.likes != null && post.likes! > 0
                    ? '${post.likes} Likes'
                    : 'Like'),
            color: liked ? theme.primary : Colors.white.withOpacity(0.5),
            onTap: () => setState(() {
              liked ? _liked.remove(post.id) : _liked.add(post.id);
            }),
          ),
          const SizedBox(width: 18),
          _PostAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Comment',
            color: Colors.white.withOpacity(0.5),
            onTap: () {},
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
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
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
