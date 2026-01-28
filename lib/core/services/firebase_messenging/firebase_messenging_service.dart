import 'dart:convert';
import 'dart:developer';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  final _firestore = FirebaseFirestore.instance;

  Future<void> init({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _requestPermission(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _requestPermission({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final status = result.authorizationStatus;

      if (status == AuthorizationStatus.denied) {
        logWarning('User denied notification permission');

        AppToast.show(
          "Notifications are disabled. Enable them from Settings to stay updated.",
          ToastType.warning,
        );

        await openAppSettings();
        return;
      }

      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional) {
        await _initFirebaseMessaging(
          result,
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
      } else if (status == AuthorizationStatus.notDetermined) {
        logWarning('Permission not determined. Prompting again...');
        await openAppSettings();
      } else {
        logWarning('Unexpected authorization status: $status');
      }
    } catch (e, st) {
      debugPrint('Error requesting notification permission: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> _initFirebaseMessaging(
    NotificationSettings settings, {
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      if (Platform.isIOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          // logSuccess('APNS token: $apnsToken');
        } else {
          logWarning('APNS token not available.');
        }
      }

      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        // logSuccess('FCM token: $fcmToken');
        await _saveOrUpdateUserToken(
          userId: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          token: fcmToken,
        );
      }

      messaging.onTokenRefresh.listen((newToken) async {
        await _updateUserToken(userId: userId, token: newToken);
      });
    } catch (e, st) {
      debugPrint(st.toString());
    }
  }

  Future<void> _saveOrUpdateUserToken({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String token,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await userRef.get();

      if (docSnapshot.exists) {
        await userRef.update({
          'user_device_token': token,
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        final data = {
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'user_device_token': token,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await userRef.set(data);
      }
    } catch (e, st) {
      debugPrint(st.toString());
    }
  }

  Future<void> _updateUserToken({
    required String userId,
    required String token,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'user_device_token': token,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      debugPrint('Failed to update user token: $e');
      debugPrint(st.toString());
    }
  }

  void _onMessageReceived(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      log("Message Received: ${notification.title}");
      log("Message Received: ${notification.body}");
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    } else if (message.data.isNotEmpty) {
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'New Update',
        body: message.data['body'] ?? 'You have a new update',
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final notification = message.notification;
    if (notification != null) {
      await NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? 'Background Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
    // ignore: empty_catches
  } catch (e) {}
}
