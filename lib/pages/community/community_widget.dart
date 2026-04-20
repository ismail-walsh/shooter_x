import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';
import '/utils/sx_discipline_theme.dart';

// ─── Community metadata ───────────────────────────────────────────────────────

class _Community {
  const _Community({
    required this.id,
    required this.name,
    required this.pill,     // pill label used in the filter
    required this.members,
    required this.discipline,
    required this.coverUrl,
  });
  final String id;          // comm_0, comm_1 etc — matches CommunityPageWidget
  final String name;
  final String pill;
  final String members;
  final String discipline;
  final String coverUrl;
}

const _kCommunities = [
  _Community(
    id: 'comm_0',
    name: 'Deer Stalking UK',
    pill: 'Deer Stalking',
    members: '4.2k',
    discipline: 'deer',
    coverUrl:
        'https://images.unsplash.com/photo-1516253593875-bd7ba052fbc5?w=900&auto=format&fit=crop&q=60',
  ),
  _Community(
    id: 'comm_1',
    name: 'Clay Shooting UK',
    pill: 'Clay Shooting',
    members: '8.1k',
    discipline: 'clay',
    coverUrl:
        'https://images.unsplash.com/photo-1595590424283-b8f17842773f?w=900&auto=format&fit=crop&q=60',
  ),
  _Community(
    id: 'comm_2',
    name: 'Precision Rifle',
    pill: 'Precision Rifle',
    members: '2.9k',
    discipline: 'precision',
    coverUrl:
        'https://images.unsplash.com/photo-1608096299210-db7e38487075?w=900&auto=format&fit=crop&q=60',
  ),
  _Community(
    id: 'comm_3',
    name: 'Target Shooting',
    pill: 'Target Shooting',
    members: '5.3k',
    discipline: 'precision',
    coverUrl:
        'https://images.unsplash.com/photo-1608096299210-db7e38487075?w=900&auto=format&fit=crop&q=60',
  ),
];

const _kPills = ['All', 'Deer Stalking', 'Clay Shooting', 'Precision Rifle', 'Target Shooting'];

