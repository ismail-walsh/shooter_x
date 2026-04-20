import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});
  static const String routeName = 'Notifications';
  static const String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  bool _loading = true;
  List<NotificationsRow> _notifs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notifs = await databaseService.getUserNotifications();
      if (mounted) setState(() { _notifs = notifs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onTap(BuildContext context, NotificationsRow n) async {
    // Mark as read locally and in DB
    if (n.isRead != true) {
      setState(() {
        final idx = _notifs.indexWhere((x) => x.id == n.id);
        if (idx != -1) _notifs[idx].isRead = true;
      });
      databaseService.markNotificationRead(n.id);
    }

    // Navigate based on target_type
    switch (n.targetType) {
      case 'Leaderboard':
        context.pushNamed('Leaderboard');
        break;
      case 'EventDetails':
        context.pushNamed('EventDetails',
            queryParameters: {'eventId': n.targetId ?? ''});
        break;
      case 'UserProfile':
        context.pushNamed('UserProfile',
            queryParameters: {'userId': n.targetId ?? ''});
        break;
      default:
        break;
    }
  }

  static String _relativeTime(DateTime? dt) {
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
        child: Column(children: [
          SXBackHeader(title: 'Notifications'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _notifs.isEmpty
                    ? Center(
                        child: Text('No notifications yet.',
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14)))
                    : ListView.builder(
                        itemCount: _notifs.length,
                        itemBuilder: (ctx, i) {
                          final n = _notifs[i];
                          final read = n.isRead == true;
                          return GestureDetector(
                            onTap: () => _onTap(context, n),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: read
                                  ? Colors.transparent
                                  : theme.primary.withOpacity(0.04),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Unread dot
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, right: 8),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 6, height: 6,
                                      decoration: BoxDecoration(
                                        color: read
                                            ? Colors.transparent
                                            : theme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  // Icon
                                  SizedBox(
                                    width: 36,
                                    child: Text(n.icon ?? '🔔',
                                        style: const TextStyle(fontSize: 22),
                                        textAlign: TextAlign.center),
                                  ),
                                  const SizedBox(width: 12),
                                  // Content
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.title,
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      if ((n.body ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(n.body!,
                                            style: GoogleFonts.inter(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 12,
                                                height: 1.4)),
                                      ],
                                    ],
                                  )),
                                  const SizedBox(width: 8),
                                  Text(_relativeTime(n.createdAt),
                                      style: GoogleFonts.inter(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
