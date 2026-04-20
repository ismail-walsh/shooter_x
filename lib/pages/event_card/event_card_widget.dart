import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/sx_shared_widgets.dart';
import 'event_card_model.dart';
export 'event_card_model.dart';

class EventCardWidget extends StatefulWidget {
  const EventCardWidget({super.key, this.clubId});
  final String? clubId;

  static const String routeName = 'EventCard';
  static const String routePath = '/eventCard';

  @override
  State<EventCardWidget> createState() => _EventCardWidgetState();
}

class _EventCardWidgetState extends State<EventCardWidget> {
  bool _loading = true;
  List<EventsRow> _events = [];
  ClubsRow? _club;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      List<EventsRow> events;
      ClubsRow? club;

      if (widget.clubId != null && widget.clubId!.isNotEmpty) {
        // Load events for this specific club (all, not just future)
        events = await EventsTable().queryRows(
          queryFn: (q) => q
              .eqOrNull('club_id', widget.clubId)
              .order('date', ascending: true),
        );
        final clubs = await ClubsTable().queryRows(
          queryFn: (q) => q.eqOrNull('id', widget.clubId),
        );
        club = clubs.isNotEmpty ? clubs.first : null;
      } else {
        // No clubId — show all upcoming events
        events = await EventsTable().queryRows(
          queryFn: (q) => q
              .gte('date', today)
              .order('date', ascending: true)
              .limit(20),
        );
      }

      if (mounted) {
        setState(() {
          _events = events;
          _club = club;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = _club != null ? '${_club!.name} Schedule' : 'Schedule';
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: title),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _events.isEmpty
                    ? _buildEmpty(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _events.length,
                        itemBuilder: (ctx, i) =>
                            _buildEventTile(theme, _events[i]),
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.alternate,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy_rounded,
                color: theme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('No events scheduled',
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Check back soon for upcoming events',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.4), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEventTile(FlutterFlowTheme theme, EventsRow event) {
    final dt = event.date;
    final monthStr =
        dt != null ? DateFormat('MMM').format(dt).toUpperCase() : '';
    final dayStr = dt != null ? dt.day.toString() : '—';
    final timeStr = dt != null ? DateFormat('h:mm a').format(dt) : '';

    final isPast = dt != null && dt.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isPast ? theme.borderColor : theme.primary.withOpacity(0.2),
        ),
      ),
      child:
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date badge
        Container(
          width: 48,
          height: 54,
          decoration: BoxDecoration(
            color: isPast
                ? theme.alternate
                : theme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(monthStr,
                  style: GoogleFonts.inter(
                      color: isPast
                          ? Colors.white.withOpacity(0.3)
                          : theme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              Text(dayStr,
                  style: GoogleFonts.interTight(
                      color:
                          isPast ? Colors.white.withOpacity(0.3) : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(event.name,
                      style: GoogleFonts.inter(
                          color: isPast
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                if (isPast)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('PAST',
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 4),
              if (timeStr.isNotEmpty)
                _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: timeStr,
                    theme: theme),
              if (event.location != null && event.location!.isNotEmpty)
                _InfoChip(
                    icon: Icons.location_on_rounded,
                    label: event.location!,
                    theme: theme),
              if (event.discipline != null) ...[
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(event.discipline!,
                      style: GoogleFonts.inter(
                          color: theme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ],
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(event.description!,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        height: 1.45),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3), size: 18),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.label, required this.theme});
  final IconData icon;
  final String label;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: [
        Icon(icon, color: Colors.white.withOpacity(0.35), size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.45), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
