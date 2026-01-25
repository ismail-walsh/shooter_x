import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'edit_profile_widget.dart' show EditProfileWidget;
import 'package:flutter/material.dart';

class EditProfileModel extends FlutterFlowModel<EditProfileWidget> {
  // State fields
  final formKey = GlobalKey<FormState>();

  // Username text field
  FocusNode? usernameFocusNode;
  TextEditingController? usernameTextController;
  String? Function(BuildContext, String?)? usernameTextControllerValidator;

  // Bio text field
  FocusNode? bioFocusNode;
  TextEditingController? bioTextController;
  String? Function(BuildContext, String?)? bioTextControllerValidator;

  // Preferred discipline dropdown
  String? disciplineValue;
  FormFieldController<String>? disciplineValueController;

  // Loading state
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState(BuildContext context) {
    usernameTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Username is required';
      }
      if (val.length < 3) {
        return 'Username must be at least 3 characters';
      }
      return null;
    };
  }

  @override
  void dispose() {
    usernameFocusNode?.dispose();
    usernameTextController?.dispose();

    bioFocusNode?.dispose();
    bioTextController?.dispose();
  }
}
