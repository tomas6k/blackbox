import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'join_team_model.dart';
export 'join_team_model.dart';

class JoinTeamWidget extends StatefulWidget {
  const JoinTeamWidget({super.key});

  @override
  State<JoinTeamWidget> createState() => _JoinTeamWidgetState();
}

class _JoinTeamWidgetState extends State<JoinTeamWidget> {
  late JoinTeamModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JoinTeamModel());

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.teamCodeTextController ??=
        TextEditingController(text: _model.teamCode);
    _model.teamCodeFocusNode ??= FocusNode();

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Rejoindre une équipe ?',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Manrope',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderRadius: 20.0,
              borderWidth: 1.0,
              buttonSize: 40.0,
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFC11E28),
                size: 24.0,
              ),
              onPressed: () async {
                FFAppState().clearTeamInfoCache();
                FFAppState().clearDashboardTransactionCache();
                FFAppState().clearPenalitiesDefaultCache();
                GoRouter.of(context).prepareAuthEvent();
                await authManager.signOut();
                GoRouter.of(context).clearRedirectLocation();

                context.goNamedAuth('createAccount', context.mounted);
              },
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 48.0, 20.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.nameTextController,
                          focusNode: _model.nameFocusNode,
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Pseudo',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .override(
                                  fontFamily: 'Manrope',
                                  fontSize: 14.0,
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
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 24.0, 0.0, 24.0),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyLarge.override(
                                    fontFamily: 'Manrope',
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                          validator: _model.nameTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _model.teamCodeTextController,
                              focusNode: _model.teamCodeFocusNode,
                              autofocus: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Code équipe',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelLarge
                                    .override(
                                      fontFamily: 'Manrope',
                                      fontSize: 14.0,
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
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        24.0, 24.0, 0.0, 24.0),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: 'Manrope',
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              validator: _model.teamCodeTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(width: 8.0)),
                    ),
                  ].divide(const SizedBox(height: 16.0)),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    _model.teamInfo = await TeamsTable().queryRows(
                      queryFn: (q) => q.eq(
                        'team_code',
                        _model.teamCodeTextController.text,
                      ),
                    );
                    if (_model.teamInfo?.length == 1) {
                      _model.userOutput = await UserTeamsTable().queryRows(
                        queryFn: (q) => q
                            .eq(
                              'user_id',
                              currentUserUid,
                            )
                            .eq(
                              'team_id',
                              _model.teamInfo?.first.id,
                            ),
                      );
                      if (_model.userOutput?.length == 1) {
                        await showDialog(
                          context: context,
                          builder: (alertDialogContext) {
                            return AlertDialog(
                              title: const Text('Tu es deja dans l\'équipe'),
                              content: const Text('Tu es deja dans l\'équipe'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(alertDialogContext),
                                  child: const Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        await UserTeamsTable().insert({
                          'team_id': _model.teamInfo?.first.id,
                          'display_name': _model.nameTextController.text,
                          'user_id': currentUserUid,
                        });
                        _model.userteamID = await UserTeamsTable().queryRows(
                          queryFn: (q) => q
                              .eq(
                                'user_id',
                                currentUserUid,
                              )
                              .eq(
                                'team_id',
                                _model.teamInfo?.first.id,
                              ),
                        );
                        FFAppState().teamSetup =
                            _model.userteamID!.first.teamId;
                        FFAppState().userSetup = _model.userteamID!.first.id;
                        FFAppState().saisonSetup =
                            _model.teamInfo!.first.currentSaison!;
                        FFAppState().roleSetup = _model.userteamID!.first.role!;
                        safeSetState(() {});

                        context.pushNamed('Home');
                      }
                    } else {
                      await showDialog(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: const Text('L\'équipe n\'existe pas'),
                            content: const Text('L\'équipe n\'existe pas'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(alertDialogContext),
                                child: const Text('Ok'),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    safeSetState(() {});
                  },
                  text: 'Rejoindre',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 0.0, 24.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Manrope',
                              letterSpacing: 0.0,
                            ),
                    elevation: 3.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ].divide(const SizedBox(height: 32.0)),
            ),
          ),
        ),
      ),
    );
  }
}
