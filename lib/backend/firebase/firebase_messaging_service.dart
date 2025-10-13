import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'firebase_config.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();
  debugPrint('Handled background message ${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static bool _listenersAttached = false;
  static bool _pluginAvailable = true;

  static Future<bool> initialize({required bool enabled}) async {
    await _setAutoInitEnabled(enabled);
    _attachListeners();

    if (!enabled || !_pluginAvailable) {
      await _cancelTokenRefresh();
      return false;
    }

    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _messaging.setAutoInitEnabled(false);
      await _cancelTokenRefresh();
    }
    return granted;
  }

  static Future<bool> enableNotifications() async {
    final autoInitSet = await _setAutoInitEnabled(true);
    if (!autoInitSet || !_pluginAvailable) {
      return false;
    }
    _attachListeners();
    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _setAutoInitEnabled(false);
    }
    return granted;
  }

  static Future<void> disableNotifications() async {
    await _setAutoInitEnabled(false);
    if (!_pluginAvailable) {
      return;
    }
    await _cancelTokenRefresh();
    try {
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (error) {
      debugPrint('Unable to delete FCM token: $error');
    }
  }

  static Future<void> dispose() async {
    await _cancelTokenRefresh();
  }

  static void _attachListeners() {
    if (_listenersAttached) {
      return;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Foreground message received: ${message.messageId ?? 'no-id'} ${message.notification?.title ?? ''}',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.messageId ?? 'no-id'}');
    });

    _listenersAttached = true;
  }

  static Future<bool> _ensurePermissionsAndToken() async {
    if (!_supportsNativeMessaging || !_pluginAvailable) {
      debugPrint('Firebase Messaging not available on this platform/runtime');
      return false;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!authorized) {
      return false;
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM token: $token');
    }

    _tokenRefreshSubscription ??=
        _messaging.onTokenRefresh.listen((String newToken) {
      debugPrint('FCM token refreshed: $newToken');
    });

    return true;
  }

  static Future<void> _cancelTokenRefresh() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  static Future<bool> _setAutoInitEnabled(bool enabled) async {
    if (!_supportsNativeMessaging) {
      return true;
    }
    try {
      await _messaging.setAutoInitEnabled(enabled);
      _pluginAvailable = true;
      return true;
    } on MissingPluginException catch (error) {
      debugPrint('FirebaseMessaging plugin not registered: $error');
      _pluginAvailable = false;
      return false;
    } catch (error) {
      debugPrint('Unable to toggle auto init: $error');
      return false;
    }
  }

  static bool get _supportsNativeMessaging =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  static bool get pluginAvailable => _pluginAvailable;
}
