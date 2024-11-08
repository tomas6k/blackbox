import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item/item_payment/item_payment_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'payment_pending_model.dart';
export 'payment_pending_model.dart';

class PaymentPendingWidget extends StatefulWidget {
  const PaymentPendingWidget({super.key});

  @override
  State<PaymentPendingWidget> createState() => _PaymentPendingWidgetState();
}

class _PaymentPendingWidgetState extends State<PaymentPendingWidget> {
  late PaymentPendingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentPendingModel());

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
            buttonSize: 54.0,
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Paiements en attente',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Manrope',
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: FutureBuilder<List<TransactionsRow>>(
              future: FFAppState().paymentPending(
                requestFn: () => TransactionsTable().queryRows(
                  queryFn: (q) => q
                      .eq(
                        'statut',
                        2.0,
                      )
                      .eq(
                        'saison_id',
                        FFAppState().saisonSetup,
                      ),
                ),
              ),
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                List<TransactionsRow> columnTransactionsRowList =
                    snapshot.data!;

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(columnTransactionsRowList.length,
                      (columnIndex) {
                    final columnTransactionsRow =
                        columnTransactionsRowList[columnIndex];
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ItemPaymentWidget(
                          key: Key(
                              'Keyrld_${columnIndex}_of_${columnTransactionsRowList.length}'),
                          primary: valueOrDefault<String>(
                            columnTransactionsRow.transactionToName,
                            'Aucun joueur trouvé',
                          ),
                          value: valueOrDefault<double>(
                            columnTransactionsRow.transactionValue,
                            0.0,
                          ),
                          pending: true,
                          emoji: valueOrDefault<String>(
                            columnTransactionsRow.transactionImg,
                            '💸',
                          ),
                          id: columnTransactionsRow.id,
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    );
                  }).divide(const SizedBox(height: 12.0)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
