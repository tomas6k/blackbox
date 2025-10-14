import 'package:flutter/foundation.dart';

import '../app_state.dart';
import '../backend/firebase/push_notification_controller.dart';

class PushPreferencesNotifier extends ChangeNotifier {
  PushPreferencesNotifier({
    required bool initialEnabled,
    required ValueChanged<bool> onPersist,
    PushNotificationsGateway? gateway,
  })  : _enabled = initialEnabled,
        _persist = onPersist,
        _gateway = gateway ?? PushNotificationController.instance {
    Future.microtask(_bootstrap);
  }

  factory PushPreferencesNotifier.fromAppState(FFAppState appState) {
    return PushPreferencesNotifier(
      initialEnabled: appState.notificationsEnabled,
      onPersist: (value) => appState.update(() {
        appState.notificationsEnabled = value;
      }),
      gateway: PushNotificationController.instance,
    );
  }

  final PushNotificationsGateway _gateway;
  final ValueChanged<bool> _persist;

  bool _enabled;
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
    _persist(value);
    notifyListeners();
  }
}
