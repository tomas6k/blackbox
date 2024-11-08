import '/flutter_flow/flutter_flow_util.dart';
import 'select_penalitie_widget.dart' show SelectPenalitieWidget;
import 'package:flutter/material.dart';

class SelectPenalitieModel extends FlutterFlowModel<SelectPenalitieWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for search widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? Function(BuildContext, String?)? searchTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
