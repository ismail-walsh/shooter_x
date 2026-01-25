import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/database_service.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'event_details_model.dart';
export 'event_details_model.dart';

class EventDetailsWidget extends StatefulWidget {
  const EventDetailsWidget({
    super.key,
    required this.eventId,
  });

  final String? eventId;

  static String routeName = 'EventDetails';
  static String routePath = '/eventDetails';

  @override
  State<EventDetailsWidget> createState() => _EventDetailsWidgetState();
}

class _EventDetailsWidgetState extends State<EventDetailsWidget> {
  late EventDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  EventsRow? _event;
  ClubsRow? _club;
  bool _isLoading = true;
  bool _isRegistered = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EventDetailsModel());
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    if (widget.eventId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final event = await databaseService.getEventById(widget.eventId!);
      final isRegistered = await databaseService.isRegisteredForEvent(widget.eventId!);

      ClubsRow? club;
      if (event?.clubId != null) {
        club = await databaseService.getClubById(event!.clubId!);
      }

      if (mounted) {
        setState(() {
          _event = event;
          _club = club;
          _isRegistered = isRegistered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading event: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  Future<void> _toggleRegistration() async {
    if (widget.eventId == null) return;

    setState(() => _isRegistering = true);

    try {
      if (_isRegistered) {
        await databaseService.unregisterFromEvent(widget.eventId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration cancelled'),
              backgroundColor: FlutterFlowTheme.of(context).secondaryText,
            ),
          );
        }
      } else {
        await databaseService.registerForEvent(widget.eventId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully registered for the event!'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isRegistered = !_isRegistered;
          _isRegistering = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRegistering = false);
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Event Details',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : _event == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Event not found',
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
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Header
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00A224), Color(0xFF003C0D)],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Event Date
                                  if (_event!.date != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        DateFormat('EEEE, MMMM d, yyyy')
                                            .format(_event!.date!),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600),
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  SizedBox(height: 16.0),
                                  // Event Name
                                  Text(
                                    _event!.name ?? 'Unnamed Event',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  if (_event!.discipline != null)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          _event!.discipline!,
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.inter(),
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Event Info Cards
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                            child: Column(
                              children: [
                                // Location Card
                                if (_event!.location != null)
                                  _buildInfoCard(
                                    Icons.location_on_outlined,
                                    'Location',
                                    _event!.location!,
                                  ),
                                // Club Card
                                if (_club != null)
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed(
                                        ClubProfileWidget.routeName,
                                        queryParameters: {
                                          'clubId':
                                              serializeParam(_club!.id, ParamType.String),
                                        }.withoutNulls,
                                      );
                                    },
                                    child: _buildInfoCard(
                                      Icons.groups_outlined,
                                      'Hosted by',
                                      _club!.name ?? 'Unknown Club',
                                      showArrow: true,
                                    ),
                                  ),
                                // Max Participants Card
                                if (_event!.maxParticipants != null)
                                  _buildInfoCard(
                                    Icons.people_outline,
                                    'Max Participants',
                                    '${_event!.maxParticipants} spots',
                                  ),
                              ],
                            ),
                          ),

                          // Description Section
                          if (_event!.description != null &&
                              _event!.description!.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About this Event',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    _event!.description!,
                                    style: FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                          // Registration Status
                          if (_isRegistered)
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'You\'re Registered!',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  font: GoogleFonts.inter(
                                                      fontWeight: FontWeight.w600),
                                                  color: FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                          ),
                                          Text(
                                            'We\'ll see you at the event',
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
                            ),

                          // Action Buttons
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16.0, 32.0, 16.0, 32.0),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: _isRegistered
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.5),
                                            width: 2.0,
                                          ),
                                        )
                                      : BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF00A224),
                                              Color(0xFF003C0D)
                                            ],
                                            stops: [0.2, 1.0],
                                            begin: AlignmentDirectional(1.0, 0.0),
                                            end: AlignmentDirectional(-1.0, 0),
                                          ),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                  child: FFButtonWidget(
                                    onPressed: _isRegistering ? null : _toggleRegistration,
                                    text: _isRegistering
                                        ? 'Loading...'
                                        : (_isRegistered
                                            ? 'Cancel Registration'
                                            : 'Register for Event'),
                                    icon: _isRegistering
                                        ? null
                                        : Icon(
                                            _isRegistered
                                                ? Icons.close
                                                : Icons.how_to_reg,
                                            size: 20.0,
                                          ),
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 50.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 8.0, 0.0),
                                      color: Colors.transparent,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(),
                                            color: _isRegistered
                                                ? Colors.red
                                                : Colors.white,
                                            letterSpacing: 0.0,
                                          ),
                                      elevation: 0.0,
                                      borderSide: BorderSide(
                                          color: Colors.transparent, width: 1.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value,
      {bool showArrow = false}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(),
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    value,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
          ],
        ),
      ),
    );
  }
}
