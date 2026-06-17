part of 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';

Future<void> _notifScheduleMealPlanReminders(
  NotificationService svc,
  List<MergedRecipePlanEntity> plans,
  Map<String, dynamic> data,
) async {
  final String kitchenId = readJsonString(data, 'kitchenId');
  final String invitationCode = readJsonString(data, 'invitationCode');
  final String kitchenName = readJsonString(data, 'kitchenName');
  final String role = readJsonString(data, 'role');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  int notificationId = plans.first.breakfast != null
      ? plans.first.breakfast!.date.hashCode & 0x7fffffff
      : plans.first.lunch != null
      ? plans.first.lunch!.date.hashCode & 0x7fffffff
      : plans.first.dinner != null
      ? plans.first.dinner!.date.hashCode & 0x7fffffff
      : 0;

  for (var plan in plans) {
    final planDate = DateTime.parse(plan.date);
    final dateOnly = DateTime(planDate.year, planDate.month, planDate.day);

    if (dateOnly.isBefore(today)) continue;

    final isToday = dateOnly.isAtSameMomentAs(today);
    final isTomorrow = dateOnly.isAtSameMomentAs(tomorrow);

    var morningTime = DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      8,
      0,
    );

    if (isToday && morningTime.isBefore(now)) {
      morningTime = morningTime.add(const Duration(days: 1));
    }

    String morningTitle = isToday
        ? "Good Morning! Your Meals Are Today"
        : "Tomorrow: You Have Meals Planned!";
    String morningBody = isToday
        ? "Time to shine in the kitchen! Tap to see your plan."
        : "Get ready! Delicious food awaits you tomorrow.";

    await _notifScheduleNotification(
      svc,
      id: notificationId++,
      title: morningTitle,
      body: morningBody,
      scheduledDateTime: morningTime,
      payload: jsonEncode({
        'type': 'meal_plan_reminder',
        "invitationCode": invitationCode,
        "kitchenName": kitchenName,
        "role": role,
        'kitchenId': kitchenId,
        'item': <String, dynamic>{},
      }),
    );

    if ((isToday || isTomorrow) && _notifHasMissingIngredients(plan)) {
      final shoppingReminderDate = isTomorrow
          ? today
          : today.subtract(const Duration(days: 1));
      final shoppingTime = DateTime(
        shoppingReminderDate.year,
        shoppingReminderDate.month,
        shoppingReminderDate.day,
        18,
        0,
      );

      if (!shoppingTime.isBefore(now)) {
        await _notifScheduleNotification(
          svc,
          id: notificationId++,
          title: isTomorrow
              ? "Buy These Today for Tomorrow's Meals!"
              : "Don't Forget! You Need These for Today's Meals",
          body: _notifMissingItemsText(plan),
          scheduledDateTime: shoppingTime,
          payload: jsonEncode({
            'type': 'meal_plan_reminder',
            "invitationCode": invitationCode,
            "kitchenName": kitchenName,
            "role": role,
            'kitchenId': kitchenId,
            'item': <String, dynamic>{},
          }),
        );

        devLog(
          "Shopping reminder scheduled → ${formatDate(shoppingTime)} 6:00 PM",
        );
      }
    }
  }
  devLog("All smart reminders scheduled!");
}

String _notifMissingItemsText(MergedRecipePlanEntity plan) {
  final List<String> allMissing = [];

  if (plan.breakfast != null && plan.breakfast!.missingIngredients.isNotEmpty) {
    final items = plan.breakfast!.missingIngredients
        .map((i) => i.name)
        .toList();
    allMissing.add("Breakfast:\n${items.map((e) => "• $e").join("\n")}");
  }

  if (plan.lunch != null && plan.lunch!.missingIngredients.isNotEmpty) {
    final items = plan.lunch!.missingIngredients.map((i) => i.name).toList();
    allMissing.add("Lunch:\n${items.map((e) => "• $e").join("\n")}");
  }

  if (plan.dinner != null && plan.dinner!.missingIngredients.isNotEmpty) {
    final items = plan.dinner!.missingIngredients.map((i) => i.name).toList();
    allMissing.add("Dinner:\n${items.map((e) => "• $e").join("\n")}");
  }

  if (allMissing.isEmpty) {
    return "All ingredients are ready! You're all set";
  }

  return allMissing.join("\n\n");
}

bool _notifHasMissingIngredients(MergedRecipePlanEntity plan) {
  return (plan.breakfast?.missingIngredients.isNotEmpty == true) ||
      (plan.lunch?.missingIngredients.isNotEmpty == true) ||
      (plan.dinner?.missingIngredients.isNotEmpty == true);
}

Future<void> _notifCancelNotification(NotificationService _, int id) async {
  await NotificationService._flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> _notifCancelAllNotifications(NotificationService _) async {
  await NotificationService._flutterLocalNotificationsPlugin.cancelAll();
}

Future<List<PendingNotificationRequest>> _notifPendingNotifications(
  NotificationService _,
) async {
  return await NotificationService._flutterLocalNotificationsPlugin
      .pendingNotificationRequests();
}
