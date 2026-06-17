// ignore_for_file: use_build_context_synchronously
// Push notification flows navigate after async Firebase/plugin calls.

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'firebase_messenging_service_part.dart';

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

        if (context.mounted) {
          await showDialog<void>(
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
          await showDialog<void>(
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
      devPrint('Error requesting notification permission: $e');
      devPrint(st.toString());
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
      devPrint(st.toString());
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
      devPrint(st.toString());
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
      devPrint('Failed to update user token: $e');
      devPrint(st.toString());
    }
  }

  void _onMessageReceived(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      devLog("Message Received: ${notification.title}");
      devLog("Message Received: ${notification.body}");
      if (message.data.isNotEmpty) {
        devLog('Payload data: ${message.data}');
        devLog('Type: ${message.data['type']}');
        devLog('Kitchen ID: ${message.data['kitchenId']}');
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
        body: readJsonString(
          Map<String, dynamic>.from(message.data),
          'body',
          fallback: 'You have a new update',
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _fcmHandleNotificationTap(message.data);
  }
}
