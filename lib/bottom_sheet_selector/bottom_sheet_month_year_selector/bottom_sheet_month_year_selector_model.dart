import '/flutter_flow/flutter_flow_util.dart';
import 'bottom_sheet_month_year_selector_widget.dart'
    show BottomSheetMonthYearSelectorWidget;
import 'package:flutter/material.dart';

class BottomSheetMonthYearSelectorModel
    extends FlutterFlowModel<BottomSheetMonthYearSelectorWidget> {
  ///  Local state fields for this component.

  int monthActive = 1;

  int yearActive = 2025;

  List<dynamic> listMonths = [];
  void addToListMonths(dynamic item) => listMonths.add(item);
  void removeFromListMonths(dynamic item) => listMonths.remove(item);
  void removeAtIndexFromListMonths(int index) => listMonths.removeAt(index);
  void insertAtIndexInListMonths(int index, dynamic item) =>
      listMonths.insert(index, item);
  void updateListMonthsAtIndex(int index, Function(dynamic) updateFn) =>
      listMonths[index] = updateFn(listMonths[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
