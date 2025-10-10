import '/backend/supabase/supabase.dart';
import '/bottom_sheet_selector/select_user/select_user_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'add_transaction_payment_model.dart';
export 'add_transaction_payment_model.dart';

class AddTransactionPaymentWidget extends StatefulWidget {
  const AddTransactionPaymentWidget({super.key});

  @override
  State<AddTransactionPaymentWidget> createState() =>
      _AddTransactionPaymentWidgetState();
}

class _AddTransactionPaymentWidgetState
    extends State<AddTransactionPaymentWidget> {
  late AddTransactionPaymentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPenaltyLoading = true;
  String? _penaltyError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddTransactionPaymentModel());

    _model.amountTextController ??= TextEditingController();
    _model.amountFocusNode ??= FocusNode();
    _model.date = getCurrentTimestamp;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _fetchPayPenalitie();
      safeSetState(() {});
    });
  }

  Future<void> _fetchPayPenalitie() async {
    final penaltyRows = await PenaltiesTable().queryRows(
      queryFn: (q) => q
          .eq('penalitie_custom', 'pay')
          .eq('saison_id', FFAppState().saisonSetup),
    );

    if (!mounted) {
      return;
    }

    if (penaltyRows.isEmpty) {
      safeSetState(() {
        _isPenaltyLoading = false;
        _penaltyError =
            'Aucune pénalité de paiement configurée pour cette saison.';
      });
      return;
    }

    safeSetState(() {
      _model.payPenalitie = penaltyRows.first;
      _isPenaltyLoading = false;
    });
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.close,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Ajouter un paiement',
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  fontFamily: 'Manrope',
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: _isPenaltyLoading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : _model.payPenalitie == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 48.0,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              _penaltyError ?? 'Une erreur est survenue.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Manrope',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 8.0, 0.0),
                                    child: TextFormField(
                                      controller: _model.amountTextController,
                                      focusNode: _model.amountFocusNode,
                                      autofocus: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Manrope',
                                              fontSize: 44.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              lineHeight: 1.0,
                                            ),
                                        alignLabelWithHint: false,
                                        hintText: '0 €',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Manrope',
                                              fontSize: 44.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Manrope',
                                            fontSize: 44.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            lineHeight: 1.24,
                                          ),
                                      textAlign: TextAlign.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              signed: false, decimal: true),
                                      validator: _model
                                          .amountTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 1.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  FocusScope.of(context)
                                                      .unfocus(),
                                              child: Padding(
                                                padding:
                                                    MediaQuery.viewInsetsOf(
                                                        context),
                                                child: SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.9,
                                                  child:
                                                      const SelectUserWidget(),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(
                                            () => _model.userChoose = value));

                                        if (_model.userChoose != null) {
                                          _model.targetUserName =
                                              _model.userChoose?.displayName;
                                          _model.targetUserImg =
                                              _model.userChoose?.displayImg;
                                          _model.targetUserID =
                                              _model.userChoose?.id;
                                          safeSetState(() {});
                                        }

                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(8.0, 8.0, 16.0, 8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: Image.network(
                                                            valueOrDefault<
                                                                String>(
                                                              _model
                                                                  .targetUserImg,
                                                              'https://dnrinnvsfrbmrlmcxiij.supabase.co/storage/v1/object/public/default/avatar.jpg',
                                                            ),
                                                            width: 40.0,
                                                            height: 40.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            valueOrDefault<
                                                                String>(
                                                              _model
                                                                  .targetUserName,
                                                              'Choisis un joueur',
                                                            ),
                                                            maxLines: 1,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyLarge
                                                                .override(
                                                                  fontFamily:
                                                                      'Manrope',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ),
                                                        const FaIcon(
                                                          FontAwesomeIcons
                                                              .chevronDown,
                                                          color:
                                                              Color(0xFFBABABA),
                                                          size: 20.0,
                                                        ),
                                                      ].divide(const SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                  ].divide(const SizedBox(
                                                      height: 4.0)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 1.0, 0.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet<bool>(
                                            context: context,
                                            builder: (context) {
                                              final datePickedCupertinoTheme =
                                                  CupertinoTheme.of(context);
                                              return ScrollConfiguration(
                                                behavior:
                                                    const MaterialScrollBehavior()
                                                        .copyWith(
                                                  dragDevices: {
                                                    PointerDeviceKind.mouse,
                                                    PointerDeviceKind.touch,
                                                    PointerDeviceKind.stylus,
                                                    PointerDeviceKind.unknown
                                                  },
                                                ),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      3,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  child: CupertinoTheme(
                                                    data:
                                                        datePickedCupertinoTheme
                                                            .copyWith(
                                                      textTheme:
                                                          datePickedCupertinoTheme
                                                              .textTheme
                                                              .copyWith(
                                                        dateTimePickerTextStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'Manrope',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ),
                                                    child: CupertinoDatePicker(
                                                      mode:
                                                          CupertinoDatePickerMode
                                                              .date,
                                                      minimumDate:
                                                          DateTime(1900),
                                                      initialDateTime: _model
                                                              .date ??
                                                          getCurrentTimestamp,
                                                      maximumDate:
                                                          DateTime(2050),
                                                      showDayOfWeek: true,
                                                      onDateTimeChanged:
                                                          (newDateTime) =>
                                                              safeSetState(() {
                                                        _model.datePicked =
                                                            newDateTime;
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                        if (_model.datePicked != null) {
                                          _model.date = _model.datePicked;
                                          safeSetState(() {});
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(8.0, 8.0, 16.0, 8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Date',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily: 'Manrope',
                                                          color: const Color(
                                                              0xFFBABABA),
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    dateTimeFormat(
                                                      'EEEE d MMM y',
                                                      _model.date,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    ),
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily: 'Manrope',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ].divide(const SizedBox(
                                                    height: 4.0)),
                                              ),
                                              const Icon(
                                                Icons.calendar_today_rounded,
                                                color: Color(0xFFBABABA),
                                                size: 24.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(height: 16.0)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: (_model.targetUserID == null ||
                                              _model.targetUserID == '' ||
                                              (_model.amountTextController
                                                      .text ==
                                                  '') ||
                                              (_model.payPenalitie == null))
                                          ? null
                                          : () async {
                                              final scaffoldMessenger =
                                                  ScaffoldMessenger.of(context);
                                              final theme =
                                                  FlutterFlowTheme.of(context);
                                              final amountValue = functions
                                                  .convertCommaDot(_model
                                                      .amountTextController
                                                      .text);
                                              if (amountValue <= 0) {
                                                scaffoldMessenger
                                                    .clearSnackBars();
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Le montant doit être supérieur à 0.',
                                                      style: TextStyle(
                                                        color:
                                                            theme.primaryText,
                                                      ),
                                                    ),
                                                    duration: const Duration(
                                                        milliseconds: 2000),
                                                    backgroundColor:
                                                        theme.warning,
                                                  ),
                                                );
                                                return;
                                              }

                                              _model.insertedTransaction =
                                                  await TransactionsTable()
                                                      .insert({
                                                'transaction_date':
                                                    supaSerialize<DateTime>(
                                                        _model.date),
                                                'transaction_value':
                                                    amountValue,
                                                'created_by':
                                                    FFAppState().userSetup,
                                                'transaction_to':
                                                    _model.targetUserID,
                                                'penalitie_id':
                                                    _model.payPenalitie?.id,
                                                'saison_id':
                                                    FFAppState().saisonSetup,
                                                'transaction_amount': 1.0,
                                              });

                                              if (!mounted) {
                                                return;
                                              }

                                              safeSetState(() {
                                                _model.amountTextController
                                                    ?.clear();
                                              });
                                              _model.targetUserName = null;
                                              _model.targetUserImg = null;
                                              _model.targetUserID = null;
                                              _model.userChoose = null;
                                              safeSetState(() {});

                                              scaffoldMessenger
                                                  .clearSnackBars();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Transaction ajoutée',
                                                    style: TextStyle(
                                                      color: theme.primaryText,
                                                    ),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 2000),
                                                  backgroundColor:
                                                      theme.success,
                                                ),
                                              );
                                            },
                                      text: 'Ajouter',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 48.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24.0, 0.0, 24.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Manrope',
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        disabledColor: const Color(0x28000000),
                                        disabledTextColor:
                                            const Color(0x64000000),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
