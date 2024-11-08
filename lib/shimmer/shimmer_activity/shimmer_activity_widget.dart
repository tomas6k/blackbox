import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'shimmer_activity_model.dart';
export 'shimmer_activity_model.dart';

class ShimmerActivityWidget extends StatefulWidget {
  const ShimmerActivityWidget({super.key});

  @override
  State<ShimmerActivityWidget> createState() => _ShimmerActivityWidgetState();
}

class _ShimmerActivityWidgetState extends State<ShimmerActivityWidget> {
  late ShimmerActivityModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShimmerActivityModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
