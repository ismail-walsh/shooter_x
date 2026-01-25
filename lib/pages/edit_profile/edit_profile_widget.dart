import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/services/database_service.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  UsersRow? _currentUser;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    _model.usernameTextController ??= TextEditingController();
    _model.usernameFocusNode ??= FocusNode();

    _model.bioTextController ??= TextEditingController();
    _model.bioFocusNode ??= FocusNode();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _model.isLoading = true;
    });

    try {
      final user = await databaseService.getCurrentUserProfile();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _model.usernameTextController?.text = user.username;
          _model.bioTextController?.text = user.bio ?? '';
          _model.disciplineValue = user.preferredDiscipline;
        });
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
          _model.isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_model.formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _model.isSaving = true;
    });

    try {
      await databaseService.updateUserProfile(
        userId: currentUserUid!,
        username: _model.usernameTextController!.text,
        bio: _model.bioTextController!.text,
        preferredDiscipline: _model.disciplineValue,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _model.isSaving = false;
        });
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
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Edit Profile',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: _model.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Profile Picture Section
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                          child: Column(
                            children: [
                              Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: _currentUser?.profileImg != null &&
                                          _currentUser!.profileImg!.isNotEmpty
                                      ? CachedNetworkImage(
                                          fadeInDuration: Duration(milliseconds: 500),
                                          fadeOutDuration: Duration(milliseconds: 500),
                                          imageUrl: _currentUser!.profileImg!,
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context).primary,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.person,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            size: 50.0,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          size: 50.0,
                                        ),
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Text(
                                'Profile photo can be changed via your account settings',
                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.inter(),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Form Fields
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username Field
                              Text(
                                'Username',
                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                                child: TextFormField(
                                  controller: _model.usernameTextController,
                                  focusNode: _model.usernameFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your username',
                                    hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).primary,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                  validator:
                                      _model.usernameTextControllerValidator.asValidator(context),
                                ),
                              ),

                              // Bio Field
                              Text(
                                'Bio',
                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                                child: TextFormField(
                                  controller: _model.bioTextController,
                                  focusNode: _model.bioFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Tell us about yourself...',
                                    hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).primary,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              ),

                              // Preferred Discipline Dropdown
                              Text(
                                'Preferred Discipline',
                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                                child: FutureBuilder<List<DisciplinesRow>>(
                                  future: DisciplinesTable().queryRows(
                                    queryFn: (q) => q.order('discipline_name'),
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
                                        height: 50,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final disciplines = snapshot.data!;
                                    final options = disciplines.isEmpty
                                        ? [
                                            'Target Shooting',
                                            'Hunting',
                                            'Competition',
                                            'Tactical',
                                            'Sporting Clays'
                                          ]
                                        : disciplines
                                            .map((d) => d.disciplineName ?? 'Unknown')
                                            .toList();

                                    return FlutterFlowDropDown<String>(
                                      controller: _model.disciplineValueController ??=
                                          FormFieldController<String>(_model.disciplineValue),
                                      options: options,
                                      onChanged: (val) =>
                                          setState(() => _model.disciplineValue = val),
                                      width: double.infinity,
                                      height: 50.0,
                                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(),
                                            letterSpacing: 0.0,
                                          ),
                                      hintText: 'Select your preferred discipline...',
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 24.0,
                                      ),
                                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                      elevation: 2.0,
                                      borderColor: FlutterFlowTheme.of(context).alternate,
                                      borderWidth: 2.0,
                                      borderRadius: 12.0,
                                      margin:
                                          EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                                      hidesUnderline: true,
                                    );
                                  },
                                ),
                              ),

                              // Save Button
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 32.0),
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
                                    onPressed: _model.isSaving ? null : _saveProfile,
                                    text: _model.isSaving ? 'Saving...' : 'Save Changes',
                                    icon: _model.isSaving
                                        ? null
                                        : Icon(
                                            Icons.check,
                                            size: 20.0,
                                          ),
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 50.0,
                                      padding:
                                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                      color: Colors.transparent,
                                      textStyle:
                                          FlutterFlowTheme.of(context).titleSmall.override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                                ),
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
