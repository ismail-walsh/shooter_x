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
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_session_model.dart';
export 'add_session_model.dart';

class AddSessionWidget extends StatefulWidget {
  const AddSessionWidget({super.key});

  static String routeName = 'AddSession';
  static String routePath = '/addSession';

  @override
  State<AddSessionWidget> createState() => _AddSessionWidgetState();
}

class _AddSessionWidgetState extends State<AddSessionWidget> {
  late AddSessionModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddSessionModel());

    _model.firearmTextController ??= TextEditingController();
    _model.firearmFocusNode ??= FocusNode();

    _model.ammoTypeTextController ??= TextEditingController();
    _model.ammoTypeFocusNode ??= FocusNode();

    _model.distanceTextController ??= TextEditingController();
    _model.distanceFocusNode ??= FocusNode();

    _model.totalShotsTextController ??= TextEditingController();
    _model.totalShotsFocusNode ??= FocusNode();

    _model.hitsTextController ??= TextEditingController();
    _model.hitsFocusNode ??= FocusNode();

    _model.notesTextController ??= TextEditingController();
    _model.notesFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    if (!(_model.formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _model.isLoading = true;
    });

    try {
      final conditions = {
        'weather': _model.weatherValue ?? 'Clear',
        'wind': _model.windValue ?? 'None',
        'notes': _model.notesTextController?.text ?? '',
      };

      final session = await databaseService.createSession(
        discipline: _model.disciplineValue ?? 'Target Shooting',
        firearm: _model.firearmTextController!.text,
        ammoType: _model.ammoTypeTextController!.text,
        distance: int.parse(_model.distanceTextController!.text),
        totalShots: int.parse(_model.totalShotsTextController!.text),
        hits: int.parse(_model.hitsTextController!.text),
        conditions: conditions,
      );

      if (session != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session saved successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
          ),
        );
        context.pushNamed(
          SessionSummaryWidget.routeName,
          queryParameters: {
            'sessionId': serializeParam(session.id, ParamType.String),
          }.withoutNulls,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving session: ${e.toString()}'),
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
            'Record Session',
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
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discipline Dropdown
                        Text(
                          'Discipline',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                ),
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
                                  ? ['Target Shooting', 'Hunting', 'Competition', 'Tactical']
                                  : disciplines.map((d) => d.disciplineName ?? 'Unknown').toList();

                              return FlutterFlowDropDown<String>(
                                controller: _model.disciplineValueController ??=
                                    FormFieldController<String>(null),
                                options: options,
                                onChanged: (val) => setState(() => _model.disciplineValue = val),
                                width: double.infinity,
                                height: 50.0,
                                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(),
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'Select discipline...',
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
                                margin: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                                hidesUnderline: true,
                              );
                            },
                          ),
                        ),

                        // Firearm Field
                        Text(
                          'Firearm',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                letterSpacing: 0.0,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: TextFormField(
                            controller: _model.firearmTextController,
                            focusNode: _model.firearmFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'e.g., Remington 700, Glock 19',
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
                            validator: _model.firearmTextControllerValidator.asValidator(context),
                          ),
                        ),

                        // Ammo Type Field
                        Text(
                          'Ammunition Type',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                letterSpacing: 0.0,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: TextFormField(
                            controller: _model.ammoTypeTextController,
                            focusNode: _model.ammoTypeFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'e.g., .308 Win, 9mm FMJ',
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
                            validator: _model.ammoTypeTextControllerValidator.asValidator(context),
                          ),
                        ),

                        // Distance Field
                        Text(
                          'Distance (meters)',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                letterSpacing: 0.0,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: TextFormField(
                            controller: _model.distanceTextController,
                            focusNode: _model.distanceFocusNode,
                            autofocus: false,
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g., 100',
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
                            validator: _model.distanceTextControllerValidator.asValidator(context),
                          ),
                        ),

                        // Shots Row
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Shots',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 8.0, 16.0),
                                    child: TextFormField(
                                      controller: _model.totalShotsTextController,
                                      focusNode: _model.totalShotsFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'e.g., 20',
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
                                      validator: _model.totalShotsTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hits on Target',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 16.0),
                                    child: TextFormField(
                                      controller: _model.hitsTextController,
                                      focusNode: _model.hitsFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'e.g., 18',
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
                                          _model.hitsTextControllerValidator.asValidator(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Conditions Section
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                          child: Text(
                            'Conditions',
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),

                        // Weather and Wind Row
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weather',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 8.0, 16.0),
                                    child: FlutterFlowDropDown<String>(
                                      controller: _model.weatherValueController ??=
                                          FormFieldController<String>(null),
                                      options: ['Clear', 'Cloudy', 'Overcast', 'Light Rain', 'Sunny'],
                                      onChanged: (val) => setState(() => _model.weatherValue = val),
                                      width: double.infinity,
                                      height: 50.0,
                                      textStyle: FlutterFlowTheme.of(context).bodyMedium,
                                      hintText: 'Weather...',
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
                                      margin: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                                      hidesUnderline: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wind',
                                    style: FlutterFlowTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 0.0, 16.0),
                                    child: FlutterFlowDropDown<String>(
                                      controller: _model.windValueController ??=
                                          FormFieldController<String>(null),
                                      options: ['None', 'Light', 'Moderate', 'Strong', 'Variable'],
                                      onChanged: (val) => setState(() => _model.windValue = val),
                                      width: double.infinity,
                                      height: 50.0,
                                      textStyle: FlutterFlowTheme.of(context).bodyMedium,
                                      hintText: 'Wind...',
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
                                      margin: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                                      hidesUnderline: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Notes Field
                        Text(
                          'Notes (Optional)',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                letterSpacing: 0.0,
                              ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: TextFormField(
                            controller: _model.notesTextController,
                            focusNode: _model.notesFocusNode,
                            autofocus: false,
                            obscureText: false,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Any additional notes about your session...',
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

                        // Save Button
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 32.0),
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
                              onPressed: _model.isLoading ? null : _saveSession,
                              text: _model.isLoading ? 'Saving...' : 'Save Session',
                              icon: _model.isLoading
                                  ? null
                                  : Icon(
                                      Icons.check_circle_outline,
                                      size: 20.0,
                                    ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                color: Colors.transparent,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
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
