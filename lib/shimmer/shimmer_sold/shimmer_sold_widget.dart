import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'shimmer_sold_model.dart';
export 'shimmer_sold_model.dart';

class ShimmerSoldWidget extends StatefulWidget {
  const ShimmerSoldWidget({super.key});

  @override
  State<ShimmerSoldWidget> createState() => _ShimmerSoldWidgetState();
}

class _ShimmerSoldWidgetState extends State<ShimmerSoldWidget>
    with TickerProviderStateMixin {
  late ShimmerSoldModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShimmerSoldModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: Colors.black,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: Colors.black,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: Colors.black,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation4': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: Colors.black,
            angle: 0.524,
          ),
        ],
      ),
    });

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

    return FutureBuilder<ApiCallResponse>(
      future: FFAppState().teamInfo(
        requestFn: () => GetSoldCall.call(
          whitchSaison: FFAppState().saisonSetup,
          whitchUser: FFAppState().userSetup,
          statutParam: '1',
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
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: const Color(0x21FFFFFF),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation1']!),
                  Container(
                    decoration: const BoxDecoration(),
                    child: Container(
                      width: 150.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: const Color(0x21FFFFFF),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['containerOnPageLoadAnimation2']!),
                  ),
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: const BoxDecoration(),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 120.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: const Color(0x21FFFFFF),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation3']!),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: const Color(0x21FFFFFF),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation4']!),
                    ],
                  ),
                ),
              ].divide(const SizedBox(height: 4.0)),
            ),
          ].divide(const SizedBox(height: 20.0)),
        );
      },
    );
  }
}
