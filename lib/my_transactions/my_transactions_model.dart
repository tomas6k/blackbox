import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'my_transactions_widget.dart' show MyTransactionsWidget;
import 'package:flutter/material.dart';

class MyTransactionsModel extends FlutterFlowModel<MyTransactionsWidget> {
  ///  Local state fields for this page.

  List<TransactionsRow> monthTransactions = [];
  void addToMonthTransactions(TransactionsRow item) =>
      monthTransactions.add(item);
  void removeFromMonthTransactions(TransactionsRow item) =>
      monthTransactions.remove(item);
  void removeAtIndexFromMonthTransactions(int index) =>
      monthTransactions.removeAt(index);
  void insertAtIndexInMonthTransactions(int index, TransactionsRow item) =>
      monthTransactions.insert(index, item);
  void updateMonthTransactionsAtIndex(
          int index, Function(TransactionsRow) updateFn) =>
      monthTransactions[index] = updateFn(monthTransactions[index]);

  int? monthSetup;

  int? yearSetup;

  UserTeamsRow? whoSetup;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Bottom Sheet - BottomSheetMonthYearSelector] action in Container widget.
  BottomSheetFilterDateStruct? buttomSheetFilterDate2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
