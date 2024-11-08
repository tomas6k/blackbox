import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'button_header_model.dart';
export 'button_header_model.dart';

class ButtonHeaderWidget extends StatefulWidget {
  const ButtonHeaderWidget({
    super.key,
    required this.text,
    required this.icon,
    int? countAmount,
    bool? count,
  })  : countAmount = countAmount ?? 0,
        count = count ?? false;

  final String? text;
  final Widget? icon;
  final int countAmount;
  final bool count;

  @override
  State<ButtonHeaderWidget> createState() => _ButtonHeaderWidgetState();
}

class _ButtonHeaderWidgetState extends State<ButtonHeaderWidget> {
  late ButtonHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonHeaderModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 76.0,
        height: 80.0,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: widget.icon!,
              ),
            ),
            Text(
              valueOrDefault<String>(
                widget.text,
                'button',
              ),
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Manrope',
                    color: FlutterFlowTheme.of(context).primaryTextInverse,
                    letterSpacing: 0.0,
                  ),
            ),
          ].divide(const SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
