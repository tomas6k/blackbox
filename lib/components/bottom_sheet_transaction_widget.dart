import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'bottom_sheet_transaction_model.dart';
export 'bottom_sheet_transaction_model.dart';

class BottomSheetTransactionWidget extends StatefulWidget {
  const BottomSheetTransactionWidget({
    super.key,
    String? emoji,
    String? name,
    String? toName,
    String? date,
    required this.quantity,
    String? byName,
    String? note,
    required this.value,
    required this.id,
  })  : emoji = emoji ?? '❌',
        name = name ?? 'Aucun nom de transaction trouvé',
        toName = toName ?? 'Aucun joueur trouvé',
        date = date ?? 'Aucune date trouvée',
        byName = byName ?? 'Aucun joueur trouvé',
        note = note ?? 'Aucune note';

  final String emoji;
  final String name;
  final String toName;
  final String date;
  final double? quantity;
  final String byName;
  final String note;
  final double? value;
  final String? id;

  @override
  State<BottomSheetTransactionWidget> createState() =>
      _BottomSheetTransactionWidgetState();
}

class _BottomSheetTransactionWidgetState
    extends State<BottomSheetTransactionWidget> {
  late BottomSheetTransactionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomSheetTransactionModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Material(
      color: Colors.transparent,
      elevation: 5.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(0.0, -1.0),
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE5B5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          widget.emoji,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Manrope',
                                    fontSize: 32.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        Text(
                          widget.toName,
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                fontFamily: 'Manrope',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(const SizedBox(height: 4.0)),
                    ),
                    Text(
                      valueOrDefault<String>(
                        functions.convertDotCommaEuro(widget.value!),
                        '0',
                      ),
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Manrope',
                                letterSpacing: 0.0,
                              ),
                    ),
                  ].divide(const SizedBox(height: 8.0)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantité',
                        style:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Manrope',
                                  letterSpacing: 0.0,
                                ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget.quantity?.toString(),
                          '0',
                        ),
                        textAlign: TextAlign.end,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Manrope',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(const SizedBox(width: 4.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sanctionné par',
                        style:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Manrope',
                                  letterSpacing: 0.0,
                                ),
                      ),
                      Text(
                        widget.byName,
                        textAlign: TextAlign.end,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Manrope',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(const SizedBox(width: 4.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Manrope',
                                  letterSpacing: 0.0,
                                ),
                      ),
                      Text(
                        widget.date,
                        textAlign: TextAlign.end,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Manrope',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ].divide(const SizedBox(width: 4.0)),
                  ),
                  if (valueOrDefault<bool>(
                    widget.note == '' ? false : true,
                    false,
                  ))
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note',
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        Text(
                          widget.note,
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Manrope',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(const SizedBox(height: 4.0)),
                    ),
                ].divide(const SizedBox(height: 8.0)),
              ),
              if (valueOrDefault<bool>(
                (FFAppState().roleSetup == 'admin') ||
                        (FFAppState().roleSetup == 'owner')
                    ? true
                    : false,
                false,
              ))
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await TransactionsTable().delete(
                            matchingRows: (rows) => rows.eq(
                              'id',
                              widget.id,
                            ),
                          );
                          Navigator.pop(context, true);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: FaIcon(
                                  FontAwesomeIcons.trashAlt,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            Text(
                              'Supprimer',
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Manrope',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                      ),
                    ].divide(const SizedBox(width: 16.0)),
                  ),
                ),
              Container(
                width: 100.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ),
            ].divide(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
