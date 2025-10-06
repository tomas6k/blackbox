import '/app_state.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PaymentInstructionsWidget extends StatefulWidget {
  const PaymentInstructionsWidget({super.key});

  @override
  State<PaymentInstructionsWidget> createState() =>
      _PaymentInstructionsWidgetState();
}

class _PaymentInstructionsWidgetState extends State<PaymentInstructionsWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static const _iban = 'FR76 1759 8000 0100 0311 8649 544';

  Widget _ribInfoTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4.0),
                SelectableText(
                  value,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
              ],
            ),
          ),
          FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.copy_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Copié dans le presse-papier',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Manrope',
                          letterSpacing: 0.0,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.close_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 28.0,
            ),
            onPressed: () async {
              context.goNamed('Home');
            },
          ),
          title: Text(
            'Moyens de paiements'.maybeHandleOverflow(
                maxChars: 32, replacement: 'Moyens de paiements'),
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Manrope',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding:
                const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merci de privilégier le virement bancaire pour régler votre participation.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Virement bancaire',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.08),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _ribInfoTile(
                        context,
                        label: 'Titulaire du compte',
                        value: 'Arnaud GORGERIN',
                      ),
                      _ribInfoTile(
                        context,
                        label: 'IBAN',
                        value: _iban,
                      ),
                      _ribInfoTile(
                        context,
                        label: 'BIC',
                        value: 'LYDIFRP2XXX',
                      ),
                      _ribInfoTile(
                        context,
                        label: 'N° de compte',
                        value: '00031186495',
                      ),
                    ].divide(const SizedBox(height: 12.0)),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'En espèces',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Un paiement en espèces est possible avec une majoration de 10 %. '
                  'Merci de préparer le montant exact majoré et de le remettre à un membre du staff.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
