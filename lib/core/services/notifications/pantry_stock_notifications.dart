import 'dart:convert';

import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';

Future<void> schedulePantryStockNotifications({
  required UserCubit userCubit,
  required List<PantryItemEntity> lowStockItems,
  required List<PantryItemEntity> expiringItems,
}) async {
  final notificationService = NotificationService();
  final DateTime now = DateTime.now();
  final DateTime morningTime = DateTime(now.year, now.month, now.day, 9, 0);
  final DateTime eveningTime = DateTime(now.year, now.month, now.day, 18, 0);

  final currentItemIds = <int>{};
  for (final item in lowStockItems) {
    currentItemIds.add(item.itemId.hashCode & 0x7fffffff);
    currentItemIds.add((item.itemId.hashCode & 0x7fffffff) + 1);
  }
  for (final item in expiringItems) {
    currentItemIds.add((item.itemId.hashCode & 0x7fffffff) + 100000);
    currentItemIds.add((item.itemId.hashCode & 0x7fffffff) + 100001);
  }

  final pendingNotifications = await notificationService.pendingNotifications();

  for (final pending in pendingNotifications) {
    if (!currentItemIds.contains(pending.id)) {
      await notificationService.cancelNotification(pending.id);
      devPrint("Canceled obsolete notification (ID: ${pending.id})");
    }
  }

  final scheduledIds = pendingNotifications.map((e) => e.id).toSet();
  devPrint("Pending notification IDs: $scheduledIds");

  for (final item in lowStockItems) {
    final int morningId = item.itemId.hashCode & 0x7fffffff;
    final int eveningId = morningId + 1;

    if (!scheduledIds.contains(morningId)) {
      await notificationService.scheduleDaily(
        id: morningId,
        title: 'Low stock: ${item.name}',
        body:
            'You are running low on ${item.name} (${formatQuantity(item.quantity)} ${unitDisplayLabel(item.unit)}).',
        dailyTime: morningTime,
        payload: jsonEncode({
          'type': 'low_stock',
          "invitationCode": userCubit.state.invitationCode,
          "kitchenName": userCubit.state.kitchenName,
          "role": userCubit.state.role,
          'kitchenId': userCubit.state.activeKitchenId,
          'item': item.toMap(),
        }),
      );
      devPrint(
        "Scheduled morning low stock notification for ${item.name} (ID: $morningId)",
      );
    }

    if (!scheduledIds.contains(eveningId)) {
      await notificationService.scheduleDaily(
        id: eveningId,
        title: 'Low stock: ${item.name}',
        body: 'Remember to restock ${item.name}.',
        dailyTime: eveningTime,
        payload: jsonEncode({
          'type': 'low_stock',
          "invitationCode": userCubit.state.invitationCode,
          "kitchenName": userCubit.state.kitchenName,
          "role": userCubit.state.role,
          'kitchenId': userCubit.state.activeKitchenId,
          'item': item.toMap(),
        }),
      );
      devPrint(
        "Scheduled evening low stock notification for ${item.name} (ID: $eveningId)",
      );
    }
  }

  for (final item in expiringItems) {
    final int morningId = (item.itemId.hashCode & 0x7fffffff) + 100000;
    final int eveningId = morningId + 1;

    if (!scheduledIds.contains(morningId)) {
      await notificationService.scheduleDaily(
        id: morningId,
        title: 'Expiring soon: ${item.name}',
        body: '${item.name} is expiring soon (${item.expireDate}).',
        dailyTime: morningTime,
        payload: jsonEncode({
          'type': 'expiring_soon',
          "invitationCode": userCubit.state.invitationCode,
          "kitchenName": userCubit.state.kitchenName,
          "role": userCubit.state.role,
          'kitchenId': userCubit.state.activeKitchenId,
          'item': item.toMap(),
        }),
      );
      devPrint(
        "Scheduled morning expiring notification for ${item.name} (ID: $morningId)",
      );
    }

    if (!scheduledIds.contains(eveningId)) {
      await notificationService.scheduleDaily(
        id: eveningId,
        title: 'Expiring soon: ${item.name}',
        body: 'Use ${item.name} before it expires.',
        dailyTime: eveningTime,
        payload: jsonEncode({
          'type': 'expiring_soon',
          "invitationCode": userCubit.state.invitationCode,
          "kitchenName": userCubit.state.kitchenName,
          "role": userCubit.state.role,
          'kitchenId': userCubit.state.activeKitchenId,
          'item': item.toMap(),
        }),
      );
      devPrint(
        "Scheduled evening expiring notification for ${item.name} (ID: $eveningId)",
      );
    }
  }
}
