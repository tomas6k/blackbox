import '/backend/schema/structs/index.dart';
import '/components/month_selector_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bottom_sheet_month_year_selector_model.dart';
export 'bottom_sheet_month_year_selector_model.dart';

class BottomSheetMonthYearSelectorWidget extends StatefulWidget {
  const BottomSheetMonthYearSelectorWidget({
    super.key,
    int? monthActive,
    int? yearActive,
  })  : monthActive = monthActive ?? 1,
        yearActive = yearActive ?? 2025;

  final int monthActive;
  final int yearActive;

  @override
  State<BottomSheetMonthYearSelectorWidget> createState() =>
      _BottomSheetMonthYearSelectorWidgetState();
}

class _BottomSheetMonthYearSelectorWidgetState
    extends State<BottomSheetMonthYearSelectorWidget> {
  late BottomSheetMonthYearSelectorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomSheetMonthYearSelectorModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.monthActive = widget.monthActive;
      _model.yearActive = widget.yearActive;
      _model.listMonths = functions
          .generateMonthsWithFuture(widget.yearActive)
          .toList()
          .cast<dynamic>();
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 56.0,
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 100.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        decoration: const BoxDecoration(),
                        child: Align(
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            'Annuler',
                            style: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Manrope',
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Choisis une date',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.pop(
                              context,
                              BottomSheetFilterDateStruct(
                                year: _model.yearActive,
                                month: _model.monthActive,
                              ));
                        },
                        child: Container(
                          width: 100.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          decoration: const BoxDecoration(),
                        ),
                      ),
                    ].divide(const SizedBox(width: 8.0)),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Builder(
                builder: (context) {
                  final listYear = functions.generateLastYears(10).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(listYear.length, (listYearIndex) {
                        final listYearItem = listYear[listYearIndex];
                        return Opacity(
                          opacity: functions.convertToInt(getJsonField(
                                    listYearItem,
                                    r'''$..[0]''',
                                  ).toString()) ==
                                  _model.yearActive
                              ? 1.0
                              : 0.4,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.yearActive =
                                  functions.convertToInt(getJsonField(
                                listYearItem,
                                r'''$..[0]''',
                              ).toString())!;
                              safeSetState(() {});
                              _model.listMonths = functions
                                  .generateMonthsWithFuture(_model.yearActive)
                                  .toList()
                                  .cast<dynamic>();
                              safeSetState(() {});
                            },
                            child: Text(
                              valueOrDefault<String>(
                                getJsonField(
                                  listYearItem,
                                  r'''$..[0]''',
                                )?.toString(),
                                '2024',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        );
                      })
                          .divide(const SizedBox(width: 16.0))
                          .addToStart(const SizedBox(width: 16.0))
                          .addToEnd(const SizedBox(width: 16.0)),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: Builder(
                  builder: (context) {
                    final listMonth = _model.listMonths.toList();

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 2.0,
                      ),
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: listMonth.length,
                      itemBuilder: (context, listMonthIndex) {
                        final listMonthItem = listMonth[listMonthIndex];
                        return Visibility(
                          visible: functions.convertToBool(getJsonField(
                                listMonthItem,
                                r'''$..[3]''',
                              ).toString()) ==
                              false,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.monthActive =
                                  functions.convertToInt(getJsonField(
                                listMonthItem,
                                r'''$..[1]''',
                              ).toString())!;
                              safeSetState(() {});
                              Navigator.pop(
                                  context,
                                  BottomSheetFilterDateStruct(
                                    year: _model.yearActive,
                                    month: _model.monthActive,
                                  ));
                            },
                            child: MonthSelectorWidget(
                              key: Key(
                                  'Keyukf_${listMonthIndex}_of_${listMonth.length}'),
                              monthText: valueOrDefault<String>(
                                getJsonField(
                                  listMonthItem,
                                  r'''$..[0]''',
                                )?.toString(),
                                'Janvier',
                              ),
                              monthNumber: getJsonField(
                                listMonthItem,
                                r'''$..[1]''',
                              ),
                              active: functions.convertToInt(getJsonField(
                                    listMonthItem,
                                    r'''$..[1]''',
                                  ).toString()) ==
                                  _model.monthActive,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ].divide(const SizedBox(height: 24.0)).addToEnd(const SizedBox(height: 48.0)),
        ),
      ),
    );
  }
}
