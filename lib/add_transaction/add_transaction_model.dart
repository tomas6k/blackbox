import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'add_transaction_widget.dart' show AddTransactionWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddTransactionModel extends FlutterFlowModel<AddTransactionWidget> {
  ///  Local state fields for this page.

  DateTime? date;

  double transactionValue = 0.0;

  String? targetUserName;

  String? targetUserImg;

  String? targetUserID;

  List<UserTeamsRow> selectedUsers = [];
  List<String> get selectedUserIds => selectedUsers
      .map((u) => u.id)
      .whereType<String>()
      .toSet()
      .toList();

  String? targetPenalitieName;

  String? targetPenalitieImg;

  String? targetPenalitieID;

  double targetPenalitieValue = 0.0;

  String transactionType = 'default';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for transactionVariable widget.
  FocusNode? transactionVariableFocusNode;
  TextEditingController? transactionVariableTextController;
  String? Function(BuildContext, String?)?
      transactionVariableTextControllerValidator;
  // State field(s) for quantity widget.
  int? quantityValue;
  // Stores action output result for [Custom Action - calculateValue] action in quantity widget.
  double? calculatedValue3;
  // State field(s) for type widget.
  FormFieldController<List<String>>? typeValueController;
  List<String>? get typeValues => typeValueController?.value;
  set typeValues(List<String>? val) => typeValueController?.value = val;
  // Stores action output result for [Custom Action - calculateValue] action in type widget.
  double? calculatedValue2;
  // Stores action output result for [Bottom Sheet - selectUser] action in Container widget.
  UserTeamsRow? userChoose;
  DateTime? datePicked;
  // Stores action output result for [Bottom Sheet - selectPenalitie] action in Container widget.
  PenaltiesRow? penalitieChoose;
  // Stores action output result for [Custom Action - calculateValue] action in Container widget.
  double? calculatedValue;
  // State field(s) for noteField widget.
  FocusNode? noteFieldFocusNode;
  TextEditingController? noteFieldTextController;
  String? Function(BuildContext, String?)? noteFieldTextControllerValidator;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  TransactionsRow? message;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  TransactionsRow? message2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    transactionVariableFocusNode?.dispose();
    transactionVariableTextController?.dispose();

    noteFieldFocusNode?.dispose();
    noteFieldTextController?.dispose();
  }
}
