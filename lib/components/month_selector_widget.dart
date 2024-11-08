import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'month_selector_model.dart';
export 'month_selector_model.dart';

class MonthSelectorWidget extends StatefulWidget {
  const MonthSelectorWidget({
    super.key,
    required this.monthText,
    required this.monthNumber,
    bool? active,
  }) : active = active ?? false;

  final String? monthText;
  final int? monthNumber;
  final bool active;

  @override
  State<MonthSelectorWidget> createState() => _MonthSelectorWidgetState();
}

class _MonthSelectorWidgetState extends State<MonthSelectorWidget> {
  late MonthSelectorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MonthSelectorModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: widget.active
            ? FlutterFlowTheme.of(context).primaryBackgroundInverse
            : FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Align(
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Text(
          valueOrDefault<String>(
            widget.monthText,
            'Janvier',
          ),
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Manrope',
                color: widget.active
                    ? FlutterFlowTheme.of(context).primaryTextInverse
                    : FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
      ),
    );
  }
}
