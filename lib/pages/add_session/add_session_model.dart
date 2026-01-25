import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'add_session_widget.dart' show AddSessionWidget;
import 'package:flutter/material.dart';

class AddSessionModel extends FlutterFlowModel<AddSessionWidget> {
  // State fields
  final formKey = GlobalKey<FormState>();

  // Discipline dropdown
  String? disciplineValue;
  FormFieldController<String>? disciplineValueController;

  // Firearm text field
  FocusNode? firearmFocusNode;
  TextEditingController? firearmTextController;
  String? Function(BuildContext, String?)? firearmTextControllerValidator;

  // Ammo type text field
  FocusNode? ammoTypeFocusNode;
  TextEditingController? ammoTypeTextController;
  String? Function(BuildContext, String?)? ammoTypeTextControllerValidator;

  // Distance text field
  FocusNode? distanceFocusNode;
  TextEditingController? distanceTextController;
  String? Function(BuildContext, String?)? distanceTextControllerValidator;

  // Total shots text field
  FocusNode? totalShotsFocusNode;
  TextEditingController? totalShotsTextController;
  String? Function(BuildContext, String?)? totalShotsTextControllerValidator;

  // Hits text field
  FocusNode? hitsFocusNode;
  TextEditingController? hitsTextController;
  String? Function(BuildContext, String?)? hitsTextControllerValidator;

  // Notes text field
  FocusNode? notesFocusNode;
  TextEditingController? notesTextController;
  String? Function(BuildContext, String?)? notesTextControllerValidator;

  // Weather conditions dropdown
  String? weatherValue;
  FormFieldController<String>? weatherValueController;

  // Wind conditions dropdown
  String? windValue;
  FormFieldController<String>? windValueController;

  // Loading state
  bool isLoading = false;

  @override
  void initState(BuildContext context) {
    firearmTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Firearm is required';
      }
      return null;
    };

    ammoTypeTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Ammo type is required';
      }
      return null;
    };

    distanceTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Distance is required';
      }
      if (int.tryParse(val) == null) {
        return 'Please enter a valid number';
      }
      return null;
    };

    totalShotsTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Total shots is required';
      }
      if (int.tryParse(val) == null || int.parse(val) <= 0) {
        return 'Please enter a valid number greater than 0';
      }
      return null;
    };

    hitsTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Hits is required';
      }
      final hits = int.tryParse(val);
      if (hits == null || hits < 0) {
        return 'Please enter a valid number';
      }
      final totalShots = int.tryParse(totalShotsTextController?.text ?? '0') ?? 0;
      if (hits > totalShots) {
        return 'Hits cannot exceed total shots';
      }
      return null;
    };
  }

  @override
  void dispose() {
    firearmFocusNode?.dispose();
    firearmTextController?.dispose();

    ammoTypeFocusNode?.dispose();
    ammoTypeTextController?.dispose();

    distanceFocusNode?.dispose();
    distanceTextController?.dispose();

    totalShotsFocusNode?.dispose();
    totalShotsTextController?.dispose();

    hitsFocusNode?.dispose();
    hitsTextController?.dispose();

    notesFocusNode?.dispose();
    notesTextController?.dispose();
  }

  /// Calculate accuracy percentage
  double get accuracy {
    final totalShots = int.tryParse(totalShotsTextController?.text ?? '0') ?? 0;
    final hits = int.tryParse(hitsTextController?.text ?? '0') ?? 0;
    if (totalShots <= 0) return 0;
    return (hits / totalShots) * 100;
  }
}
