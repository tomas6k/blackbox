import '/backend/supabase/supabase.dart';
import '/components/button_header_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item/item_transaction/item_transaction_widget.dart';
import 'dart:async';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for buttonHeader component.
  late ButtonHeaderModel buttonHeaderModel1;
  // Stores action output result for [Backend Call - Query Rows] action in buttonHeader widget.
  List<TransactionsRow>? pendingTransaction;
  // Model for buttonHeader component.
  late ButtonHeaderModel buttonHeaderModel2;
  // Model for buttonHeader component.
  late ButtonHeaderModel buttonHeaderModel3;
  // Model for buttonHeader component.
  late ButtonHeaderModel buttonHeaderModel4;
  bool apiRequestCompleted1 = false;
  String? apiRequestLastUniqueKey1;
  bool requestCompleted1 = false;
  String? requestLastUniqueKey1;
  bool requestCompleted2 = false;
  String? requestLastUniqueKey2;
  bool apiRequestCompleted2 = false;
  String? apiRequestLastUniqueKey2;
  bool requestCompleted3 = false;
  String? requestLastUniqueKey3;
  // Model for itemTransaction component.
  late ItemTransactionModel itemTransactionModel1;
  // Stores action output result for [Bottom Sheet - BottomSheetTransaction] action in itemTransaction widget.
  bool? transactionChange;

  @override
  void initState(BuildContext context) {
    buttonHeaderModel1 = createModel(context, () => ButtonHeaderModel());
    buttonHeaderModel2 = createModel(context, () => ButtonHeaderModel());
    buttonHeaderModel3 = createModel(context, () => ButtonHeaderModel());
    buttonHeaderModel4 = createModel(context, () => ButtonHeaderModel());
    itemTransactionModel1 = createModel(context, () => ItemTransactionModel());
  }

  @override
  void dispose() {
    buttonHeaderModel1.dispose();
    buttonHeaderModel2.dispose();
    buttonHeaderModel3.dispose();
    buttonHeaderModel4.dispose();
    itemTransactionModel1.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleted1;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleted1;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleted2;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForApiRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleted2;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted3({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleted3;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
