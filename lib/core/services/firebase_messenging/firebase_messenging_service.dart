import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService.instance() => _instance;

  Future<void> init() async {
    _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _initFirebaseMessaging(NotificationSettings settings) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      logWarning('Notification permission denied');
      return;
    }

    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        logWarning('APNS token not available after waiting');
        return;
      } else {
        logSuccess('APNS token: $apnsToken');
      }
    }

    String? fcmToken = await messaging.getToken();
    logSuccess('FCM token: $fcmToken');

    messaging.onTokenRefresh.listen((newToken) {
      logSuccess('FCM token refreshed: $newToken');
    });
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AuthorizationStatus status = result.authorizationStatus;
    if (status == AuthorizationStatus.denied) {
      return;
    }

    if (status == AuthorizationStatus.authorized) {
      _initFirebaseMessaging(result);
    } else {
      if (status == AuthorizationStatus.notDetermined) {
        await openAppSettings();
      } else {
        await _requestPermission();
      }
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    logInfo('Notification caused the app to open: ${message.data.toString()}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logInfo('Background message received: ${message.data.toString()}');
}
