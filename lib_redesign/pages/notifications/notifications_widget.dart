// notifications_widget.dart  — NEW SCREEN
// Add to lib/pages/notifications/notifications_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';
import '/components/sx_shared_widgets.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});
  static const String routeName = 'Notifications';
  static const String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  final Set<int> _read = {};

  static const _notifs = [
    {'icon': '🏆', 'title': 'New leaderboard position!', 'desc': 'You moved up to rank 9 in OD Tactical Shoot.', 'time': '5m', 'route': 'Leaderboard'},
    {'icon': '👥', 'title': 'Club event reminder', 'desc': 'Steel Challenge Night starts in 2 hours.', 'time': '2h', 'route': 'EventDetails'},
    {'icon': '💬', 'title': 'John Wick commented on your post', 'desc': '"Great grouping, what ammo are you running?"', 'time': '3h', 'route': 'PostDetail'},
    {'icon': '⭐', 'title': 'Achievement unlocked!', 'desc': 'Sharp Shooter — scored 95% or above.', 'time': '1d', 'route': 'UserProfile'},
    {'icon': '👤', 'title': 'Sarah Daley is now following you', 'desc': '', 'time': '2d', 'route': 'UserProfile'},
    {'icon': '📅', 'title': 'Monthly Medal is now open', 'desc': '12 spots remaining — book now.', 'time': '3d', 'route': 'EventDetails'},
  ];

  void _onTap(BuildContext context, int i) {
    setState(() => _read.add(i));
    final route = _notifs[i]['route'] as String;
    switch (route) {
      case 'Leaderboard':
        context.pushNamed('Leaderboard');
        break;
      case 'EventDetails':
        context.pushNamed('EventDetails', queryParameters: {'eventId': 'event_0'});
        break;
      case 'UserProfile':
        context.pushNamed('UserProfile', queryParameters: {'userId': 'user_0'});
        break;
      default:
        break;
    }
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
            child: ListView.builder(
              itemCount: _notifs.length,
              itemBuilder: (ctx, i) {
                final n = _notifs[i];
                final read = _read.contains(i);
                return GestureDetector(
                  onTap: () => _onTap(context, i),
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
                          child: Text(n['icon'] as String,
                              style: const TextStyle(fontSize: 22),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['title'] as String,
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            if ((n['desc'] as String).isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(n['desc'] as String,
                                  style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12, height: 1.4)),
                            ],
                          ],
                        )),
                        const SizedBox(width: 8),
                        Text(n['time'] as String,
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
