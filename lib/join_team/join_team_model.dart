import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'join_team_widget.dart' show JoinTeamWidget;
import 'package:flutter/material.dart';

class JoinTeamModel extends FlutterFlowModel<JoinTeamWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for teamCode widget.
  FocusNode? teamCodeFocusNode;
  TextEditingController? teamCodeTextController;
  String? Function(BuildContext, String?)? teamCodeTextControllerValidator;
  var teamCode = '';
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<TeamsRow>? teamInfo;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserTeamsRow>? userOutput;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserTeamsRow>? userteamID;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    teamCodeFocusNode?.dispose();
    teamCodeTextController?.dispose();
  }
}
