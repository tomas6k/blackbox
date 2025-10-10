import '/backend/supabase/supabase.dart';
import '/bottom_sheet_selector/select_penalitie/select_penalitie_widget.dart';
import '/bottom_sheet_selector/select_user/select_user_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_count_controller.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'add_transaction_model.dart';
export 'add_transaction_model.dart';

class AddTransactionWidget extends StatefulWidget {
  const AddTransactionWidget({super.key});

  @override
  State<AddTransactionWidget> createState() => _AddTransactionWidgetState();
}

class _AddTransactionWidgetState extends State<AddTransactionWidget> {
  late AddTransactionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddTransactionModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.date = getCurrentTimestamp;
      safeSetState(() {});
    });

    _model.transactionVariableTextController ??= TextEditingController();
    _model.transactionVariableFocusNode ??= FocusNode();

    _model.noteFieldTextController ??= TextEditingController();
    _model.noteFieldFocusNode ??= FocusNode();

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
            'Ajouter une transaction',
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  fontFamily: 'Manrope',
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          actions: [
            if ((FFAppState().roleSetup == 'admin') ||
                (FFAppState().roleSetup == 'owner'))
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 8.0,
                  borderWidth: 0.0,
                  buttonSize: 40.0,
                  icon: Icon(
                    Icons.payments,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    context.pushNamed('addTransactionPayment');
                  },
                ),
              ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
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
                        if (_model.transactionType == 'custom')
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: TextFormField(
                              controller:
                                  _model.transactionVariableTextController,
                              focusNode: _model.transactionVariableFocusNode,
                              onChanged: (_) => EasyDebounce.debounce(
                                '_model.transactionVariableTextController',
                                const Duration(milliseconds: 1),
                                () async {
                                  await actions.forceNegativeValueAction(
                                    _model
                                        .transactionVariableTextController.text,
                                  );
                                },
                              ),
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
                                      signed: true, decimal: true),
                              validator: _model
                                  .transactionVariableTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        if (_model.transactionType == 'default')
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              valueOrDefault<String>(
                                '${valueOrDefault<String>(
                                  _model.transactionValue.toString(),
                                  '0',
                                )} €',
                                '0 €',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    fontFamily: 'Manrope',
                                    fontSize: 44.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 120.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                shape: BoxShape.rectangle,
                              ),
                              child: FlutterFlowCountController(
                                decrementIconBuilder: (enabled) => Icon(
                                  Icons.remove_rounded,
                                  color: enabled
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryText
                                      : FlutterFlowTheme.of(context).alternate,
                                  size: 24.0,
                                ),
                                incrementIconBuilder: (enabled) => Icon(
                                  Icons.add_rounded,
                                  color: enabled
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context).alternate,
                                  size: 24.0,
                                ),
                                countBuilder: (count) => Text(
                                  count.toString(),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                count: _model.quantityValue ??= 1,
                                updateCount: (count) async {
                                  safeSetState(
                                      () => _model.quantityValue = count);
                                  _model.calculatedValue3 =
                                      await actions.calculateValue(
                                    _model.typeValues!.toList(),
                                    _model.penalitieChoose!.penalitieValue,
                                    _model.quantityValue!,
                                  );
                                  _model.transactionValue =
                                      _model.calculatedValue3!;
                                  safeSetState(() {});

                                  safeSetState(() {});
                                },
                                stepSize: 1,
                                minimum: 1,
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 0.0, 0.0),
                              child: FlutterFlowChoiceChips(
                                options: const [
                                  ChipData('Gameday'),
                                  ChipData('BlackWeek')
                                ],
                                onChanged: (val) async {
                                  safeSetState(() => _model.typeValues = val);
                                  _model.calculatedValue2 =
                                      await actions.calculateValue(
                                    _model.typeValues!.toList(),
                                    _model.penalitieChoose!.penalitieValue,
                                    _model.quantityValue!,
                                  );
                                  _model.transactionValue =
                                      _model.calculatedValue2!;
                                  safeSetState(() {});

                                  safeSetState(() {});
                                },
                                selectedChipStyle: ChipStyle(
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  iconColor:
                                      FlutterFlowTheme.of(context).primary,
                                  iconSize: 0.0,
                                  elevation: 0.0,
                                  borderColor:
                                      FlutterFlowTheme.of(context).primary,
                                  borderWidth: 2.0,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                unselectedChipStyle: ChipStyle(
                                  backgroundColor: Colors.white,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  iconColor: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  iconSize: 0.0,
                                  elevation: 0.0,
                                  borderColor: const Color(0xFFF1F1FB),
                                  borderWidth: 2.0,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                chipSpacing: 8.0,
                                rowSpacing: 12.0,
                                multiselect: true,
                                initialized: _model.typeValues != null,
                                alignment: WrapAlignment.start,
                                controller: _model.typeValueController ??=
                                    FormFieldController<List<String>>(
                                  [],
                                ),
                                wrapped: false,
                              ),
                            ),
                          ],
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
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.9,
                                      child: const SelectUserWidget(),
                                    ),
                                  ),
                                );
                              },
                            ).then((value) =>
                                safeSetState(() => _model.userChoose = value));

                            if (_model.userChoose != null) {
                              _model.targetUserName =
                                  _model.userChoose?.displayName;
                              _model.targetUserImg =
                                  _model.userChoose?.displayImg;
                              _model.targetUserID = _model.userChoose?.id;
                              safeSetState(() {});
                            }

                            safeSetState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 8.0, 16.0, 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                valueOrDefault<String>(
                                                  _model.targetUserImg,
                                                  'https://dnrinnvsfrbmrlmcxiij.supabase.co/storage/v1/object/public/default/avatar.jpg',
                                                ),
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                valueOrDefault<String>(
                                                  _model.targetUserName,
                                                  'Choisis un joueur',
                                                ),
                                                maxLines: 1,
                                                style:
                                                    FlutterFlowTheme.of(context)
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
                                            ),
                                            const FaIcon(
                                              FontAwesomeIcons.chevronDown,
                                              color: Color(0xFFBABABA),
                                              size: 20.0,
                                            ),
                                          ].divide(const SizedBox(width: 12.0)),
                                        ),
                                      ].divide(const SizedBox(height: 4.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
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
                                      behavior: const MaterialScrollBehavior()
                                          .copyWith(
                                        dragDevices: {
                                          PointerDeviceKind.mouse,
                                          PointerDeviceKind.touch,
                                          PointerDeviceKind.stylus,
                                          PointerDeviceKind.unknown
                                        },
                                      ),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        child: CupertinoTheme(
                                          data:
                                              datePickedCupertinoTheme.copyWith(
                                            textTheme: datePickedCupertinoTheme
                                                .textTheme
                                                .copyWith(
                                              dateTimePickerTextStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineMedium
                                                      .override(
                                                        fontFamily: 'Manrope',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ),
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.date,
                                            minimumDate: DateTime(1900),
                                            initialDateTime:
                                                getCurrentTimestamp,
                                            maximumDate: DateTime(2050),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            use24hFormat: false,
                                            onDateTimeChanged: (newDateTime) =>
                                                safeSetState(() {
                                              _model.datePicked = newDateTime;
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
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 8.0, 16.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Manrope',
                                                  color:
                                                      const Color(0xFFBABABA),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            dateTimeFormat(
                                              "yMMMd",
                                              _model.date,
                                              locale:
                                                  FFLocalizations.of(context)
                                                      .languageCode,
                                            ),
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily: 'Manrope',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ].divide(const SizedBox(height: 4.0)),
                                      ),
                                    ),
                                    const FaIcon(
                                      FontAwesomeIcons.calendar,
                                      color: Color(0xFFBABABA),
                                      size: 24.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
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
                                        FocusScope.of(context).unfocus(),
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.9,
                                        child: const SelectPenalitieWidget(),
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(
                                  () => _model.penalitieChoose = value));

                              if (_model.penalitieChoose != null) {
                                _model.targetPenalitieName =
                                    _model.penalitieChoose?.penalitieName;
                                _model.targetPenalitieImg =
                                    _model.penalitieChoose?.penalitieImg;
                                _model.targetPenalitieID =
                                    _model.penalitieChoose?.id;
                                _model.targetPenalitieValue =
                                    _model.penalitieChoose!.penalitieValue;
                                _model.transactionType =
                                    _model.penalitieChoose!.penalitieCustom;
                                safeSetState(() {});
                                _model.calculatedValue =
                                    await actions.calculateValue(
                                  _model.typeValues!.toList(),
                                  valueOrDefault<double>(
                                    _model.penalitieChoose?.penalitieValue,
                                    0.0,
                                  ),
                                  _model.quantityValue!,
                                );
                                _model.transactionValue =
                                    _model.calculatedValue!;
                                safeSetState(() {});
                              }

                              safeSetState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 8.0, 16.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Motif',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Manrope',
                                                  color:
                                                      const Color(0xFFBABABA),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  _model.targetPenalitieImg,
                                                  '👉',
                                                ),
                                                maxLines: 1,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily: 'Manrope',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                              ),
                                              Text(
                                                valueOrDefault<String>(
                                                  _model.targetPenalitieName,
                                                  'Choisis la pénalité',
                                                ),
                                                maxLines: 1,
                                                style:
                                                    FlutterFlowTheme.of(context)
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
                                            ].divide(
                                                const SizedBox(width: 4.0)),
                                          ),
                                        ].divide(const SizedBox(height: 4.0)),
                                      ),
                                    ),
                                    const FaIcon(
                                      FontAwesomeIcons.chevronDown,
                                      color: Color(0xFFBABABA),
                                      size: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _model.noteFieldTextController,
                          focusNode: _model.noteFieldFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: false,
                            labelText: 'Note',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color: const Color(0xFFBABABA),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0x00000000),
                                width: 0.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 0.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 0.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 0.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Manrope',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          minLines: 1,
                          validator: _model.noteFieldTextControllerValidator
                              .asValidator(context),
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
                        if (_model.transactionType == 'default')
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: ((_model.targetUserID == null ||
                                          _model.targetUserID == '') ||
                                      (_model.targetPenalitieID == null ||
                                          _model.targetPenalitieID == ''))
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      final theme =
                                          FlutterFlowTheme.of(context);

                                      _model.message =
                                          await TransactionsTable().insert({
                                        'transaction_date':
                                            supaSerialize<DateTime>(
                                                _model.date),
                                        'transaction_value':
                                            _model.transactionValue,
                                        'created_by': FFAppState().userSetup,
                                        'transaction_to': _model.targetUserID,
                                        'penalitie_id':
                                            _model.targetPenalitieID,
                                        'saison_id': FFAppState().saisonSetup,
                                        'note':
                                            _model.noteFieldTextController.text,
                                        'gameday': functions.getBoolValue(
                                            'Gameday',
                                            _model.typeValues?.toList()),
                                        'blackweek': functions.getBoolValue(
                                            'BlackWeek',
                                            _model.typeValues?.toList()),
                                        'transaction_amount':
                                            _model.quantityValue?.toDouble(),
                                      });
                                      if (!mounted) {
                                        return;
                                      }
                                      safeSetState(() {
                                        _model.typeValueController?.reset();
                                      });
                                      safeSetState(() {
                                        _model.transactionVariableTextController
                                            ?.clear();
                                        _model.noteFieldTextController?.clear();
                                      });
                                      safeSetState(() {
                                        _model.quantityValue = 1;
                                      });
                                      _model.transactionValue = 0.0;
                                      _model.targetPenalitieName = null;
                                      _model.targetPenalitieImg = null;
                                      _model.targetPenalitieID = null;
                                      _model.targetPenalitieValue = 0.0;
                                      safeSetState(() {});
                                      scaffoldMessenger.clearSnackBars();
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
                                          backgroundColor: theme.success,
                                        ),
                                      );

                                      safeSetState(() {});
                                    },
                              text: 'Ajouter',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
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
                                borderRadius: BorderRadius.circular(8.0),
                                disabledColor: const Color(0x28000000),
                                disabledTextColor: const Color(0x64000000),
                              ),
                            ),
                          ),
                        if (_model.transactionType == 'custom')
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: ((_model.targetUserID == null ||
                                          _model.targetUserID == '') ||
                                      ((_model.transactionVariableTextController
                                                  .text ==
                                              '') ||
                                          (_model.transactionVariableTextController
                                                  .text ==
                                              '0')))
                                  ? null
                                  : () async {
                                      final scaffoldMessenger =
                                          ScaffoldMessenger.of(context);
                                      final theme =
                                          FlutterFlowTheme.of(context);

                                      _model.message2 =
                                          await TransactionsTable().insert({
                                        'transaction_date':
                                            supaSerialize<DateTime>(
                                                _model.date),
                                        'transaction_value': functions
                                            .convertCommaDotNegative(_model
                                                .transactionVariableTextController
                                                .text),
                                        'created_by': FFAppState().userSetup,
                                        'transaction_to': _model.targetUserID,
                                        'penalitie_id':
                                            _model.targetPenalitieID,
                                        'saison_id': FFAppState().saisonSetup,
                                        'note':
                                            _model.noteFieldTextController.text,
                                        'gameday': functions.getBoolValue(
                                            'Gameday',
                                            _model.typeValues?.toList()),
                                        'blackweek': functions.getBoolValue(
                                            'BlackWeek',
                                            _model.typeValues?.toList()),
                                        'transaction_amount':
                                            _model.quantityValue?.toDouble(),
                                      });
                                      if (!mounted) {
                                        return;
                                      }
                                      safeSetState(() {
                                        _model.typeValueController?.reset();
                                      });
                                      safeSetState(() {
                                        _model.transactionVariableTextController
                                            ?.clear();
                                        _model.noteFieldTextController?.clear();
                                      });
                                      safeSetState(() {
                                        _model.quantityValue = 1;
                                      });
                                      _model.transactionValue = 0.0;
                                      _model.targetPenalitieName = null;
                                      _model.targetPenalitieImg = null;
                                      _model.targetPenalitieID = null;
                                      _model.targetPenalitieValue = 0.0;
                                      safeSetState(() {});
                                      scaffoldMessenger.clearSnackBars();
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
                                          backgroundColor: theme.success,
                                        ),
                                      );

                                      safeSetState(() {});
                                    },
                              text: 'Ajouter',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 0.0, 24.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
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
                                borderRadius: BorderRadius.circular(8.0),
                                disabledColor: const Color(0x28000000),
                                disabledTextColor: const Color(0x64000000),
                              ),
                            ),
                          ),
                      ].divide(const SizedBox(width: 16.0)),
                    ),
                  ),
                ].divide(const SizedBox(height: 16.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
