import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  width: 100.0,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          alignment: const AlignmentDirectional(-1.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/blackbox-spash.png',
                              width: double.infinity,
                              height: 100.0,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, -1.0),
                                  child: Text(
                                    'Se connecter',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineLarge
                                        .override(
                                          fontFamily: 'Manrope',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: 370.0,
                                      child: TextFormField(
                                        controller:
                                            _model.emailAddressTextController,
                                        focusNode: _model.emailAddressFocusNode,
                                        autofocus: true,
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'Manrope',
                                                    letterSpacing: 0.0,
                                                  ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Manrope',
                                              letterSpacing: 0.0,
                                            ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: _model
                                            .emailAddressTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 370.0,
                                      child: TextFormField(
                                        controller:
                                            _model.passwordTextController,
                                        focusNode: _model.passwordFocusNode,
                                        autofocus: true,
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        obscureText: !_model.passwordVisibility,
                                        decoration: InputDecoration(
                                          labelText: 'Mot de passe',
                                          labelStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'Manrope',
                                                    letterSpacing: 0.0,
                                                  ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                          suffixIcon: InkWell(
                                            onTap: () => safeSetState(
                                              () => _model.passwordVisibility =
                                                  !_model.passwordVisibility,
                                            ),
                                            focusNode:
                                                FocusNode(skipTraversal: true),
                                            child: Icon(
                                              _model.passwordVisibility
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Manrope',
                                              letterSpacing: 0.0,
                                            ),
                                        validator: _model
                                            .passwordTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 16.0)),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        final router = GoRouter.of(context);
                                        router.prepareAuthEvent();

                                        final user =
                                            await authManager.signInWithEmail(
                                          context,
                                          _model
                                              .emailAddressTextController.text,
                                          _model.passwordTextController.text,
                                        );
                                        if (user == null) {
                                          return;
                                        }

                                        _model.teamQuery =
                                            await UserTeamsTable().queryRows(
                                          queryFn: (q) => q.eq(
                                            'user_id',
                                            currentUserUid,
                                          ),
                                        );
                                        if (!mounted) {
                                          return;
                                        }
                                        if (_model.teamQuery?.length == 1) {
                                          _model.saisonOutput =
                                              await SaisonsTable().queryRows(
                                            queryFn: (q) => q
                                                .eq(
                                                  'team_id',
                                                  _model
                                                      .teamQuery?.first.teamId,
                                                )
                                                .eq(
                                                  'active',
                                                  true,
                                                ),
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          FFAppState().teamSetup = _model
                                              .saisonOutput!.first.teamId!;
                                          FFAppState().userSetup =
                                              _model.teamQuery!.first.id;
                                          FFAppState().saisonSetup =
                                              _model.saisonOutput!.first.id;
                                          FFAppState().roleSetup =
                                              _model.teamQuery!.first.role!;

                                          if (!mounted ||
                                              router.shouldRedirect(false)) {
                                            return;
                                          }
                                          router.goNamed('Home');
                                        } else {
                                          final hasNoTeam =
                                              _model.teamQuery?.isEmpty ?? true;
                                          if (hasNoTeam) {
                                            if (!mounted ||
                                                router.shouldRedirect(false)) {
                                              return;
                                            }
                                            router.goNamed('joinTeam');
                                          } else {
                                            if (!mounted) {
                                              return;
                                            }
                                            final dialogContext = context;
                                            await showDialog(
                                              context: dialogContext,
                                              builder: (alertDialogContext) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Plus d\'une équipe'),
                                                  content: const Text(
                                                      'En construction, pas possible avec cette version. Contacter l\'administarteur'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              alertDialogContext),
                                                      child: const Text('Ok'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if (!mounted) {
                                              return;
                                            }
                                          }
                                        }

                                        // await actions.onesignalLogin(
                                        //   currentUserUid,
                                        // );
                                      },
                                      text: 'Se connecter',
                                      options: FFButtonOptions(
                                        width: 370.0,
                                        height: 44.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: Colors.black,
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
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        if (_model.emailAddressTextController
                                            .text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Email required!',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        await authManager.resetPassword(
                                          email: _model
                                              .emailAddressTextController.text,
                                          context: context,
                                        );
                                      },
                                      text: 'Mot de passe oublié',
                                      options: FFButtonOptions(
                                        width: 370.0,
                                        height: 44.0,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: Colors.transparent,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Manrope',
                                              color: Colors.black,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ].divide(const SizedBox(height: 16.0)),
                                ),

                                // You will have to add an action on this rich text to go to your login page.
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, -1.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 12.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.goNamed('createAccount');
                                      },
                                      child: RichText(
                                        textScaler:
                                            MediaQuery.of(context).textScaler,
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Pas de compte ?',
                                              style: TextStyle(),
                                            ),
                                            TextSpan(
                                              text: ' S\'enregistrer',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Manrope',
                                                        color: Colors.black,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                            )
                                          ],
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Manrope',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(height: 32.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 100.0,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.network(
                            'https://images.unsplash.com/photo-1514924013411-cbf25faa35bb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1380&q=80',
                          ).image,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
