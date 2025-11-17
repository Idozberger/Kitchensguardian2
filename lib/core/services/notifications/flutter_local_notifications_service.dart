import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init({
    Function(NotificationResponse)? onNotificationResponse,
  }) async {
    await _requestPermissions();
    tz.initializeTimeZones();

    final NotificationAppLaunchDetails? launchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null) {
        _handleNotificationPayload(payload);
      }
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

  void _handleNotificationPayload(String payload) {
    try {
      log('Navigating to Recipe Details with payload: $payload');
      final context = rootNavigatorKey.currentContext;

      if (context != null) {
        context.go(Routes.notification);
      } else {}
    } catch (e, st) {
      log('$st');
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
        debugPrint("iOS Notification Permission Granted");
      } else {
        debugPrint("iOS Notification Permission Denied");
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
          debugPrint("Android Notification Permission Granted");
        } else {
          debugPrint("Android Notification Permission Denied");
        }
      } else {
        debugPrint("Android Notification Permission Already Granted");
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'main_channel_id',
          'Main Channel',
          channelDescription: 'General notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          ongoing: true,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledDateTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'scheduled_channel_id',
          'Scheduled Channel',
          channelDescription: 'Scheduled notifications channel',
          importance: Importance.max,
          priority: Priority.high,
        );
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      platformDetails,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleEveryMinute({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime nextSecond = now.add(const Duration(seconds: 1));

    await scheduleDaily(
      id: id,
      title: title,
      body: body,
      dailyTime: nextSecond,
      payload: payload,
    );
  }

  Future<bool> isExactAlarmAllowed() async {
    final androidPlugin = NotificationService._flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await androidPlugin?.canScheduleExactNotifications() ?? false;
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required DateTime dailyTime,
    String? payload,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dailyTime.hour,
      dailyTime.minute,
      dailyTime.second,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDateTime: scheduledDate,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  _handleNotificationTap(response.payload);
}

void _handleNotificationTap(String? payload) {
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    context.go(Routes.notification);
  } else {}
}

bool pendingNavigation = true;
