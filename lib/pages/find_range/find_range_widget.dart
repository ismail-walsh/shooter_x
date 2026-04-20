import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class FindRangeWidget extends StatefulWidget {
  const FindRangeWidget({super.key});
  static const String routeName = 'FindRange';
  static const String routePath = '/findRange';

  @override
  State<FindRangeWidget> createState() => _FindRangeWidgetState();
}

class _FindRangeWidgetState extends State<FindRangeWidget> {
  bool _loading = true;
  List<RangesRow> _ranges = [];
  int? _selected;
  final _mapController = MapController();

  // Default centre: middle of England
  static const _ukCenter = ll.LatLng(52.5, -1.5);
  static const _defaultZoom = 6.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ranges = await databaseService.getAllRanges();
      if (mounted) setState(() { _ranges = ranges; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectRange(int i) {
    final alreadySelected = _selected == i;
    setState(() => _selected = alreadySelected ? null : i);
    if (!alreadySelected) {
      final r = _ranges[i];
      if (r.latitude != null && r.longitude != null) {
        _mapController.move(ll.LatLng(r.latitude!, r.longitude!), 13.0);
      }
    }
  }

  Future<void> _openMaps(RangesRow r) async {
    if (r.latitude == null || r.longitude == null) return;
    final lat = r.latitude!;
    final lng = r.longitude!;
    final q = Uri.encodeComponent(r.name);
    // Apple Maps first (iOS), Google Maps fallback
    final apple = Uri.parse('https://maps.apple.com/?q=$q&ll=$lat,$lng&z=16');
    final google = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(apple, mode: LaunchMode.externalApplication)) {
      await launchUrl(google, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callRange(RangesRow r) async {
    final phone = r.phone;
    if (phone == null || phone.isEmpty) return;
    final cleaned = phone.replaceAll(' ', '').replaceAll('-', '');
    await launchUrl(Uri.parse('tel:$cleaned'));
  }

  Future<void> _openWebsite(RangesRow r) async {
    final url = r.websiteUrl;
    if (url == null || url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Find a Range'),
          _buildMap(context, theme),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _ranges.isEmpty
                    ? Center(
                        child: Text('No ranges found.',
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _ranges.length,
                        itemBuilder: (ctx, i) => _buildRangeTile(ctx, theme, i),
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMap(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.borderColor)),
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: _ukCenter,
          initialZoom: _defaultZoom,
          minZoom: 4,
          maxZoom: 18,
        ),
        children: [
          // Dark tile layer — CartoDB Dark Matter (free, no API key)
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.walshtechnologies.shooterx',
          ),
          MarkerLayer(
            markers: _ranges.asMap().entries
                .where((e) =>
                    e.value.latitude != null && e.value.longitude != null)
                .map((e) {
              final i = e.key;
              final r = e.value;
              final sel = _selected == i;
              final open = r.isOpen ?? true;
              return Marker(
                point: ll.LatLng(r.latitude!, r.longitude!),
                width: 120,
                height: 46,
                child: GestureDetector(
                  onTap: () => _selectRange(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: sel
                              ? theme.primary
                              : open
                                  ? const Color(0xFF0D1A0D)
                                  : const Color(0xFF1A0D0D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? theme.primary
                                : open
                                    ? theme.primary.withOpacity(0.5)
                                    : const Color(0xFFEF4444).withOpacity(0.6),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                        child: Text(
                          r.name.split(' ').first,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                          width: 2,
                          height: 6,
                          color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Map attribution
          const SimpleAttributionWidget(
            source: Text('© CartoDB · © OpenStreetMap',
                style: TextStyle(fontSize: 9, color: Colors.white38)),
            alignment: Alignment.bottomRight,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTile(BuildContext context, FlutterFlowTheme theme, int i) {
    final r = _ranges[i];
    final sel = _selected == i;
    final open = r.isOpen ?? true;
    final isClay = r.discipline?.toLowerCase().contains('clay') ?? false;

    return GestureDetector(
      onTap: () => _selectRange(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: sel
              ? theme.primary.withOpacity(0.06)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: sel ? theme.primary : theme.borderColor),
        ),
        child: Column(children: [
          // ── Header row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: open
                      ? theme.primary.withOpacity(0.12)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isClay ? Icons.sports_baseball_rounded : Icons.adjust_rounded,
                  color: open ? theme.primary : const Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      r.discipline != null
                          ? '${r.discipline!} · ${r.location ?? ''}'
                          : (r.location ?? ''),
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: open
                      ? theme.primary.withOpacity(0.15)
                      : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  open ? 'OPEN' : 'CLOSED',
                  style: GoogleFonts.inter(
                      color: open
                          ? theme.primary
                          : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
          // ── Expanded detail ──────────────────────────────────
          if (sel) ...[
            Divider(color: theme.borderColor, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (r.description != null && r.description!.isNotEmpty) ...[
                    Text(r.description!,
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12,
                            height: 1.55)),
                    const SizedBox(height: 12),
                  ],
                  // Opening hours
                  if (r.openingHours != null &&
                      r.openingHours!.isNotEmpty) ...[
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: r.openingHours!,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Phone
                  if (r.phone != null && r.phone!.isNotEmpty) ...[
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: r.phone!,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 4),
                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: _MapButton(
                        icon: Icons.directions_rounded,
                        label: 'Directions',
                        onTap: () => _openMaps(r),
                        theme: theme,
                      ),
                    ),
                    if (r.phone != null && r.phone!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MapButton(
                          icon: Icons.phone_rounded,
                          label: 'Call',
                          onTap: () => _callRange(r),
                          theme: theme,
                          outlined: true,
                        ),
                      ),
                    ],
                    if (r.websiteUrl != null && r.websiteUrl!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MapButton(
                          icon: Icons.language_rounded,
                          label: 'Website',
                          onTap: () => _openWebsite(r),
                          theme: theme,
                          outlined: true,
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.theme});
  final IconData icon;
  final String label;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: theme.primary, size: 14),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              height: 1.55),
        ),
      ),
    ]);
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
    this.outlined = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final FlutterFlowTheme theme;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : theme.primary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.primary),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
