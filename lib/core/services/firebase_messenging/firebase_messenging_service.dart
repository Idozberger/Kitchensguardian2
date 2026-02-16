import 'dart:convert';
import 'dart:developer';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
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
    required BuildContext context,
  }) async {
    await _requestPermission(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      context: context,
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
    required BuildContext context,
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

        // Show dialog instead of toast
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return NotificationPermissionDialog(
                onOpenSettings: () {
                  Navigator.of(dialogContext).pop();
                  openAppSettings();
                },
                onCancel: () {
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          );
        }
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

        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return NotificationPermissionDialog(
                onOpenSettings: () {
                  Navigator.of(dialogContext).pop();
                  openAppSettings();
                },
                onCancel: () {
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          );
        }
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
      if (message.data.isNotEmpty) {
        log('Payload data: ${message.data}');
        log('Type: ${message.data['type']}');
        log('Kitchen ID: ${message.data['kitchenId']}');
      }
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

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;

  const NotificationPermissionDialog({
    super.key,
    required this.onOpenSettings,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GenericDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: gapAll(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.primaryColor,
            ),
          ),

          gapVertical(20),

          Text(
            'Enable Notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          gapVertical(12),

          Text(
            'Enable notifications to receive important updates about your items expiring, kitchen join, and more.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          gapVertical(24),

          Row(
            children: [
              Expanded(
                child: GenericButtonWidget(
                  onPressed: onCancel,
                  text: "Cancel",
                  isOutlined: true,
                ),
              ),

              gapHorizontal(12),

              Expanded(
                child: GenericButtonWidget(
                  onPressed: onOpenSettings,
                  text: "Open Settings",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
