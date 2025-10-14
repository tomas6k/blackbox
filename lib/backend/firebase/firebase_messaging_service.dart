import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      await _disableStoredTokens();
      return false;
    }

    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _messaging.setAutoInitEnabled(false);
      await _cancelTokenRefresh();
      await _disableStoredTokens();
    }
    return granted;
  }

  static Future<bool> enableNotifications() async {
    final autoInitSet = await _setAutoInitEnabled(true);
    if (!autoInitSet || !_pluginAvailable) {
      await _disableStoredTokens();
      return false;
    }
    _attachListeners();
    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _setAutoInitEnabled(false);
      await _disableStoredTokens();
    }
    return granted;
  }

  static Future<void> disableNotifications() async {
    await _setAutoInitEnabled(false);
    if (!_pluginAvailable) {
      await _disableStoredTokens();
      return;
    }
    await _cancelTokenRefresh();
    try {
      final existingToken = await _messaging.getToken();
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
      await _disableStoredTokens(token: existingToken);
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
      await _syncToken(token: token, enabled: true);
    }

    _tokenRefreshSubscription ??=
        _messaging.onTokenRefresh.listen((String newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await _syncToken(token: newToken, enabled: true);
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

  static SupabaseClient get _supabase => Supabase.instance.client;

  static String get _currentPlatformLabel {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'unknown';
    }
  }

  static Future<void> _syncToken({
    required String token,
    required bool enabled,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }
    final localeTag = WidgetsBinding.instance.platformDispatcher.locale;
    final payload = {
      'user_id': user.id,
      'token': token,
      'platform': _currentPlatformLabel,
      'enabled': enabled,
      'locale': localeTag != null ? localeTag.toLanguageTag() : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await _supabase
          .from('user_push_tokens')
          .upsert(payload, onConflict: 'token');
    } catch (error) {
      debugPrint('Failed to sync push token: $error');
    }
  }

  static Future<void> _disableStoredTokens({String? token}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }
    final updatePayload = {
      'enabled': false,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      var query = _supabase.from('user_push_tokens').update(updatePayload).eq(
            'user_id',
            user.id,
          );
      if (token != null) {
        query = query.eq('token', token);
      } else {
        query = query.eq('platform', _currentPlatformLabel);
      }
      await query;
    } catch (error) {
      debugPrint('Failed to disable stored push tokens: $error');
    }
  }
}
