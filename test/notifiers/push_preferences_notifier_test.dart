import 'package:flutter_test/flutter_test.dart';

import 'package:blackbox/backend/firebase/push_notification_controller.dart';
import 'package:blackbox/notifiers/push_preferences_notifier.dart';

class FakePushGateway implements PushNotificationsGateway {
  @override
  bool pluginAvailable = true;

  bool initializeResult = true;
  bool enableResult = true;

  int initializeCalls = 0;
  int enableCalls = 0;
  int disableCalls = 0;
  bool lastInitializeArgument = false;

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> enable() async {
    enableCalls++;
    return enableResult;
  }

  @override
  Future<void> disable() async {
    disableCalls++;
  }

  @override
  Future<bool> initialize(bool enabled) async {
    initializeCalls++;
    lastInitializeArgument = enabled;
    return initializeResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePushGateway gateway;
  late List<bool> persistedValues;

  PushPreferencesNotifier buildNotifier({bool initialEnabled = true}) {
    gateway = FakePushGateway();
    persistedValues = [];
    final notifier = PushPreferencesNotifier(
      initialEnabled: initialEnabled,
      onPersist: persistedValues.add,
      gateway: gateway,
    );
    return notifier;
  }

  Future<void> settleNotifier() async {
    await pumpEventQueue();
  }

  test('initializes gateway with current value', () async {
    final notifier = buildNotifier(initialEnabled: true);
    gateway.initializeResult = false;

    await settleNotifier();

    expect(gateway.initializeCalls, 1);
    expect(gateway.lastInitializeArgument, true);
    expect(notifier.enabled, false);
    expect(persistedValues, [false]);
  });

  test('enable updates state when gateway succeeds', () async {
    final notifier = buildNotifier(initialEnabled: false);
    await settleNotifier();

    gateway.enableResult = true;
    final changed = await notifier.setEnabled(true);

    expect(changed, true);
    expect(notifier.enabled, true);
    expect(persistedValues.last, true);
    expect(gateway.enableCalls, 1);
  });

  test('enable returns false when gateway denies permission', () async {
    final notifier = buildNotifier(initialEnabled: false);
    await settleNotifier();

    gateway.enableResult = false;
    final changed = await notifier.setEnabled(true);

    expect(changed, false);
    expect(notifier.enabled, false);
    expect(persistedValues, isEmpty);
  });

  test('disable routes through gateway and persists', () async {
    final notifier = buildNotifier(initialEnabled: true);
    await settleNotifier();

    final changed = await notifier.setEnabled(false);

    expect(changed, true);
    expect(notifier.enabled, false);
    expect(gateway.disableCalls, 1);
    expect(persistedValues.last, false);
  });

  test('pluginAvailable proxies gateway value', () {
    final notifier = buildNotifier(initialEnabled: true);
    gateway.pluginAvailable = false;
    expect(notifier.pluginAvailable, false);
  });
}
