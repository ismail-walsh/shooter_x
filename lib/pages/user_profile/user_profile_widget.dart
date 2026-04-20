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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({
    super.key,
    required this.userId,
    this.displayName,
  });

  final String? userId;
  /// Fallback name shown when the user row can't be loaded (e.g. RLS blocked).
  final String? displayName;

  static String routeName = 'UserProfile';
  static String routePath = '/userProfile';

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  UsersRow? _user;
  Map<String, dynamic> _stats = {};
  List<SessionsRow> _recentSessions = [];
  bool _isLoading = true;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = widget.userId ?? currentUserUid;
      _isOwnProfile = userId == currentUserUid;

      if (userId != null) {
        final user = await databaseService.getUserById(userId);
        final stats = _isOwnProfile ? await databaseService.getUserSessionStats() : {};
        final sessions = _isOwnProfile ? await databaseService.getUserSessions() : <SessionsRow>[];

        if (mounted) {
          setState(() {
            _user = user;
            _stats = Map<String, dynamic>.from(stats);
            _recentSessions = sessions.take(5).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildNotFoundPlaceholder(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = widget.displayName?.isNotEmpty == true
        ? widget.displayName!
        : 'Unknown User';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: theme.alternate,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  color: Colors.white.withOpacity(0.4), size: 40),
            ),
            const SizedBox(height: 16),
            Text(name,
                style: GoogleFonts.interTight(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Profile not available',
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.4), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authManager.signOut();
      if (mounted) {
        context.goNamed(OnboardingWidget.routeName);
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
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Profile',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            if (_isOwnProfile)
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.settings_outlined,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24.0,
                ),
                onPressed: () {
                  context.pushNamed(EditProfileWidget.routeName);
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
              : _user == null
                  ? _buildNotFoundPlaceholder(context)

                  : RefreshIndicator(
                      onRefresh: _loadUserData,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // Profile Header
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5.0,
                                    color: Color(0x230F1113),
                                    offset: Offset(0.0, 2.0),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Profile Picture
                                    Container(
                                      width: 80.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF0000CE), Color(0xFF00A224)],
                                          stops: [0.0, 1.0],
                                          begin: AlignmentDirectional(-1.0, 0.0),
                                          end: AlignmentDirectional(1.0, 0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(60.0),
                                          child: _user!.profileImg != null &&
                                                  _user!.profileImg!.isNotEmpty
                                              ? CachedNetworkImage(
                                                  fadeInDuration: Duration(milliseconds: 500),
                                                  fadeOutDuration: Duration(milliseconds: 500),
                                                  imageUrl: _user!.profileImg!,
                                                  width: 80.0,
                                                  height: 80.0,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Container(
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Container(
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  color: FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color:
                                                        FlutterFlowTheme.of(context).secondaryText,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    // User Info
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _user!.username,
                                              style: FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .override(
                                                    font: GoogleFonts.interTight(),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            if (_user!.preferredDiscipline != null)
                                              Text(
                                                _user!.preferredDiscipline!,
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(),
                                                      color:
                                                          FlutterFlowTheme.of(context).primary,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            if (_stats.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      '${_stats['total_sessions'] ?? 0} sessions',
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context)
                                                                .secondaryText,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                    SizedBox(width: 8.0),
                                                    Text(
                                                      '${_stats['total_shots'] ?? 0} rounds',
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts.inter(),
                                                            color: FlutterFlowTheme.of(context)
                                                                .secondaryText,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Stats Cards
                            if (_stats.isNotEmpty)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Accuracy',
                                        '${(_stats['avg_accuracy'] ?? 0).toStringAsFixed(1)}%',
                                        Icons.gps_fixed,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Total Hits',
                                        '${_stats['total_hits'] ?? 0}',
                                        Icons.check_circle_outline,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Sessions',
                                        '${_stats['total_sessions'] ?? 0}',
                                        Icons.calendar_today,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Bio Section
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'About',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _user!.bio ?? 'No bio added yet.',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            color: _user!.bio == null
                                                ? FlutterFlowTheme.of(context).secondaryText
                                                : null,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Recent Sessions
                            if (_recentSessions.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Sessions',
                                      style: FlutterFlowTheme.of(context).labelMedium.override(
                                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    if (_isOwnProfile)
                                      InkWell(
                                        onTap: () {
                                          context.pushNamed(ActivityWidget.routeName);
                                        },
                                        child: Text(
                                          'View All',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).primary,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                primary: false,
                                shrinkWrap: true,
                                itemCount: _recentSessions.length,
                                itemBuilder: (context, index) {
                                  final session = _recentSessions[index];
                                  return _buildSessionCard(session);
                                },
                              ),
                            ],

                            // Action Buttons for own profile
                            if (_isOwnProfile) ...[
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF00A224), Color(0xFF003C0D)],
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
                                    text: 'Record New Session',
                                    icon: Icon(Icons.add, size: 20.0),
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
                                                color: Colors.white,
                                                letterSpacing: 0.0,
                                              ),
                                      elevation: 0.0,
                                      borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed(EditProfileWidget.routeName);
                                  },
                                  text: 'Edit Profile',
                                  icon: Icon(Icons.edit_outlined, size: 20.0),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    iconPadding:
                                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.interTight(),
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 32.0),
                                child: FFButtonWidget(
                                  onPressed: _logout,
                                  text: 'Logout',
                                  icon: Icon(Icons.logout, size: 20.0, color: Colors.red),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 50.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    iconPadding:
                                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.interTight(),
                                          color: Colors.red,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: Colors.red.withOpacity(0.5),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x230F1113),
            offset: Offset(0.0, 1.0),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 24.0,
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  letterSpacing: 0.0,
                ),
          ),
          SizedBox(height: 4.0),
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(),
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionsRow session) {
    final accuracy = session.accuracy?.toStringAsFixed(1) ?? '0';
    final date = session.createdAt != null
        ? DateFormat('MMM d, yyyy').format(session.createdAt!)
        : 'Unknown date';

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            SessionSummaryWidget.routeName,
            queryParameters: {
              'sessionId': serializeParam(session.id, ParamType.String),
            }.withoutNulls,
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x230F1113),
                offset: Offset(0.0, 1.0),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.gps_fixed,
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
                      session.discipline ?? 'Session',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            letterSpacing: 0.0,
                          ),
                    ),
                    Text(
                      '${session.hits ?? 0}/${session.totalShots ?? 0} hits | ${session.distance ?? 0}m',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$accuracy%',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    date,
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(),
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
