import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'firebase_config.dart';
import 'push_notification_controller.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();
  debugPrint('Handled background message ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final PushNotificationsGateway _gateway =
      PushNotificationController.instance;

  static Future<bool> initialize({required bool enabled}) =>
      _gateway.initialize(enabled);

  static Future<bool> enableNotifications() => _gateway.enable();

  static Future<void> disableNotifications() => _gateway.disable();

  static Future<void> dispose() => _gateway.dispose();

  static bool get pluginAvailable => _gateway.pluginAvailable;
}
