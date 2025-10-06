import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/bottom_sheet_transaction_widget.dart';
import '/components/button_header_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/item/item_transaction/item_transaction_widget.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!((FFAppState().teamSetup != '') ||
          (FFAppState().userSetup != '') ||
          (FFAppState().saisonSetup != '') ||
          (FFAppState().roleSetup != ''))) {
        context.goNamed('joinTeam');

        FFAppState().deleteTeamSetup();
        FFAppState().teamSetup = '';

        FFAppState().deleteUserSetup();
        FFAppState().userSetup = '';

        FFAppState().deleteSaisonSetup();
        FFAppState().saisonSetup = '';

        FFAppState().deleteRoleSetup();
        FFAppState().roleSetup = '';
      }
    });

    animationsMap.addAll({
      'itemTransactionOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.98, 0.98),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

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

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: Visibility(
        visible: (FFAppState().roleSetup == 'owner') ||
            (FFAppState().roleSetup == 'admin'),
        child: FloatingActionButton(
          onPressed: () async {
            context.pushNamed(
              'addTransaction',
              extra: <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.bottomToTop,
                ),
              },
            );
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 20.0,
          child: Icon(
            Icons.add,
            color: FlutterFlowTheme.of(context).primaryTextInverse,
            size: 24.0,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: const BoxDecoration(),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/dashboard-background.jpg',
                    ).image,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: FutureBuilder<ApiCallResponse>(
                                future: FFAppState()
                                    .teamMemberInfo(
                                  requestFn: () => GetSoldCall.call(
                                    whitchSaison: FFAppState().saisonSetup,
                                    statutParam: '1',
                                  ),
                                )
                                    .then((result) {
                                  _model.apiRequestCompleted2 = true;
                                  return result;
                                }),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final teamSoldGetSoldResponse =
                                      snapshot.data!;

                                  return Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0x3FFFFFFF),
                                          borderRadius:
                                              BorderRadius.circular(9999.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(8.0, 4.0, 16.0, 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        9999.0),
                                                child: CachedNetworkImage(
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 500),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 500),
                                                  imageUrl:
                                                      valueOrDefault<String>(
                                                    getJsonField(
                                                      teamSoldGetSoldResponse
                                                          .jsonBody,
                                                      r'''$[0].team_img''',
                                                    )?.toString(),
                                                    'https://dnrinnvsfrbmrlmcxiij.supabase.co/storage/v1/object/public/default/avatar.jpg',
                                                  ),
                                                  width: 32.0,
                                                  height: 32.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    valueOrDefault<String>(
                                                      getJsonField(
                                                        teamSoldGetSoldResponse
                                                            .jsonBody,
                                                        r'''$[0].team_name''',
                                                      )?.toString(),
                                                      'Aucune équipe trouvée',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'Manrope',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryTextInverse,
                                                          letterSpacing: 0.0,
                                                          lineHeight: 1.2,
                                                        ),
                                                  ),
                                                  Opacity(
                                                    opacity: 0.72,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          valueOrDefault<
                                                              String>(
                                                            functions
                                                                .convertDotCommaEuro(
                                                                    valueOrDefault<
                                                                        double>(
                                                              functions.calculatePositiveSum((getJsonField(
                                                                teamSoldGetSoldResponse
                                                                    .jsonBody,
                                                                r'''$''',
                                                                true,
                                                              )!
                                                                      .toList()
                                                                      .map<GetSoldStruct?>(GetSoldStruct.maybeFromMap)
                                                                      .toList() as Iterable<GetSoldStruct?>)
                                                                  .withoutNulls
                                                                  .map((e) => e.toMap())
                                                                  .toList()),
                                                              0.0,
                                                            )),
                                                            '0 €',
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .labelSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Manrope',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryTextInverse,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            const FaIcon(
                                                              FontAwesomeIcons
                                                                  .clock,
                                                              color:
                                                                  Colors.white,
                                                              size: 16.0,
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                functions.convertDotCommaEuro(
                                                                    valueOrDefault<
                                                                        double>(
                                                                  functions.calculateTotalDueSum((teamSoldGetSoldResponse
                                                                          .jsonBody
                                                                          .toList()
                                                                          .map<GetSoldStruct?>(
                                                                              GetSoldStruct.maybeFromMap)
                                                                          .toList() as Iterable<GetSoldStruct?>)
                                                                      .withoutNulls
                                                                      .map((e) => e.toMap())
                                                                      .toList()),
                                                                  0.0,
                                                                )),
                                                                '0 €',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .override(
                                                                    fontFamily:
                                                                        'Manrope',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryTextInverse,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  width: 4.0)),
                                                        ),
                                                      ].divide(const SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ].divide(
                                                const SizedBox(width: 8.0)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            FutureBuilder<ApiCallResponse>(
                              future: FFAppState()
                                  .userSold(
                                requestFn: () => GetSoldCall.call(
                                  whitchSaison: FFAppState().saisonSetup,
                                  whitchUser: FFAppState().userSetup,
                                  statutParam: '1',
                                ),
                              )
                                  .then((result) {
                                _model.apiRequestCompleted1 = true;
                                return result;
                              }),
                              builder: (context, snapshot) {
                                // Customize what your widget looks like when it's loading.
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final userSoldGetSoldResponse = snapshot.data!;

                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 0.0, 20.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              functions.convertDotCommaEuro(
                                                  valueOrDefault<double>(
                                                getJsonField(
                                                  userSoldGetSoldResponse
                                                      .jsonBody,
                                                  r'''$..total_due_sum''',
                                                ),
                                                0.0,
                                              )),
                                              '0 €',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  fontFamily: 'Manrope',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryTextInverse,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 0.0, 20.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              'Solde à venir ${valueOrDefault<String>(
                                                functions.convertDotCommaEuro(
                                                    valueOrDefault<double>(
                                                  getJsonField(
                                                    userSoldGetSoldResponse
                                                        .jsonBody,
                                                    r'''$..total_sum''',
                                                  ),
                                                  0.0,
                                                )),
                                                '0 €',
                                              )}',
                                              'Solde à venir 0 €',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'Manrope',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryTextInverse,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ].divide(const SizedBox(height: 40.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 20.0, 20.0, 24.0),
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
                                _model.pendingTransaction =
                                    await TransactionsTable().queryRows(
                                  queryFn: (q) => q
                                      .eq(
                                        'saison_id',
                                        FFAppState().saisonSetup,
                                      )
                                      .eq(
                                        'transaction_to',
                                        FFAppState().userSetup,
                                      )
                                      .eq(
                                        'statut',
                                        2.0,
                                      ),
                                );
                                if (_model.pendingTransaction!.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tu as déjà initié un paiement',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).warning,
                                    ),
                                  );
                                } else {
                                  context.goNamed(
                                    'payment',
                                    extra: <String, dynamic>{
                                      kTransitionInfoKey: const TransitionInfo(
                                        hasTransition: true,
                                        transitionType:
                                            PageTransitionType.bottomToTop,
                                      ),
                                    },
                                  );
                                }

                                safeSetState(() {});
                              },
                              child: wrapWithModel(
                                model: _model.buttonHeaderModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonHeaderWidget(
                                  text: 'Payer',
                                  icon: FaIcon(
                                    FontAwesomeIcons.euroSign,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryTextInverse,
                                    size: 24.0,
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
                                context.pushNamed('rules');
                              },
                              child: wrapWithModel(
                                model: _model.buttonHeaderModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonHeaderWidget(
                                  text: 'Règles',
                                  icon: FaIcon(
                                    FontAwesomeIcons.bookOpen,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryTextInverse,
                                    size: 24.0,
                                  ),
                                  count: false,
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed('paymentInstructions');
                              },
                              child: wrapWithModel(
                                model: _model.buttonHeaderModel4,
                                updateCallback: () => safeSetState(() {}),
                                child: ButtonHeaderWidget(
                                  text: 'Voir le RIB',
                                  icon: FaIcon(
                                    FontAwesomeIcons.moneyCheckDollar,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryTextInverse,
                                    size: 24.0,
                                  ),
                                  count: false,
                                ),
                              ),
                            ),
                            if ((FFAppState().roleSetup == 'owner') ||
                                (FFAppState().roleSetup == 'admin'))
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed('paymentPending');
                                },
                                child: Stack(
                                  alignment:
                                      const AlignmentDirectional(0.7, -1.1),
                                  children: [
                                    wrapWithModel(
                                      model: _model.buttonHeaderModel3,
                                      updateCallback: () => safeSetState(() {}),
                                      child: ButtonHeaderWidget(
                                        text: 'Paiements',
                                        icon: FaIcon(
                                          FontAwesomeIcons.donate,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryTextInverse,
                                          size: 24.0,
                                        ),
                                        count: false,
                                      ),
                                    ),
                                    FutureBuilder<List<TransactionsRow>>(
                                      future: FFAppState()
                                          .paymentPending(
                                        requestFn: () =>
                                            TransactionsTable().queryRows(
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
                                      )
                                          .then((result) {
                                        _model.requestCompleted3 = true;
                                        return result;
                                      }),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<TransactionsRow>
                                            transactionsPaymentPendingTransactionsRowList =
                                            snapshot.data!;

                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(99.0),
                                          ),
                                          child: Visibility(
                                            visible:
                                                transactionsPaymentPendingTransactionsRowList
                                                    .isNotEmpty,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(99.0),
                                              child: Container(
                                                width: 20.0,
                                                height: 20.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          99.0),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      transactionsPaymentPendingTransactionsRowList
                                                          .length
                                                          .toString(),
                                                      '0',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily: 'Manrope',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryTextInverse,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ].divide(const SizedBox(width: 16.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: RefreshIndicator(
                  color: FlutterFlowTheme.of(context).primary,
                  onRefresh: () async {
                    safeSetState(() {
                      FFAppState().clearUserSoldCache();
                      _model.apiRequestCompleted1 = false;
                    });
                    await _model.waitForApiRequestCompleted1();
                    safeSetState(() {
                      FFAppState().clearDashboardTransactionCache();
                      _model.requestCompleted1 = false;
                    });
                    safeSetState(() {
                      FFAppState().clearDashboardMyPaymentCache();
                      _model.requestCompleted2 = false;
                    });
                    safeSetState(() {
                      FFAppState().clearTeamMemberInfoCache();
                      _model.apiRequestCompleted2 = false;
                    });
                    safeSetState(() {
                      FFAppState().clearPaymentPendingCache();
                      _model.requestCompleted3 = false;
                    });
                    await _model.waitForRequestCompleted3();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.sizeOf(context).height * 0.4,
                          ),
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FutureBuilder<List<TransactionsRow>>(
                                future: FFAppState()
                                    .dashboardMyPayment(
                                  requestFn: () =>
                                      TransactionsTable().querySingleRow(
                                    queryFn: (q) => q
                                        .eq(
                                          'saison_id',
                                          FFAppState().saisonSetup,
                                        )
                                        .eq(
                                          'statut',
                                          2.0,
                                        )
                                        .eq(
                                          'transaction_to',
                                          FFAppState().userSetup,
                                        )
                                        .order('transaction_date'),
                                  ),
                                )
                                    .then((result) {
                                  _model.requestCompleted2 = true;
                                  return result;
                                }),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 40.0,
                                        height: 40.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<TransactionsRow>
                                      myPaymentTransactionsRowList =
                                      snapshot.data!;

                                  // Return an empty Container when the item does not exist.
                                  if (snapshot.data!.isEmpty) {
                                    return Container();
                                  }
                                  final myPaymentTransactionsRow =
                                      myPaymentTransactionsRowList.isNotEmpty
                                          ? myPaymentTransactionsRowList.first
                                          : null;

                                  return Container(
                                    decoration: const BoxDecoration(),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 16.0, 0.0, 0.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        12.0, 12.0, 12.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tu as initié un paiement',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                'Manrope',
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                    Text(
                                                      'Ta demande est en attente de validation par le trésorier. Assure-toi que le paiement a bien été effectué.',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily:
                                                                    'Manrope',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                    ),
                                                  ].divide(const SizedBox(
                                                      height: 4.0)),
                                                ),
                                              ),
                                              ListView(
                                                padding: EdgeInsets.zero,
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      wrapWithModel(
                                                        model: _model
                                                            .itemTransactionModel1,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            ItemTransactionWidget(
                                                          primary:
                                                              myPaymentTransactionsRow!
                                                                  .transactionName!,
                                                          secondary:
                                                              dateTimeFormat(
                                                            "d MMMM • HH:mm",
                                                            myPaymentTransactionsRow
                                                                .transactionDate,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ),
                                                          supporting:
                                                              dateTimeFormat(
                                                            "d MMMM • HH:mm",
                                                            myPaymentTransactionsRow
                                                                .transactionDate,
                                                            locale: FFLocalizations
                                                                    .of(context)
                                                                .languageCode,
                                                          ),
                                                          value: myPaymentTransactionsRow
                                                              .transactionValue,
                                                          pending: true,
                                                          amount: false,
                                                          emoji: valueOrDefault<
                                                              String>(
                                                            myPaymentTransactionsRow
                                                                .transactionImg,
                                                            '❌',
                                                          ),
                                                          amountNumber: 1.0,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                12.0,
                                                                8.0,
                                                                12.0,
                                                                12.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  await TransactionsTable()
                                                                      .delete(
                                                                    matchingRows:
                                                                        (rows) =>
                                                                            rows.eq(
                                                                      'id',
                                                                      myPaymentTransactionsRow
                                                                          .id,
                                                                    ),
                                                                  );
                                                                  safeSetState(
                                                                      () {
                                                                    FFAppState()
                                                                        .clearDashboardMyPaymentCache();
                                                                    _model.requestCompleted2 =
                                                                        false;
                                                                  });
                                                                  safeSetState(
                                                                      () {
                                                                    FFAppState()
                                                                        .clearDashboardTransactionCache();
                                                                    _model.requestCompleted1 =
                                                                        false;
                                                                  });
                                                                  safeSetState(
                                                                      () {
                                                                    FFAppState()
                                                                        .clearPaymentPendingCache();
                                                                    _model.requestCompleted3 =
                                                                        false;
                                                                  });
                                                                  await _model
                                                                      .waitForRequestCompleted3();
                                                                },
                                                                text:
                                                                    'Annuler mon paiement',
                                                                options:
                                                                    FFButtonOptions(
                                                                  height: 40.0,
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          24.0,
                                                                          0.0,
                                                                          24.0,
                                                                          0.0),
                                                                  iconPadding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'Manrope',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                                  elevation:
                                                                      0.0,
                                                                  borderSide:
                                                                      const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 0.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  width: 12.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(const SizedBox(
                                                    height: 12.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child:
                                          FutureBuilder<List<TransactionsRow>>(
                                        future: FFAppState()
                                            .dashboardTransaction(
                                          requestFn: () =>
                                              TransactionsTable().queryRows(
                                            queryFn: (q) => q
                                                .eq(
                                                  'transaction_to',
                                                  FFAppState().userSetup,
                                                )
                                                .eq(
                                                  'saison_id',
                                                  FFAppState().saisonSetup,
                                                )
                                                .eq(
                                                  'statut',
                                                  1.0,
                                                )
                                                .order('transaction_date'),
                                            limit: 3,
                                          ),
                                        )
                                            .then((result) {
                                          _model.requestCompleted1 = true;
                                          return result;
                                        }),
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 40.0,
                                                height: 40.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          List<TransactionsRow>
                                              myTransactionsListTransactionsRowList =
                                              snapshot.data!;

                                          if (myTransactionsListTransactionsRowList
                                              .isEmpty) {
                                            return Center(
                                              child: Image.asset(
                                                'assets/images/blackbox-logo.png',
                                                width: 50.0,
                                                height: 50.0,
                                              ),
                                            );
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: List.generate(
                                                myTransactionsListTransactionsRowList
                                                    .length,
                                                (myTransactionsListIndex) {
                                              final myTransactionsListTransactionsRow =
                                                  myTransactionsListTransactionsRowList[
                                                      myTransactionsListIndex];
                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      HapticFeedback
                                                          .selectionClick();
                                                      await showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        useSafeArea: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                BottomSheetTransactionWidget(
                                                              emoji: myTransactionsListTransactionsRow
                                                                  .transactionImg!,
                                                              name: myTransactionsListTransactionsRow
                                                                  .transactionName!,
                                                              toName: myTransactionsListTransactionsRow
                                                                  .transactionToName!,
                                                              date:
                                                                  dateTimeFormat(
                                                                "d MMMM • HH:mm",
                                                                myTransactionsListTransactionsRow
                                                                    .date!,
                                                                locale: FFLocalizations.of(
                                                                        context)
                                                                    .languageCode,
                                                              ),
                                                              quantity:
                                                                  valueOrDefault<
                                                                      double>(
                                                                myTransactionsListTransactionsRow
                                                                    .transactionAmount,
                                                                1.0,
                                                              ),
                                                              byName: myTransactionsListTransactionsRow
                                                                  .createdByName!,
                                                              note:
                                                                  myTransactionsListTransactionsRow
                                                                      .note,
                                                              value: myTransactionsListTransactionsRow
                                                                  .transactionValue,
                                                              id: myTransactionsListTransactionsRow
                                                                  .id,
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() =>
                                                              _model.transactionChange =
                                                                  value));

                                                      if (_model
                                                          .transactionChange!) {
                                                        safeSetState(() {
                                                          FFAppState()
                                                              .clearUserSoldCache();
                                                          _model.apiRequestCompleted1 =
                                                              false;
                                                        });
                                                        await _model
                                                            .waitForApiRequestCompleted1();
                                                        safeSetState(() {
                                                          FFAppState()
                                                              .clearDashboardTransactionCache();
                                                          _model.requestCompleted1 =
                                                              false;
                                                        });
                                                        safeSetState(() {
                                                          FFAppState()
                                                              .clearDashboardMyPaymentCache();
                                                          _model.requestCompleted2 =
                                                              false;
                                                        });
                                                        safeSetState(() {
                                                          FFAppState()
                                                              .clearTeamMemberInfoCache();
                                                          _model.apiRequestCompleted2 =
                                                              false;
                                                        });
                                                        safeSetState(() {
                                                          FFAppState()
                                                              .clearPaymentPendingCache();
                                                          _model.requestCompleted3 =
                                                              false;
                                                        });
                                                        await _model
                                                            .waitForRequestCompleted3();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Transaction supprimée',
                                                              style: TextStyle(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                              ),
                                                            ),
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        4000),
                                                            backgroundColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .success,
                                                          ),
                                                        );
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                    child:
                                                        ItemTransactionWidget(
                                                      key: Key(
                                                          'Keyqfw_${myTransactionsListIndex}_of_${myTransactionsListTransactionsRowList.length}'),
                                                      primary:
                                                          myTransactionsListTransactionsRow
                                                              .transactionName!,
                                                      secondary: dateTimeFormat(
                                                        "d MMMM • HH:mm",
                                                        myTransactionsListTransactionsRow
                                                            .transactionDate,
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
                                                      supporting:
                                                          dateTimeFormat(
                                                        "d MMMM • HH:mm",
                                                        myTransactionsListTransactionsRow
                                                            .transactionDate,
                                                        locale:
                                                            FFLocalizations.of(
                                                                    context)
                                                                .languageCode,
                                                      ),
                                                      value:
                                                          myTransactionsListTransactionsRow
                                                              .transactionValue,
                                                      pending:
                                                          myTransactionsListTransactionsRow
                                                                  .statut ==
                                                              2.0,
                                                      amount: myTransactionsListTransactionsRow
                                                              .transactionAmount! >
                                                          1.0,
                                                      emoji: valueOrDefault<
                                                          String>(
                                                        myTransactionsListTransactionsRow
                                                            .transactionImg,
                                                        '❌',
                                                      ),
                                                      amountNumber:
                                                          valueOrDefault<
                                                              double>(
                                                        myTransactionsListTransactionsRow
                                                            .transactionAmount,
                                                        1.0,
                                                      ),
                                                    ),
                                                  ).animateOnActionTrigger(
                                                    animationsMap[
                                                        'itemTransactionOnActionTriggerAnimation']!,
                                                  ),
                                                  if (myTransactionsListIndex ==
                                                      2)
                                                    FFButtonWidget(
                                                      onPressed: () async {
                                                        context.pushNamed(
                                                            'myTransactions');
                                                      },
                                                      text: 'Tout afficher',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 40.0,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(24.0,
                                                                0.0, 24.0, 0.0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                0.0, 0.0, 0.0),
                                                        color:
                                                            Colors.transparent,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Manrope',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                        elevation: 0.0,
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 0.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                                .divide(const SizedBox(height: 16.0))
                                .addToStart(const SizedBox(height: 0.0)),
                          ),
                        ),
                      ]
                          .divide(const SizedBox(height: 12.0))
                          .addToEnd(const SizedBox(height: 24.0)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
