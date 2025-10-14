import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef _LocaleResolver = Locale Function();

abstract class PushNotificationsGateway {
  bool get pluginAvailable;

  Future<bool> initialize(bool enabled);

  Future<bool> enable();

  Future<void> disable();

  Future<void> dispose();
}

class PushNotificationController implements PushNotificationsGateway {
  PushNotificationController._({
    FirebaseMessaging? messaging,
    PushPermissionManager? permissionManager,
    PushTokenRepository? tokenRepository,
    _LocaleResolver? localeResolver,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _permissionManager = permissionManager ??
            PushPermissionManager(messaging ?? FirebaseMessaging.instance),
        _tokenRepository =
            tokenRepository ?? PushTokenRepository(Supabase.instance.client),
        _localeResolver =
            localeResolver ?? PushNotificationController._defaultLocaleResolver;

  static final PushNotificationController instance =
      PushNotificationController._();

  final FirebaseMessaging _messaging;
  final PushPermissionManager _permissionManager;
  final PushTokenRepository _tokenRepository;
  final _LocaleResolver _localeResolver;

  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _listenersAttached = false;
  bool _pluginAvailable = true;

  static Locale _defaultLocaleResolver() =>
      WidgetsBinding.instance.platformDispatcher.locale;

  @override
  bool get pluginAvailable => _pluginAvailable;

  @override
  Future<bool> initialize(bool enabled) async {
    _pluginAvailable = await _permissionManager.setAutoInitEnabled(enabled);
    _attachListeners();

    if (!enabled || !_pluginAvailable) {
      await _cancelTokenRefresh();
      await _tokenRepository.disable(platform: _currentPlatformLabel);
      return false;
    }

    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _permissionManager.setAutoInitEnabled(false);
      await _cancelTokenRefresh();
      await _tokenRepository.disable(platform: _currentPlatformLabel);
    }
    return granted;
  }

  @override
  Future<bool> enable() async {
    _pluginAvailable = await _permissionManager.setAutoInitEnabled(true);
    if (!_pluginAvailable) {
      await _tokenRepository.disable(platform: _currentPlatformLabel);
      return false;
    }
    _attachListeners();
    final granted = await _ensurePermissionsAndToken();
    if (!granted) {
      await _permissionManager.setAutoInitEnabled(false);
      await _tokenRepository.disable(platform: _currentPlatformLabel);
    }
    return granted;
  }

  @override
  Future<void> disable() async {
    await _permissionManager.setAutoInitEnabled(false);
    await _cancelTokenRefresh();
    try {
      final existingToken = await _permissionManager.fetchToken();
      await _permissionManager.deleteToken();
      await _tokenRepository.disable(
        platform: _currentPlatformLabel,
        token: existingToken,
      );
    } on MissingPluginException catch (error) {
      debugPrint('Firebase plugin not available during disable: $error');
    } catch (error) {
      debugPrint('Unable to delete FCM token: $error');
    }
  }

  @override
  Future<void> dispose() async {
    await _cancelTokenRefresh();
  }

  Future<bool> _ensurePermissionsAndToken() async {
    if (!_supportsNativeMessaging || !_pluginAvailable) {
      debugPrint('Firebase Messaging not available on this platform/runtime');
      return false;
    }

    final authorizationStatus = await _permissionManager.requestPermission();
    debugPrint('Notification permission: $authorizationStatus');

    final authorized = authorizationStatus == AuthorizationStatus.authorized ||
        authorizationStatus == AuthorizationStatus.provisional;
    if (!authorized) {
      return false;
    }

    await _permissionManager.ensureForegroundPresentation();

    final token = await _permissionManager.fetchToken();
    if (token != null) {
      await _tokenRepository.save(
        token: token,
        platform: _currentPlatformLabel,
        locale: _localeResolver().toLanguageTag(),
        enabled: true,
      );
    }

    _tokenRefreshSubscription ??=
        _messaging.onTokenRefresh.listen((String newToken) async {
      debugPrint('FCM token refreshed: $newToken');
      await _tokenRepository.save(
        token: newToken,
        platform: _currentPlatformLabel,
        locale: _localeResolver().toLanguageTag(),
        enabled: true,
      );
    });

    return true;
  }

  void _attachListeners() {
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

  Future<void> _cancelTokenRefresh() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  static bool get _supportsNativeMessaging =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

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
}

class PushPermissionManager {
  PushPermissionManager(this._messaging);

  final FirebaseMessaging _messaging;

  Future<bool> setAutoInitEnabled(bool enabled) async {
    try {
      await _messaging.setAutoInitEnabled(enabled);
      return true;
    } on MissingPluginException catch (error) {
      debugPrint('FirebaseMessaging plugin not registered: $error');
      return false;
    } catch (error) {
      debugPrint('Unable to toggle auto init: $error');
      return false;
    }
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus;
  }

  Future<void> ensureForegroundPresentation() =>
      _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

  Future<String?> fetchToken() => _messaging.getToken();

  Future<void> deleteToken() => _messaging.deleteToken();
}

class PushTokenRepository {
  PushTokenRepository(this._client);

  final SupabaseClient _client;

  User? get _user => _client.auth.currentUser;

  Future<void> save({
    required String token,
    required String platform,
    required String? locale,
    required bool enabled,
  }) async {
    final user = _user;
    if (user == null) {
      return;
    }

    final payload = {
      'user_id': user.id,
      'token': token,
      'platform': platform,
      'enabled': enabled,
      'locale': locale,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _client.from('user_push_tokens').upsert(
            payload,
            onConflict: 'token',
          );
    } catch (error) {
      debugPrint('Failed to sync push token: $error');
    }
  }

  Future<void> disable({
    required String platform,
    String? token,
  }) async {
    final user = _user;
    if (user == null) {
      return;
    }

    final updatePayload = {
      'enabled': false,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      var query = _client
          .from('user_push_tokens')
          .update(updatePayload)
          .eq('user_id', user.id);
      if (token != null) {
        query = query.eq('token', token);
      } else {
        query = query.eq('platform', platform);
      }
      await query;
    } catch (error) {
      debugPrint('Failed to disable stored push tokens: $error');
    }
  }
}
