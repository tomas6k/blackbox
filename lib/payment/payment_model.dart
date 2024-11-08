import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'payment_widget.dart' show PaymentWidget;
import 'package:flutter/material.dart';

class PaymentModel extends FlutterFlowModel<PaymentWidget> {
  ///  Local state fields for this page.

  double soldFuture = 0.0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for paiment widget.
  FocusNode? paimentFocusNode;
  TextEditingController? paimentTextController;
  String? Function(BuildContext, String?)? paimentTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Payer widget.
  List<PenaltiesRow>? penalitiePay;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    paimentFocusNode?.dispose();
    paimentTextController?.dispose();
  }
}