// ── Assigns a stable community to a post by hashing post.id ──────────────────
_Community _communityForPost(PostsRow post) {
  final hash = post.id.codeUnits.fold(0, (prev, e) => prev + e);
  return _kCommunities[hash % _kCommunities.length];
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({super.key});
  static const String routeName = 'Community';
  static const String routePath = '/community';

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  String _activePill = 'All';
  final Set<String> _liked = {};     // post IDs liked this session
  bool _likeSyncing = false;

  bool _loading = true;
  List<PostsRow> _posts = [];
  UsersRow? _me;
  final Map<String, UsersRow> _userCache = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Data load ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final uid = currentUserUid;
    try {
    final results = await Future.wait([
      databaseService.getCurrentUserProfile().catchError((_) => null),
      databaseService.getAllPosts(limit: 40).catchError((_) => <PostsRow>[]),
    ]).timeout(const Duration(seconds: 12),
        onTimeout: () => [null, <PostsRow>[]]);

    if (!mounted) return;

    final posts = results[1] as List<PostsRow>;

    // Batch-fetch authors
    final otherIds = posts
        .map((p) => p.userId)
        .whereType<String>()
        .where((id) => id != uid)
        .toSet()
        .toList();
    Map<String, UsersRow> cache = {};
    if (otherIds.isNotEmpty) {
      final users = await UsersTable()
          .queryRows(queryFn: (q) => q.inFilter('id', otherIds))
          .catchError((_) => <UsersRow>[]);
      cache = {for (final u in users) u.id: u};
    }

    // Fetch liked post IDs for current user
    Set<String> liked = {};
    try {
      final rows = await SupaFlow.client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', uid);
      if (rows is List) {
        liked = {
          for (final r in rows)
            if (r['post_id'] != null) r['post_id'] as String
        };
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _me = results[0] as UsersRow?;
      _posts = posts;
      _userCache.addAll(cache);
      _liked.addAll(liked);
      _loading = false;
    });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Like toggle ───────────────────────────────────────────────────────────

  Future<void> _toggleLike(PostsRow post) async {
    final postId = post.id;
    final wasLiked = _liked.contains(postId);

    // Optimistic UI
    setState(() {
      wasLiked ? _liked.remove(postId) : _liked.add(postId);
    });

    try {
      if (wasLiked) {
        await SupaFlow.client
            .from('post_likes')
            .delete()
            .eq('user_id', currentUserUid)
            .eq('post_id', postId);
        // Decrement counter
        final current = post.likes ?? 0;
        if (current > 0) {
          await PostsTable().update(
            data: {'likes': current - 1},
            matchingRows: (q) => q.eq('id', postId),
          );
        }
      } else {
        await SupaFlow.client.from('post_likes').upsert({
          'user_id': currentUserUid,
          'post_id': postId,
        });
        await databaseService.likePost(postId);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          wasLiked ? _liked.add(postId) : _liked.remove(postId);
        });
      }
    }
  }

  // ── Filtered posts ────────────────────────────────────────────────────────

  List<PostsRow> get _filteredPosts {
    if (_activePill == 'All') return _posts;
    return _posts
        .where((p) => _communityForPost(p).pill == _activePill)
        .toList();
  }

  _Community? get _activeCommunity {
    if (_activePill == 'All') return null;
    try {
      return _kCommunities.firstWhere((c) => c.pill == _activePill);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _relTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, theme)),
            SliverToBoxAdapter(child: _buildPills(context, theme)),
            if (_activeCommunity != null)
              SliverToBoxAdapter(
                  child: _buildActiveCommunityCard(context, theme)),
            if (_activePill == 'All')
              SliverToBoxAdapter(
                  child: _buildSuggestedCommunities(context, theme)),
            SliverToBoxAdapter(child: _buildComposeBar(context, theme)),
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              )
            else if (_filteredPosts.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyFeed(context, theme))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildPostCard(ctx, theme, _filteredPosts[i]),
                  childCount: _filteredPosts.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'Community',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pushNamed('UserProfile',
                queryParameters: {'userId': currentUserUid}),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor),
              ),
              child: ClipOval(
                child: _me?.profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: _me!.profileImg!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _avatarIcon(),
                      )
                    : _avatarIcon(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarIcon() => Icon(Icons.person_rounded,
      color: Colors.white.withOpacity(0.45), size: 17);

  // ── Filter pills ──────────────────────────────────────────────────────────

  Widget _buildPills(BuildContext context, FlutterFlowTheme theme) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _kPills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final pill = _kPills[i];
          final active = pill == _activePill;
          return GestureDetector(
            onTap: () => setState(() => _activePill = pill),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? theme.primary : theme.secondaryBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? theme.primary : theme.borderColor,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                pill,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Active community card ─────────────────────────────────────────────────

  Widget _buildActiveCommunityCard(
      BuildContext context, FlutterFlowTheme theme) {
    final comm = _activeCommunity!;
    final dt = getDisciplineTheme(comm.discipline);

    return GestureDetector(
      onTap: () => context.pushNamed('CommunityPage',
          queryParameters: {'communityId': comm.id}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: dt.grad,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(dt.icon, color: dt.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comm.name,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${comm.members} members',
                    style: GoogleFonts.inter(
                      color: theme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Tap to view',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Suggested communities ─────────────────────────────────────────────────

  Widget _buildSuggestedCommunities(
      BuildContext context, FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SXSectionTitle(
            label: 'Suggested Communities',
            actionLabel: 'See All',
            onAction: () => context.pushNamed('FindClubs'),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: _kCommunities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final comm = _kCommunities[i];
              final dt = getDisciplineTheme(comm.discipline);
              return GestureDetector(
                onTap: () => context.pushNamed('CommunityPage',
                    queryParameters: {'communityId': comm.id}),
                child: Container(
                  width: 148,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: dt.grad,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                        child: Center(
                            child: Icon(dt.icon, color: dt.accent, size: 28)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comm.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${comm.members} members',
                              style: GoogleFonts.inter(
                                  color: theme.primary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Compose bar ───────────────────────────────────────────────────────────

  Widget _buildComposeBar(BuildContext context, FlutterFlowTheme theme) {
    final suffix = _activePill != 'All' ? ' in $_activePill' : '';
    final placeholder = 'Share something$suffix…';

    return GestureDetector(
      onTap: () async {
        await context.pushNamed('CreatePost');
        _load();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _me?.profileImg?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: _me!.profileImg!,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 14,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 14,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                placeholder,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.edit_outlined,
                color: Colors.white.withOpacity(0.25), size: 16),
          ],
        ),
      ),
    );
  }

  // ── Empty feed ────────────────────────────────────────────────────────────

  Widget _buildEmptyFeed(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Text(
        _activePill == 'All'
            ? 'No posts yet — be the first to share!'
            : 'No posts in $_activePill yet.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.35),
          fontSize: 13,
        ),
      ),
    );
  }

  // ── Post card ─────────────────────────────────────────────────────────────

  Widget _buildPostCard(
      BuildContext context, FlutterFlowTheme theme, PostsRow post) {
    final isOwn = post.userId == currentUserUid;
    final author = isOwn ? null : _userCache[post.userId];
    final displayName =
        isOwn ? 'You' : (author?.username ?? 'Shooter');
    final handle = isOwn
        ? '@you'
        : '@${author?.username ?? post.userId?.substring(0, 6) ?? 'member'}';
    final avatarUrl = isOwn ? _me?.profileImg : author?.profileImg;
    final liked = _liked.contains(post.id);
    final comm = _communityForPost(post);
    final dt = getDisciplineTheme(comm.discipline);
    final likeCount =
        liked ? (post.likes ?? 0) + 1 : (post.likes ?? 0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Community pill (All mode only)
          if (_activePill == 'All') ...[
            GestureDetector(
              onTap: () => setState(() => _activePill = comm.pill),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: dt.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(dt.icon, color: dt.accent, size: 11),
                    const SizedBox(width: 5),
                    Text(
                      comm.name,
                      style: GoogleFonts.inter(
                        color: dt.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Author row
          Row(
            children: [
              GestureDetector(
                onTap: post.userId == null
                    ? null
                    : () => context.pushNamed('UserProfile',
                          queryParameters: {'userId': post.userId!}),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: avatarUrl?.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            width: 34,
                            height: 34,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _postAvatarIcon(
                                isOwn, theme),
                          )
                        : _postAvatarIcon(isOwn, theme),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: post.userId == null
                      ? null
                      : () => context.pushNamed('UserProfile',
                            queryParameters: {'userId': post.userId!}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          color: isOwn ? theme.primary : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        handle,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                _relTime(post.createdAt),
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Content
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},  // PostDetailWidget navigation — wire when route exists
            child: Text(
              post.content ?? '',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.82),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),

          // Media
          if (post.mediaUrl?.isNotEmpty == true) ...[
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

          // Actions
          const SizedBox(height: 12),
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: () => _toggleLike(post),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(liked),
                        color: liked
                            ? theme.primary
                            : Colors.white.withOpacity(0.45),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      likeCount > 0 ? '$likeCount' : 'Like',
                      style: GoogleFonts.inter(
                        color: liked
                            ? theme.primary
                            : Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Comment (count display only for now)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white.withOpacity(0.45), size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'Comment',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Share
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_outlined,
                      color: Colors.white.withOpacity(0.45), size: 16),
                  const SizedBox(width: 5),
                  Text(
                    'Share',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postAvatarIcon(bool isOwn, FlutterFlowTheme theme) => Icon(
        Icons.person_rounded,
        color: isOwn ? theme.primary : Colors.white.withOpacity(0.4),
        size: 17,
      );
}
