// ignore_for_file: use_build_context_synchronously
part of 'package:foodkitchen/core/services/firebase_messenging/firebase_messenging_service.dart';

void _fcmHandleNotificationTap(Map<String, dynamic>? data) async {
  if (data == null) return;

  devLog("notification deep link: $data");
  final String kitchenId = readJsonString(data, 'kitchenId');
  final String invitationCode = readJsonString(data, 'invitationCode');
  final String kitchenName = readJsonString(data, 'kitchenName');
  final String role = readJsonString(data, 'role');

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    bool isLoggedIn = _fcmIsUserLoggedIn();
    if (isLoggedIn == false) {
      context.go(Routes.signIn);
      return;
    }
    await _fcmHandlePostNavigationLogic(
      context,
      kitchenId,
      invitationCode,
      kitchenName,
      role,
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
    } else if (notifType == "kitchens_notification") {
      context.go(Routes.notification);
    }
  });
}

bool _fcmIsUserLoggedIn() {
  final prefs = sl<SharedPreferences>();
  final token = prefs.getString('access-token');
  return token != null && token.isNotEmpty;
}

Future<void> _fcmHandlePostNavigationLogic(
  BuildContext context,
  String kitchenId,
  String invitationCode,
  String kitchenName,
  String role,
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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Top-level handler must exist for FCM; display logic intentionally disabled here (foreground/tap paths handle UX).
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
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
