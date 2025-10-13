import '/flutter_flow/flutter_flow_util.dart';
import 'select_user_widget.dart' show SelectUserWidget;
import 'package:flutter/material.dart';

class SelectUserModel extends FlutterFlowModel<SelectUserWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;
  List<String> selectedUserIds = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
