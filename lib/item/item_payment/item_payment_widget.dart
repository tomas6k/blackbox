import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'item_payment_model.dart';
export 'item_payment_model.dart';

class ItemPaymentWidget extends StatefulWidget {
  const ItemPaymentWidget({
    super.key,
    String? primary,
    double? value,
    bool? pending,
    String? emoji,
    required this.id,
  })  : primary = primary ?? 'Aucun titre associé',
        value = value ?? 0.0,
        pending = pending ?? false,
        emoji = emoji ?? '❌';

  final String primary;
  final double value;
  final bool pending;
  final String emoji;
  final String? id;

  @override
  State<ItemPaymentWidget> createState() => _ItemPaymentWidgetState();
}

class _ItemPaymentWidgetState extends State<ItemPaymentWidget> {
  late ItemPaymentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemPaymentModel());

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.transparent,
            width: 0.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40.0,
                height: 40.0,
                child: Stack(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            widget.emoji,
                            '❌',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Manrope',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                    if (widget.pending)
                      Align(
                        alignment: const AlignmentDirectional(2.0, 2.0),
                        child: Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).warning,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: FaIcon(
                              FontAwesomeIcons.clock,
                              color: FlutterFlowTheme.of(context)
                                  .primaryTextInverse,
                              size: 14.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20.0,
                      decoration: const BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(
                              valueOrDefault<String>(
                                widget.primary,
                                'Aucun joueur',
                              ),
                              maxLines: 1,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                    lineHeight: 1.4286,
                                  ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 4.0)),
                      ),
                    ),
                    Container(
                      height: 16.0,
                      decoration: const BoxDecoration(),
                      child: Text(
                        valueOrDefault<String>(
                          functions.convertDotCommaEuro(valueOrDefault<double>(
                            widget.value,
                            0.0,
                          )),
                          '0 €',
                        ),
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily: 'Manrope',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 4.0)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 12.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).alternate,
                        icon: FaIcon(
                          FontAwesomeIcons.check,
                          color: FlutterFlowTheme.of(context).success,
                          size: 24.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: () async {
                          await TransactionsTable().update(
                            data: {
                              'statut': 1.0,
                            },
                            matchingRows: (rows) => rows.eq(
                              'id',
                              widget.id,
                            ),
                          );
                          FFAppState().clearPaymentPendingCache();
                          FFAppState().clearDashboardMyPaymentCache();

                          FFAppState().update(() {});

                          safeSetState(() {});
                        },
                      ),
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 12.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).alternate,
                        icon: FaIcon(
                          FontAwesomeIcons.trashAlt,
                          color: FlutterFlowTheme.of(context).error,
                          size: 24.0,
                        ),
                        showLoadingIndicator: true,
                        onPressed: () async {
                          await TransactionsTable().delete(
                            matchingRows: (rows) => rows.eq(
                              'id',
                              widget.id,
                            ),
                          );
                          FFAppState().clearPaymentPendingCache();
                          FFAppState().clearDashboardMyPaymentCache();

                          FFAppState().update(() {});

                          safeSetState(() {});
                        },
                      ),
                    ].divide(const SizedBox(width: 8.0)),
                  ),
                ],
              ),
            ].divide(const SizedBox(width: 12.0)),
          ),
        ),
      ),
    );
  }
}
