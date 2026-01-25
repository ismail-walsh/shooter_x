import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/database_service.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'club_profile_model.dart';
export 'club_profile_model.dart';

class ClubProfileWidget extends StatefulWidget {
  const ClubProfileWidget({
    super.key,
    required this.clubId,
  });

  final String? clubId;

  static String routeName = 'ClubProfile';
  static String routePath = '/clubProfile';

  @override
  State<ClubProfileWidget> createState() => _ClubProfileWidgetState();
}

class _ClubProfileWidgetState extends State<ClubProfileWidget> {
  late ClubProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ClubsRow? _club;
  List<EventsRow> _events = [];
  bool _isLoading = true;
  bool _isMember = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClubProfileModel());
    _loadClubData();
  }

  Future<void> _loadClubData() async {
    if (widget.clubId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final club = await databaseService.getClubById(widget.clubId!);
      final isMember = await databaseService.isClubMember(widget.clubId!);
      final events = await databaseService.getAllEvents(clubId: widget.clubId);

      if (mounted) {
        setState(() {
          _club = club;
          _isMember = isMember;
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading club: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  Future<void> _toggleMembership() async {
    if (widget.clubId == null) return;

    setState(() => _isJoining = true);

    try {
      if (_isMember) {
        await databaseService.leaveClub(widget.clubId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have left the club'),
              backgroundColor: FlutterFlowTheme.of(context).secondaryText,
            ),
          );
        }
      } else {
        await databaseService.joinClub(widget.clubId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have joined the club!'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isMember = !_isMember;
          _isJoining = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : _club == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Club not found',
                          style: FlutterFlowTheme.of(context).headlineSmall,
                        ),
                        SizedBox(height: 16.0),
                        FFButtonWidget(
                          onPressed: () => context.pop(),
                          text: 'Go Back',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.interTight(),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 200.0,
                        floating: false,
                        pinned: true,
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        leading: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 60.0,
                          fillColor: Colors.black26,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: _club!.coverImg != null && _club!.coverImg!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _club!.coverImg!,
                                  width: double.infinity,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: FlutterFlowTheme.of(context).primary,
                                    child: Icon(Icons.gps_fixed, size: 50, color: Colors.white54),
                                  ),
                                )
                              : Container(
                                  color: FlutterFlowTheme.of(context).primary,
                                  child: Icon(Icons.gps_fixed, size: 50, color: Colors.white54),
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80.0,
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).alternate,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                              width: 3.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(9.0),
                                            child: _club!.profileImg != null &&
                                                    _club!.profileImg!.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: _club!.profileImg!,
                                                    width: 80.0,
                                                    height: 80.0,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Icon(
                                                    Icons.gps_fixed,
                                                    size: 40.0,
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                  ),
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _club!.name ?? 'Unknown Club',
                                                style: FlutterFlowTheme.of(context)
                                                    .headlineSmall
                                                    .override(
                                                      font: GoogleFonts.interTight(
                                                          fontWeight: FontWeight.bold),
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              if (_club!.discipline != null)
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(
                                                      0.0, 4.0, 0.0, 0.0),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 8.0, vertical: 4.0),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context)
                                                          .primary
                                                          .withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Text(
                                                      _club!.discipline!,
                                                      style: FlutterFlowTheme.of(context)
                                                          .labelSmall
                                                          .override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context)
                                                                .primary,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              if (_club!.location != null)
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(
                                                      0.0, 8.0, 0.0, 0.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on_outlined,
                                                        size: 16.0,
                                                        color: FlutterFlowTheme.of(context)
                                                            .secondaryText,
                                                      ),
                                                      SizedBox(width: 4.0),
                                                      Text(
                                                        _club!.location!,
                                                        style: FlutterFlowTheme.of(context)
                                                            .bodySmall
                                                            .override(
                                                              font: GoogleFonts.inter(),
                                                              color: FlutterFlowTheme.of(context)
                                                                  .secondaryText,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.0),
                                    Container(
                                      width: double.infinity,
                                      height: 50.0,
                                      decoration: _isMember
                                          ? BoxDecoration(
                                              borderRadius: BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: FlutterFlowTheme.of(context).alternate,
                                                width: 2.0,
                                              ),
                                            )
                                          : BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFF00A224), Color(0xFF003C0D)],
                                                stops: [0.2, 1.0],
                                                begin: AlignmentDirectional(1.0, 0.0),
                                                end: AlignmentDirectional(-1.0, 0),
                                              ),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                      child: FFButtonWidget(
                                        onPressed: _isJoining ? null : _toggleMembership,
                                        text: _isJoining
                                            ? 'Loading...'
                                            : (_isMember ? 'Leave Club' : 'Join Club'),
                                        icon: _isJoining
                                            ? null
                                            : Icon(
                                                _isMember ? Icons.logout : Icons.add,
                                                size: 20.0,
                                              ),
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 50.0,
                                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                          color: Colors.transparent,
                                          textStyle:
                                              FlutterFlowTheme.of(context).titleSmall.override(
                                                    font: GoogleFonts.interTight(),
                                                    color: _isMember
                                                        ? FlutterFlowTheme.of(context).primaryText
                                                        : Colors.white,
                                                    letterSpacing: 0.0,
                                                  ),
                                          elevation: 0.0,
                                          borderSide:
                                              BorderSide(color: Colors.transparent, width: 1.0),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_club!.description != null && _club!.description!.isNotEmpty)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      _club!.description!,
                                      style: FlutterFlowTheme.of(context).bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            if (_events.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 8.0),
                                child: Text(
                                  'Upcoming Events',
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              ..._events.take(3).map((event) => _buildEventCard(event)),
                            ],
                            SizedBox(height: 32.0),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEventCard(EventsRow event) {
    final date = event.date != null
        ? DateFormat('MMM d, yyyy').format(event.date!)
        : 'Date TBD';

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            EventDetailsWidget.routeName,
            queryParameters: {
              'eventId': serializeParam(event.id, ParamType.String),
            }.withoutNulls,
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x1F000000),
                offset: Offset(0.0, 2.0),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.event,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name ?? 'Event',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      date,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
