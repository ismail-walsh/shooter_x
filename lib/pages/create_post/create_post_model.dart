import '/flutter_flow/flutter_flow_util.dart';
import 'create_post_widget.dart' show CreatePostWidget;
import 'package:flutter/material.dart';

class CreatePostModel extends FlutterFlowModel<CreatePostWidget> {
  // State fields
  final formKey = GlobalKey<FormState>();

  // Content text field
  FocusNode? contentFocusNode;
  TextEditingController? contentTextController;
  String? Function(BuildContext, String?)? contentTextControllerValidator;

  // Loading state
  bool isLoading = false;

  @override
  void initState(BuildContext context) {
    contentTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Post content is required';
      }
      if (val.length < 3) {
        return 'Post must be at least 3 characters';
      }
      return null;
    };
  }

  @override
  void dispose() {
    contentFocusNode?.dispose();
    contentTextController?.dispose();
  }
}
