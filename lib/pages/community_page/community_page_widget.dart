import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import 'community_page_model.dart';
export 'community_page_model.dart';

class CommunityPageWidget extends StatefulWidget {
  const CommunityPageWidget({super.key, this.communityId});
  final String? communityId;

  static const String routeName = 'CommunityPage';
  static const String routePath = '/communityPage';

  @override
  State<CommunityPageWidget> createState() => _CommunityPageWidgetState();
}

// Static community metadata (no DB table yet)
const _communityData = [
  _CommunityMeta(
    name: 'Deer Stalking UK',
    members: '4.2k',
    description:
        'The home for deer stalkers across the UK. Share your experiences, ask for advice on equipment, discuss DSC qualifications and connect with fellow stalkers. All deer species and methods welcome — respectful, responsible stalking only.',
    coverUrl:
        'https://images.unsplash.com/photo-1516253593875-bd7ba052fbc5?w=900&auto=format&fit=crop&q=60',
    tint: Color(0xFF1E2E1E),
  ),
  _CommunityMeta(
    name: 'Clay Shooting UK',
    members: '8.1k',
    description:
        'The largest online community for clay shooters in the UK. From beginners learning the basics of English Sporting to CPSA-qualified coaches — tips on technique, equipment reviews, competition results and ground recommendations all welcome.',
    coverUrl:
        'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=900&auto=format&fit=crop&q=60',
    tint: Color(0xFF2E1E1E),
  ),
  _CommunityMeta(
    name: 'Precision Rifle',
    members: '2.9k',
    description:
        'For those obsessed with accuracy. Long-range ballistics, reloading data, PRS competition prep, scope reviews and load development discussion. Home to everyone from F-Class competitors to Highland stalkers seeking sub-MOA consistency.',
    coverUrl:
        'https://images.unsplash.com/photo-1608096299210-db7e38487075?w=900&auto=format&fit=crop&q=60',
    tint: Color(0xFF1E1E2E),
  ),
];

class _CommunityMeta {
  const _CommunityMeta({
    required this.name,
    required this.members,
    required this.description,
    required this.coverUrl,
    required this.tint,
  });
  final String name;
  final String members;
  final String description;
  final String coverUrl;
  final Color tint;
}

class _CommunityPageWidgetState extends State<CommunityPageWidget> {
  bool _loading = true;
  List<PostsRow> _posts = [];
  final Set<String> _liked = {};
  final Map<String, UsersRow> _userCache = {};

  _CommunityMeta get _meta {
    final id = widget.communityId ?? '';
    final idx = int.tryParse(id.replaceFirst('comm_', '')) ?? 0;
    if (idx >= 0 && idx < _communityData.length) return _communityData[idx];
    return _communityData[0];
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await databaseService.getAllPosts(limit: 20);

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
        if (mounted) setState(() => _userCache.addAll(cache));
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
    final meta = _meta;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: CustomScrollView(slivers: [
              // ── Hero header ─────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context, theme, meta)),
              // ── Posts ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('Posts',
                      style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                )
              else if (_posts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                        'No posts yet — be the first to share something!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildPost(ctx, theme, _posts[i]),
                    childCount: _posts.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ]),
          ),
          // ── Sticky write-a-post bar ──────────────────────────
          _buildPostBar(context, theme),
        ]),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, FlutterFlowTheme theme, _CommunityMeta meta) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Cover image with back button
      Stack(children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: meta.tint,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: meta.coverUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: meta.tint),
            ),
          ),
        ),
        // Dark scrim for readability
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        // Back button
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
        // Notification and options
        Positioned(
          top: 12,
          right: 12,
          child: Row(children: [
            _HeaderAction(icon: Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            _HeaderAction(icon: Icons.more_horiz_rounded),
          ]),
        ),
      ]),
      // Community name & stats
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meta.name,
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
          const SizedBox(height: 3),
          Text('${meta.members} members',
              style: GoogleFonts.inter(
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(meta.description,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.5)),
          const SizedBox(height: 12),
          Divider(color: FlutterFlowTheme.of(context).borderColor, height: 1),
        ]),
      ),
    ]);
  }

  Widget _buildPost(BuildContext context, FlutterFlowTheme theme, PostsRow post) {
    final isOwn = post.userId == currentUserUid;
    final liked = _liked.contains(post.id);
    final author = isOwn ? null : _userCache[post.userId];
    final displayName = isOwn ? 'You' : (author?.username ?? 'Shooter');
    final handle = isOwn
        ? '@you'
        : '@${(author?.username ?? post.userId?.substring(0, 6) ?? 'member')}';
    final avatarUrl = isOwn ? null : author?.profileImg;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration:
                  BoxDecoration(color: theme.alternate, shape: BoxShape.circle),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        width: 36, height: 36, fit: BoxFit.cover,
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(displayName,
                  style: GoogleFonts.inter(
                      color: isOwn ? theme.primary : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text(handle,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ]),
          ),
          Text(_relTime(post.createdAt),
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ]),
        const SizedBox(height: 10),
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
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          _PostAction(
            icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: liked
                ? 'Liked'
                : (post.likes != null && post.likes! > 0
                    ? '${post.likes}'
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

  Widget _buildPostBar(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: GestureDetector(
        onTap: () async {
          await context.pushNamed('CreatePost');
          // Reload posts after returning
          _loadPosts();
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Write a Post',
                style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
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
