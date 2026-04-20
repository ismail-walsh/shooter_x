import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/sx_shared_widgets.dart';
import '/services/database_service.dart';

class MembershipCardWidget extends StatefulWidget {
  const MembershipCardWidget({super.key, this.userId});
  final String? userId;

  static const String routeName = 'MembershipCard';
  static const String routePath = '/membershipCard';

  @override
  State<MembershipCardWidget> createState() => _MembershipCardWidgetState();
}

class _MembershipCardWidgetState extends State<MembershipCardWidget> {
  bool _loading = true;
  UsersRow? _user;
  ClubsRow? _club;
  MembershipCardsRow? _card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final uid = (widget.userId?.isNotEmpty == true)
          ? widget.userId!
          : currentUserUid ?? '';
      if (uid.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final user = await databaseService.getUserById(uid);
      final memberships = await databaseService.getUserClubMemberships();
      final cards = await databaseService.getUserMembershipCards();

      ClubsRow? club;
      MembershipCardsRow? card;

      if (memberships.isNotEmpty) {
        final clubId = memberships.first.clubId ?? '';
        club = await databaseService.getClubById(clubId);
        card = cards.where((c) => c.clubId == clubId).firstOrNull;
        card ??= cards.isNotEmpty ? cards.first : null;
      }

      if (mounted) {
        setState(() {
          _user = user;
          _club = club;
          _card = card;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _memberName {
    if (_user == null) return 'Member';
    final full = _user!.fullName;
    if (full != null && full.isNotEmpty) return full;
    return _user!.username;
  }

  String get _clubName => _club?.name ?? 'Shooting Club';
  String get _clubAddress => _club?.location ?? '';
  String get _cardNumber => _card?.cardNumber ?? 'PENDING';
  String get _openingHours =>
      _club?.openingHours ?? 'Contact club for range hours';
  String get _expiryYear {
    final dt = _card?.expiryDate;
    if (dt == null) return '2027';
    return dt.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(children: [
          SXBackHeader(title: 'Membership Card'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(children: [
                      _buildCard(context, theme),
                      const SizedBox(height: 24),
                      _buildInfoSection(context, theme),
                    ]),
                  ),
          ),
        ]),
      ),
    );
  }

  // ── Membership Card ───────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2E1A), Color(0xFF0D1A0D)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: [
        // ── Card header ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.15),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.gps_fixed_rounded,
                  color: theme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _clubName,
                    style: GoogleFonts.interTight(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3),
                  ),
                  Text('MEMBER CARD',
                      style: GoogleFonts.inter(
                          color: theme.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
            Text('Valid\n$_expiryYear',
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ]),
        ),

        // ── Punched ticket divider ────────────────────────────
        _TicketDivider(theme: theme),

        // ── Member details ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MEMBER',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(_memberName,
                  style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Row(children: [
                _CardStat(label: 'MEMBER NO.', value: _cardNumber, theme: theme),
                const SizedBox(width: 24),
                _CardStat(label: 'EXPIRES', value: _expiryYear, theme: theme),
              ]),
            ],
          ),
        ),

        // ── Barcode ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BarcodeWidget(
              data: _cardNumber,
              barcode: Barcode.code128(),
              color: Colors.black,
              backgroundColor: Colors.transparent,
              drawText: true,
              style: const TextStyle(
                  fontSize: 8, color: Colors.black54),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Info section below card ───────────────────────────────────────────────

  Widget _buildInfoSection(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(children: [
        _InfoRow(
          icon: Icons.location_on_rounded,
          label: 'Address',
          value: _clubAddress.isNotEmpty ? _clubAddress : 'See club website',
          theme: theme,
          showDivider: true,
        ),
        _InfoRow(
          icon: Icons.access_time_rounded,
          label: 'Range Hours',
          value: _openingHours,
          theme: theme,
          showDivider: _club?.phone != null,
        ),
        if (_club?.phone != null && _club!.phone!.isNotEmpty)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _club!.phone!,
            theme: theme,
            showDivider: false,
          ),
      ]),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _TicketDivider extends StatelessWidget {
  const _TicketDivider({required this.theme});
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            shape: BoxShape.circle,
          )),
      Expanded(
        child: LayoutBuilder(builder: (context, constraints) {
          final dashCount = (constraints.maxWidth / 10).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) => Container(
              width: 4, height: 1,
              color: Colors.white.withOpacity(0.15),
            )),
          );
        }),
      ),
      Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            shape: BoxShape.circle,
          )),
    ]);
  }
}

class _CardStat extends StatelessWidget {
  const _CardStat(
      {required this.label, required this.value, required this.theme});
  final String label;
  final String value;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2)),
      const SizedBox(height: 2),
      Text(value,
          style: GoogleFonts.inter(
              color: theme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700)),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.showDivider,
  });
  final IconData icon;
  final String label;
  final String value;
  final FlutterFlowTheme theme;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(value,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ]),
      ),
      if (showDivider) Divider(color: theme.borderColor, height: 1),
    ]);
  }
}
