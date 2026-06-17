part of 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';

Future<void> _notifShowTestNotification(
  NotificationService _, {
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  try {
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

    await NotificationService._flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  } catch (e) {
    devPrint('Error showing notification: $e');
  }
}

Future<void> _notifShowNotification(
  NotificationService _, {
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  try {
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

    await NotificationService._flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  } catch (e) {
    devPrint('Error showing notification: $e');
  }
}

Future<void> _notifScheduleNotification(
  NotificationService _, {
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

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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

  await NotificationService._flutterLocalNotificationsPlugin.zonedSchedule(
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

Future<void> _notifScheduleEveryMinute(
  NotificationService svc, {
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  final DateTime now = DateTime.now();

  final DateTime nextSecond = now.add(const Duration(seconds: 1));

  await _notifScheduleDaily(
    svc,
    id: id,
    title: title,
    body: body,
    dailyTime: nextSecond,
    payload: payload,
  );
}

Future<bool> _notifIsExactAlarmAllowed(NotificationService _) async {
  final androidPlugin = NotificationService._flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  return await androidPlugin?.canScheduleExactNotifications() ?? false;
}

Future<void> _notifScheduleDaily(
  NotificationService svc, {
  required int id,
  required String title,
  required String body,
  required DateTime dailyTime,
  String? payload,
}) async {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  tz.TZDateTime scheduledDate;

  scheduledDate = tz.TZDateTime(
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

  await _notifScheduleNotification(
    svc,
    id: id,
    title: title,
    body: body,
    scheduledDateTime: scheduledDate,
    payload: payload,
  );
}
