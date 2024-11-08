import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'activity_widget.dart' show ActivityWidget;
import 'package:flutter/material.dart';

class ActivityModel extends FlutterFlowModel<ActivityWidget> {
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

  // Stores action output result for [Backend Call - Query Rows] action in Activity widget.
  List<TransactionsRow>? transactionsMonth;
  // Stores action output result for [Bottom Sheet - BottomSheetMonthYearSelector] action in Container widget.
  BottomSheetFilterDateStruct? buttomSheetFilterDate2;
  // Stores action output result for [Backend Call - Query Rows] action in Container widget.
  List<TransactionsRow>? transactionsMonth2;
  // Stores action output result for [Bottom Sheet - selectUser] action in Container widget.
  UserTeamsRow? whoPlayer;
  // Stores action output result for [Backend Call - Query Rows] action in Container widget.
  List<TransactionsRow>? transactionsMonth3;
  // Stores action output result for [Bottom Sheet - BottomSheetTransaction] action in itemTransaction widget.
  bool? transactionChangeinActivity;
  // Stores action output result for [Backend Call - Query Rows] action in itemTransaction widget.
  List<TransactionsRow>? transactionsMonth4;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
