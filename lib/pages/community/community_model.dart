import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'community_widget.dart' show CommunityWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CommunityModel extends FlutterFlowModel<CommunityWidget> {
  ///  State fields for stateful widgets in this page.

  Stream<List<UsersRow>>? containerSupabaseStream1;
  Stream<List<UsersRow>>? containerSupabaseStream2;
  Stream<List<DisciplinesRow>>? listViewSupabaseStream1;
  Stream<List<DisciplinesRow>>? listViewSupabaseStream2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
