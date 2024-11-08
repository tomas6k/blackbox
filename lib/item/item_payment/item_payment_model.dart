import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'item_payment_widget.dart' show ItemPaymentWidget;
import 'package:flutter/material.dart';

class ItemPaymentModel extends FlutterFlowModel<ItemPaymentWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Update Row(s)] action in IconButton widget.
  List<TransactionsRow>? validatedPayment;
  // Stores action output result for [Backend Call - Delete Row(s)] action in IconButton widget.
  List<TransactionsRow>? deletedPayment;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
