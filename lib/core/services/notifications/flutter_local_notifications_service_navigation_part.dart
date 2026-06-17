// ignore_for_file: use_build_context_synchronously
part of 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  localNotificationHandleNotificationTap(response.payload);
}

void localNotificationHandleNotificationTap(String? payload) async {
  devLog("firebase push notification: payload, $payload");
  if (payload == null) return;

  final Map<String, dynamic> data = jsonObjectFromResponseData(
    jsonDecode(payload),
  );
  devLog("notification deep link: $data");
  final String kitchenId = readJsonString(data, 'kitchenId');
  final String invitationCode = readJsonString(data, 'invitationCode');
  final String kitchenName = readJsonString(data, 'kitchenName');
  final String role = readJsonString(data, 'role');
  final String status = readJsonString(data, 'status');
  final String recipeId = readJsonString(data, 'recipeId');

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    bool isLoggedIn = _localNotifIsUserLoggedIn();
    if (isLoggedIn == false) {
      context.go(Routes.signIn);
      return;
    }
    if (status == "Declined") {
      context.go(Routes.splash);
      return;
    }
    await _localNotifHandlePostNavigationLogic(
      context,
      kitchenId,
      invitationCode,
      kitchenName,
      role,
      status,
    );

    final String notifType = readJsonString(data, 'type');
    if (notifType == "low_stock" || notifType == "expiring_soon") {
      final Map<String, dynamic> itemMap = jsonObjectFromResponseData(
        data['item'],
      );
      context.goNamed(
        Routes.myPantry,
        extra: {
          "type": notifType,
          "item_id": readJsonString(itemMap, 'itemId'),
        },
      );
    } else if (notifType == "meal_plan_reminder") {
      context.goNamed(
        Routes.dashboard,
        extra: {
          'fromNotification': true,
          'entryType': DashboardEntryType.planner,
        },
      );
    } else if (status == "start_recipe_request") {
      context.goNamed(
        Routes.recipeRequestsDetail,
        extra: {
          "recipeId": recipeId,
          "kitchenId": kitchenId,
          "backPageAvailable": false,
        },
      );
    } else if (notifType == "kitchens_notification" && status != "Declined") {
      context.go(Routes.notification);
    } else if (notifType == "kitchens_notification" && status == "Declined") {
      context.go(Routes.splash);
    }
  });
}

bool _localNotifIsUserLoggedIn() {
  final prefs = sl<SharedPreferences>();
  final token = prefs.getString('access-token');
  return token != null && token.isNotEmpty;
}

Future<void> _localNotifHandlePostNavigationLogic(
  BuildContext context,
  String kitchenId,
  String invitationCode,
  String kitchenName,
  String role,
  String status,
) async {
  final prefs = sl<SharedPreferences>();
  await prefs.setString("kitchen_id", kitchenId);
  await prefs.setString("role", role);
  await prefs.setString("invitation_code", invitationCode);

  context.read<UserCubit>().updateActiveKitchenIdInvitationCodeAndRole(
    kitchenName: kitchenName,
    activeKitchenId: kitchenId,
    invitationCode: invitationCode,
    role: role,
  );
  await context.read<UserCubit>().setUser();

  context.read<ConsumptionBloc>().add(
    GetConsumptionConfirmationPendingCountEvent(kitchenId: kitchenId),
  );

  await context.read<UserCubit>().getUserStorageArea(kitchenId: kitchenId);

  context.read<KitchenBloc>().add(
    SwitchKitchenEvent(
      Kitchen(
        invitationCode: invitationCode,
        kitchenId: kitchenId,
        kitchenName: kitchenName,
        role: role,
      ),
    ),
  );
}

bool pendingNavigation = true;
