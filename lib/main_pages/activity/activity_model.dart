import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/services/transactions_feed_controller.dart';
import 'activity_widget.dart' show ActivityWidget;
import 'package:flutter/material.dart';

class ActivityModel extends FlutterFlowModel<ActivityWidget> {
  ///  Local state fields for this page.

  late TransactionsFeedController transactionsFeedController;

  List<TransactionsRow> get monthTransactions =>
      transactionsFeedController.transactions;
  set monthTransactions(List<TransactionsRow> value) =>
      transactionsFeedController.transactions = value;
  void addToMonthTransactions(TransactionsRow item) =>
      transactionsFeedController.transactions.add(item);
  void removeFromMonthTransactions(TransactionsRow item) =>
      transactionsFeedController.transactions.remove(item);
  void removeAtIndexFromMonthTransactions(int index) =>
      transactionsFeedController.transactions.removeAt(index);
  void insertAtIndexInMonthTransactions(int index, TransactionsRow item) =>
      transactionsFeedController.transactions.insert(index, item);
  void updateMonthTransactionsAtIndex(
      int index, Function(TransactionsRow) updateFn) {
    monthTransactions[index] =
        updateFn(transactionsFeedController.transactions[index]);
  }

  int? get monthSetup => transactionsFeedController.month;
  set monthSetup(int? value) => transactionsFeedController.month = value;

  int? get yearSetup => transactionsFeedController.year;
  set yearSetup(int? value) => transactionsFeedController.year = value;

  UserTeamsRow? get whoSetup => transactionsFeedController.selectedPlayer;
  set whoSetup(UserTeamsRow? value) =>
      transactionsFeedController.selectedPlayer = value;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Bottom Sheet - BottomSheetMonthYearSelector] action in Container widget.
  BottomSheetFilterDateStruct? buttomSheetFilterDate2;
  // Stores action output result for [Bottom Sheet - selectUser] action in Container widget.
  UserTeamsRow? whoPlayer;
  // Stores action output result for [Bottom Sheet - BottomSheetTransaction] action in itemTransaction widget.
  bool? transactionChangeinActivity;

  @override
  void initState(BuildContext context) {
    transactionsFeedController = TransactionsFeedController();
  }

  @override
  void dispose() {}
}
