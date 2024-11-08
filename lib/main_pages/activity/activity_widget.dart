import '/backend/supabase/supabase.dart';
import '/bottom_sheet_selector/bottom_sheet_month_year_selector/bottom_sheet_month_year_selector_widget.dart';
import '/bottom_sheet_selector/select_user/select_user_widget.dart';
import '/components/bottom_sheet_transaction_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item/item_transaction/item_transaction_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'activity_model.dart';
export 'activity_model.dart';

class ActivityWidget extends StatefulWidget {
  const ActivityWidget({super.key});

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  late ActivityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ActivityModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.monthSetup =
          functions.extractDateDetails(getCurrentTimestamp, 'month');
      _model.yearSetup =
          functions.extractDateDetails(getCurrentTimestamp, 'year');
      safeSetState(() {});
      _model.transactionsMonth = await TransactionsTable().queryRows(
        queryFn: (q) => q
            .eq(
              'saison_id',
              FFAppState().saisonSetup,
            )
            .gte(
              'transaction_date',
              supaSerialize<DateTime>(functions.getBoundaryDate(
                  _model.monthSetup, _model.yearSetup, 'first')),
            )
            .eq(
              'statut',
              1.0,
            )
            .lte(
              'transaction_date',
              supaSerialize<DateTime>(functions.getBoundaryDate(
                  _model.monthSetup, _model.yearSetup, 'end')),
            )
            .order('transaction_date'),
      );
      _model.monthTransactions =
          _model.transactionsMonth!.toList().cast<TransactionsRow>();
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    child: Text(
                      'Activité',
                      style:
                          FlutterFlowTheme.of(context).headlineLarge.override(
                                fontFamily: 'Manrope',
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            useSafeArea: true,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: BottomSheetMonthYearSelectorWidget(
                                    monthActive: _model.monthSetup!,
                                    yearActive: _model.yearSetup!,
                                  ),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(
                              () => _model.buttomSheetFilterDate2 = value));

                          _model.monthSetup =
                              _model.buttomSheetFilterDate2?.month;
                          _model.yearSetup =
                              _model.buttomSheetFilterDate2?.year;
                          safeSetState(() {});
                          _model.transactionsMonth2 =
                              await TransactionsTable().queryRows(
                            queryFn: (q) => q
                                .eq(
                                  'saison_id',
                                  FFAppState().saisonSetup,
                                )
                                .gte(
                                  'transaction_date',
                                  supaSerialize<DateTime>(
                                      functions.getBoundaryDate(
                                          _model.monthSetup,
                                          _model.yearSetup,
                                          'first')),
                                )
                                .eq(
                                  'statut',
                                  1.0,
                                )
                                .lte(
                                  'transaction_date',
                                  supaSerialize<DateTime>(
                                      functions.getBoundaryDate(
                                          _model.monthSetup,
                                          _model.yearSetup,
                                          'end')),
                                )
                                .order('transaction_date'),
                          );
                          _model.monthTransactions = _model.transactionsMonth2!
                              .toList()
                              .cast<TransactionsRow>();
                          safeSetState(() {});
                          if ((_model.monthSetup == null) ||
                              (_model.yearSetup == null)) {
                            _model.monthSetup = functions.extractDateDetails(
                                getCurrentTimestamp, 'month');
                            _model.yearSetup = functions.extractDateDetails(
                                getCurrentTimestamp, 'year');
                            safeSetState(() {});
                          }

                          safeSetState(() {});
                        },
                        child: Container(
                          height: 36.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dateTimeFormat(
                                              "MMMM",
                                              functions.getBoundaryDate(
                                                  _model.monthSetup,
                                                  _model.yearSetup,
                                                  'first'),
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ) ==
                                            dateTimeFormat(
                                              "MMMM",
                                              getCurrentTimestamp,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            )
                                        ? 'Mois actuel'
                                        : dateTimeFormat(
                                            "MMMM",
                                            functions.getBoundaryDate(
                                                _model.monthSetup,
                                                _model.yearSetup,
                                                'first'),
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Manrope',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  FaIcon(
                                    FontAwesomeIcons.chevronDown,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 16.0,
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.9,
                                    child: const SelectUserWidget(),
                                  ),
                                ),
                              );
                            },
                          ).then((value) =>
                              safeSetState(() => _model.whoPlayer = value));

                          _model.transactionsMonth3 =
                              await TransactionsTable().queryRows(
                            queryFn: (q) => q
                                .eq(
                                  'saison_id',
                                  FFAppState().saisonSetup,
                                )
                                .gte(
                                  'transaction_date',
                                  supaSerialize<DateTime>(
                                      functions.getBoundaryDate(
                                          _model.monthSetup,
                                          _model.yearSetup,
                                          'first')),
                                )
                                .eq(
                                  'statut',
                                  1.0,
                                )
                                .lte(
                                  'transaction_date',
                                  supaSerialize<DateTime>(
                                      functions.getBoundaryDate(
                                          _model.monthSetup,
                                          _model.yearSetup,
                                          'end')),
                                )
                                .eq(
                                  'transaction_to',
                                  _model.whoPlayer?.id,
                                )
                                .order('transaction_date'),
                          );
                          _model.monthTransactions = _model.transactionsMonth3!
                              .toList()
                              .cast<TransactionsRow>();
                          _model.whoSetup = _model.whoPlayer;
                          safeSetState(() {});

                          safeSetState(() {});
                        },
                        child: Container(
                          height: 36.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      _model.whoSetup?.id == null ||
                                              _model.whoSetup?.id == ''
                                          ? 'Joueurs'
                                          : _model.whoSetup?.displayName,
                                      'Joueurs',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Manrope',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  FaIcon(
                                    FontAwesomeIcons.chevronDown,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 16.0,
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                        .divide(const SizedBox(width: 8.0))
                        .addToStart(const SizedBox(width: 16.0)),
                  ),
                ].divide(const SizedBox(height: 16.0)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: Builder(
                      builder: (context) {
                        final monthTransaction =
                            _model.monthTransactions.toList();
                        if (monthTransaction.isEmpty) {
                          return Center(
                            child: Image.asset(
                              'assets/images/blackbox-android-icon.png',
                              width: 50.0,
                              height: 50.0,
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            24.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: monthTransaction.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                          itemBuilder: (context, monthTransactionIndex) {
                            final monthTransactionItem =
                                monthTransaction[monthTransactionIndex];
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (functions.isNewDate(
                                    _model.monthTransactions.toList(),
                                    monthTransactionIndex))
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 20.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          valueOrDefault<String>(
                                            dateTimeFormat(
                                              "MMMMEEEEd",
                                              monthTransactionItem
                                                  .transactionDate,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            'Pas de date',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                fontFamily: 'Manrope',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          valueOrDefault<String>(
                                            functions.convertDotCommaEuro(
                                                functions.calculateNegativeSum(
                                                    _model.monthTransactions
                                                        .toList(),
                                                    monthTransactionItem
                                                        .transactionDate)!),
                                            '0 €',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .labelLarge
                                              .override(
                                                fontFamily: 'Manrope',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 18.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    HapticFeedback.selectionClick();
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () =>
                                              FocusScope.of(context).unfocus(),
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: BottomSheetTransactionWidget(
                                              emoji: valueOrDefault<String>(
                                                monthTransactionItem
                                                    .transactionImg,
                                                '❌',
                                              ),
                                              name: monthTransactionItem
                                                  .transactionName!,
                                              toName: monthTransactionItem
                                                  .transactionToName!,
                                              date: dateTimeFormat(
                                                "d MMMM • HH:mm",
                                                monthTransactionItem
                                                    .transactionDate,
                                                locale:
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                              quantity: monthTransactionItem
                                                  .transactionAmount!,
                                              byName: monthTransactionItem
                                                  .createdByName!,
                                              note: monthTransactionItem.note,
                                              value: monthTransactionItem
                                                  .transactionValue,
                                              id: monthTransactionItem.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() => _model
                                        .transactionChangeinActivity = value));

                                    if (_model.transactionChangeinActivity!) {
                                      _model.transactionsMonth4 =
                                          await TransactionsTable().queryRows(
                                        queryFn: (q) => q
                                            .eq(
                                              'saison_id',
                                              FFAppState().saisonSetup,
                                            )
                                            .gte(
                                              'transaction_date',
                                              supaSerialize<DateTime>(
                                                  functions.getBoundaryDate(
                                                      _model.monthSetup,
                                                      _model.yearSetup,
                                                      'first')),
                                            )
                                            .eq(
                                              'statut',
                                              1.0,
                                            )
                                            .lte(
                                              'transaction_date',
                                              supaSerialize<DateTime>(
                                                  functions.getBoundaryDate(
                                                      _model.monthSetup,
                                                      _model.yearSetup,
                                                      'end')),
                                            )
                                            .order('transaction_date'),
                                      );
                                      _model.monthTransactions = _model
                                          .transactionsMonth!
                                          .toList()
                                          .cast<TransactionsRow>();
                                      safeSetState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Transaction supprimée',
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              const Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .success,
                                        ),
                                      );
                                    }

                                    safeSetState(() {});
                                  },
                                  child: ItemTransactionWidget(
                                    key: Key(
                                        'Key24g_${monthTransactionIndex}_of_${monthTransaction.length}'),
                                    primary: valueOrDefault<String>(
                                      monthTransactionItem.transactionName,
                                      'Aucun titre associé',
                                    ),
                                    secondary: valueOrDefault<String>(
                                      monthTransactionItem.transactionValue
                                          .toString(),
                                      '0',
                                    ),
                                    supporting: valueOrDefault<String>(
                                      monthTransactionItem.transactionToName,
                                      'Aucun joueur trouvé',
                                    ),
                                    value: valueOrDefault<double>(
                                      monthTransactionItem.transactionValue,
                                      0.0,
                                    ),
                                    pending: monthTransactionItem.statut == 2.0,
                                    amount: monthTransactionItem
                                            .transactionAmount! >
                                        1.0,
                                    emoji: valueOrDefault<String>(
                                      monthTransactionItem.transactionImg,
                                      '❌',
                                    ),
                                    amountNumber:
                                        monthTransactionItem.transactionAmount!,
                                  ),
                                ),
                              ].divide(const SizedBox(height: 16.0)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ].divide(const SizedBox(height: 8.0)),
          ),
        ),
      ),
    );
  }
}
