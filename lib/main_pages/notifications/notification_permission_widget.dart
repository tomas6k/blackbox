import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '/notifiers/push_preferences_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationPermissionWidget extends StatefulWidget {
  const NotificationPermissionWidget({super.key});

  static Future<bool?> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => const NotificationPermissionWidget(),
        fullscreenDialog: true,
      ),
    );
  }

  static Future<bool> requestPermission(BuildContext context) async {
    final pushPrefs = context.read<PushPreferencesNotifier>();
    final appState = FFAppState();

    var granted = false;
    try {
      granted = await pushPrefs.setEnabled(true);
    } catch (error) {
      debugPrint('Notification enable failed: $error');
    }

    appState.update(() {
      appState.notificationsEnabled = granted;
    });

    if (!granted && context.mounted) {
      await _showNotificationSettingsDialog(context);
    }

    return granted;
  }

  @override
  State<NotificationPermissionWidget> createState() =>
      _NotificationPermissionWidgetState();
}

class _NotificationPermissionWidgetState
    extends State<NotificationPermissionWidget> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final pushPrefs = context.watch<PushPreferencesNotifier>();
    final appState = FFAppState();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reste informé',
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily: 'Manrope',
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 24.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 72.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Active les notifications',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: 'Manrope',
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Sois averti immédiatement quand une sanction est infligée sur ton compte. '
                        'Tu pourras ainsi réagir plus vite et rester à jour sur les décisions de la Blackbox.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Manrope',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!pushPrefs.pluginAvailable)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      'Réinstalle l’application ou redémarre ton appareil pour activer les notifications.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Manrope',
                            color: FlutterFlowTheme.of(context).error,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                FFButtonWidget(
                  onPressed: _processing || !pushPrefs.pluginAvailable
                      ? null
                      : () async {
                          await _handleEnableNotifications(pushPrefs, appState);
                        },
                  text: 'Activer les notifications',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleMedium
                        .override(
                          fontFamily: 'Manrope',
                          color:
                              FlutterFlowTheme.of(context).primaryTextInverse,
                          letterSpacing: 0.0,
                        ),
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  showLoadingIndicator: true,
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Plus tard',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            fontFamily: 'Manrope',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleEnableNotifications(
    PushPreferencesNotifier pushPrefs,
    FFAppState appState,
  ) async {
    if (_processing) {
      return;
    }
    setState(() => _processing = true);

    final granted = await NotificationPermissionWidget.requestPermission(
      context,
    );

    if (!mounted) {
      return;
    }

    if (granted) {
      Navigator.of(context).pop(true);
    }

    if (mounted) {
      setState(() => _processing = false);
    }
  }
}

Future<void> _showNotificationSettingsDialog(BuildContext context) async {
  if (!context.mounted) {
    return;
  }
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Notifications désactivées'),
        content: const Text(
          'Active les notifications depuis les Réglages pour recevoir les alertes de sanction.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Plus tard'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _openSystemNotificationSettings();
            },
            isDefaultAction: true,
            child: const Text('Ouvrir les réglages'),
          ),
        ],
      ),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Notifications désactivées'),
      content: const Text(
        'Active les notifications depuis les réglages pour recevoir les alertes de sanction.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Plus tard'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            _openSystemNotificationSettings();
          },
          child: const Text('Ouvrir les réglages'),
        ),
      ],
    ),
  );
}

Future<void> _openSystemNotificationSettings() async {
  if (kIsWeb) {
    return;
  }
  final uri = defaultTargetPlatform == TargetPlatform.iOS
      ? Uri.parse('app-settings:')
      : Uri.parse('app-settings:');
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) {
    debugPrint('Impossible d\'ouvrir les réglages.');
  }
}
