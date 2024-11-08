import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/item/item_player/item_player_widget.dart';
import '/shimmer/shimmer_test/shimmer_test_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'team_model.dart';
export 'team_model.dart';

class TeamWidget extends StatefulWidget {
  const TeamWidget({super.key});

  @override
  State<TeamWidget> createState() => _TeamWidgetState();
}

class _TeamWidgetState extends State<TeamWidget> {
  late TeamModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeamModel());

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
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: Text(
                          'Mon équipe',
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Manrope',
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<ApiCallResponse>(
                          future: FFAppState()
                              .teamMemberInfo(
                            requestFn: () => GetSoldCall.call(
                              whitchSaison: FFAppState().saisonSetup,
                              statutParam: '1',
                            ),
                          )
                              .then((result) {
                            _model.apiRequestCompleted = true;
                            return result;
                          }),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return const ShimmerTestWidget();
                            }
                            final listViewGetSoldResponse = snapshot.data!;

                            return Builder(
                              builder: (context) {
                                final teamList = (getJsonField(
                                      listViewGetSoldResponse.jsonBody,
                                      r'''$''',
                                      true,
                                    )
                                                ?.toList()
                                                .map<GetSoldStruct?>(
                                                    GetSoldStruct.maybeFromMap)
                                                .toList()
                                            as Iterable<GetSoldStruct?>)
                                        .withoutNulls
                                        .toList() ??
                                    [];
                                if (teamList.isEmpty) {
                                  return Center(
                                    child: Image.asset(
                                      'assets/images/blackbox-logo.png',
                                      width: 50.0,
                                      height: 50.0,
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  color: FlutterFlowTheme.of(context).primary,
                                  onRefresh: () async {
                                    safeSetState(() {
                                      FFAppState().clearTeamMemberInfoCache();
                                      _model.apiRequestCompleted = false;
                                    });
                                    await _model.waitForApiRequestCompleted();
                                  },
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      24.0,
                                    ),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: teamList.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8.0),
                                    itemBuilder: (context, teamListIndex) {
                                      final teamListItem =
                                          teamList[teamListIndex];
                                      return ItemPlayerWidget(
                                        key: Key(
                                            'Key1ig_${teamListIndex}_of_${teamList.length}'),
                                        primary: valueOrDefault<String>(
                                          teamListItem.userName,
                                          'Aucun nom associé',
                                        ),
                                        secondary: valueOrDefault<double>(
                                          teamListItem.totalDueSum,
                                          0.0,
                                        ),
                                        supporting: valueOrDefault<double>(
                                          teamListItem.totalSum,
                                          0.0,
                                        ),
                                        photo: valueOrDefault<String>(
                                          teamListItem.userImg,
                                          'https://dnrinnvsfrbmrlmcxiij.supabase.co/storage/v1/object/public/default/avatar.jpg',
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ].divide(const SizedBox(height: 12.0)),
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
