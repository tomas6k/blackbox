import 'package:flutter/foundation.dart';

import '../app_state.dart';
import '../backend/firebase/push_notification_controller.dart';

class PushPreferencesNotifier extends ChangeNotifier {
  PushPreferencesNotifier(
    this._appState, {
    PushNotificationsGateway? gateway,
  }) : _gateway = gateway ?? PushNotificationController.instance {
    _enabled = _appState.notificationsEnabled;
    Future.microtask(_bootstrap);
  }

  final FFAppState _appState;
  final PushNotificationsGateway _gateway;

  bool _enabled = true;
  bool get enabled => _enabled;

  bool get pluginAvailable => _gateway.pluginAvailable;

  Future<void> _bootstrap() async {
    final success = await _gateway.initialize(_enabled);
    if (!success && _enabled) {
      _updateState(false);
    }
  }

  Future<bool> setEnabled(bool value) async {
    if (value == _enabled) {
      return true;
    }
    if (value) {
      final granted = await _gateway.enable();
      if (!granted) {
        return false;
      }
      _updateState(true);
      return true;
    } else {
      await _gateway.disable();
      _updateState(false);
      return true;
    }
  }

  void _updateState(bool value) {
    _enabled = value;
    _appState.update(() {
      _appState.notificationsEnabled = value;
    });
    notifyListeners();
  }
}
