// ignore_for_file: use_build_context_synchronously
// Notification tap handlers navigate after async plugin work.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

part 'flutter_local_notifications_service_impl_part.dart';
part 'flutter_local_notifications_service_impl_part2.dart';
part 'flutter_local_notifications_service_navigation_part.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init({
    void Function(NotificationResponse)? onNotificationResponse,
  }) async {
    await _requestPermissions();
    tz.initializeTimeZones();

    final NotificationAppLaunchDetails? launchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      devLog(
        "firebase push notification: payload, ${launchDetails!.notificationResponse?.payload}",
      );
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null) {
        _handleNotificationPayload(payload);
      }
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
    );
  }

  void _handleNotificationPayload(String payload) async {
    try {
      devLog('Navigating to Recipe Details with payload: $payload');

      localNotificationHandleNotificationTap(payload);
    } catch (e, st) {
      devLog('$st');
    }
  }

  Future<void> requestPermission() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      bool? permissionGranted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      if (permissionGranted != null && permissionGranted) {
        devPrint("iOS Notification Permission Granted");
      } else {
        devPrint("iOS Notification Permission Denied");
      }
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool hasPermission =
          await androidImplementation?.areNotificationsEnabled() ?? false;

      if (!hasPermission) {
        final bool? grantedNotificationPermission = await androidImplementation
            ?.requestNotificationsPermission();

        if (grantedNotificationPermission == true) {
          devPrint("Android Notification Permission Granted");
        } else {
          devPrint("Android Notification Permission Denied");
        }
      } else {
        devPrint("Android Notification Permission Already Granted");
      }
    }
  }

  Future<void> showTestNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) => _notifShowTestNotification(
    this,
    id: id,
    title: title,
    body: body,
    payload: payload,
  );

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) => _notifShowNotification(
    this,
    id: id,
    title: title,
    body: body,
    payload: payload,
  );

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) => _notifScheduleNotification(
    this,
    id: id,
    title: title,
    body: body,
    scheduledDateTime: scheduledDateTime,
    payload: payload,
  );

  Future<void> scheduleEveryMinute({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) => _notifScheduleEveryMinute(
    this,
    id: id,
    title: title,
    body: body,
    payload: payload,
  );

  Future<bool> isExactAlarmAllowed() => _notifIsExactAlarmAllowed(this);

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required DateTime dailyTime,
    String? payload,
  }) => _notifScheduleDaily(
    this,
    id: id,
    title: title,
    body: body,
    dailyTime: dailyTime,
    payload: payload,
  );

  Future<void> scheduleMealPlanReminders(
    List<MergedRecipePlanEntity> plans,
    Map<String, dynamic> data,
  ) => _notifScheduleMealPlanReminders(this, plans, data);

  Future<void> cancelNotification(int id) => _notifCancelNotification(this, id);

  Future<void> cancelAllNotifications() => _notifCancelAllNotifications(this);

  Future<List<PendingNotificationRequest>> pendingNotifications() =>
      _notifPendingNotifications(this);
}
