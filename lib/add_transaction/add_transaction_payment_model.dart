import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_transaction_payment_widget.dart' show AddTransactionPaymentWidget;
import 'package:flutter/material.dart';

class AddTransactionPaymentModel
    extends FlutterFlowModel<AddTransactionPaymentWidget> {
  ///  Local state fields for this page.

  DateTime? date;

  String? targetUserName;

  String? targetUserImg;

  String? targetUserID;

  PenaltiesRow? payPenalitie;
  DateTime? datePicked;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  FocusNode? amountFocusNode;
  TextEditingController? amountTextController;
  String? Function(BuildContext, String?)? amountTextControllerValidator;

  UserTeamsRow? userChoose;

  TransactionsRow? insertedTransaction;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    amountFocusNode?.dispose();
    amountTextController?.dispose();
  }
}
