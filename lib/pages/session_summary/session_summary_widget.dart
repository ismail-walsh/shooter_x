import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/database_service.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_summary_model.dart';
export 'session_summary_model.dart';

class SessionSummaryWidget extends StatefulWidget {
  const SessionSummaryWidget({
    super.key,
    required this.sessionId,
  });

  final String? sessionId;

  static String routeName = 'SessionSummary';
  static String routePath = '/sessionSummary';

  @override
  State<SessionSummaryWidget> createState() => _SessionSummaryWidgetState();
}

class _SessionSummaryWidgetState extends State<SessionSummaryWidget>
    with TickerProviderStateMixin {
  late SessionSummaryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  SessionsRow? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SessionSummaryModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: Offset(0.0, 20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    _loadSession();
  }

  Future<void> _loadSession() async {
    if (widget.sessionId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final session = await databaseService.getSessionById(widget.sessionId!);
      if (mounted) {
        setState(() {
          _session = session;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading session: ${e.toString()}'),
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
            'Session Summary',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.share_outlined,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
          ],
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
              : _session == null
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
                            'Session not found',
                            style: FlutterFlowTheme.of(context).headlineSmall,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Accuracy Hero Section
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
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 24.0, 24.0, 32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'Accuracy',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.interTight(),
                                          color: Colors.white70,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    '${_session!.accuracy?.toStringAsFixed(1) ?? '0'}%',
                                    style: FlutterFlowTheme.of(context)
                                        .displayLarge
                                        .override(
                                          font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold),
                                          color: Colors.white,
                                          fontSize: 64.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    '${_session!.hits ?? 0} hits out of ${_session!.totalShots ?? 0} shots',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: Colors.white70,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ).animateOnPageLoad(
                              animationsMap['containerOnPageLoadAnimation']!),

                          // Session Details
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 24.0, 16.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session Details',
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                SizedBox(height: 16.0),
                                _buildDetailRow(
                                  'Discipline',
                                  _session!.discipline ?? 'Not specified',
                                  Icons.sports,
                                ),
                                _buildDetailRow(
                                  'Firearm',
                                  _session!.firearm ?? 'Not specified',
                                  Icons.gps_fixed,
                                ),
                                _buildDetailRow(
                                  'Ammunition',
                                  _session!.ammoType ?? 'Not specified',
                                  Icons.inventory_2_outlined,
                                ),
                                _buildDetailRow(
                                  'Distance',
                                  '${_session!.distance ?? 0} meters',
                                  Icons.straighten,
                                ),
                                _buildDetailRow(
                                  'Date',
                                  _session!.createdAt != null
                                      ? DateFormat('MMMM d, yyyy • h:mm a')
                                          .format(_session!.createdAt!)
                                      : 'Unknown',
                                  Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),

                          // Conditions Section
                          if (_session!.conditions != null)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 24.0, 16.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conditions',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  SizedBox(height: 16.0),
                                  if (_session!.conditions!['weather'] != null)
                                    _buildDetailRow(
                                      'Weather',
                                      _session!.conditions!['weather'],
                                      Icons.wb_sunny_outlined,
                                    ),
                                  if (_session!.conditions!['wind'] != null)
                                    _buildDetailRow(
                                      'Wind',
                                      _session!.conditions!['wind'],
                                      Icons.air,
                                    ),
                                  if (_session!.conditions!['notes'] != null &&
                                      _session!.conditions!['notes'].toString().isNotEmpty)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Notes',
                                              style: FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              _session!.conditions!['notes'],
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // Action Buttons
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 32.0, 16.0, 32.0),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
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
                                    onPressed: () {
                                      context.pushNamed(AddSessionWidget.routeName);
                                    },
                                    text: 'Record Another Session',
                                    icon: Icon(Icons.add, size: 20.0),
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
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                          ),
                                      elevation: 0.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.0),
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed(ActivityWidget.routeName);
                                  },
                                  text: 'View All Sessions',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.interTight(),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).alternate,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
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
          mainAxisSize: MainAxisSize.max,
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
          ],
        ),
      ),
    );
  }
}
