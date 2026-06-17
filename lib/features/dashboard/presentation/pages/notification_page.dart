import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/navigation/paywall_navigation.dart';
import 'package:foodkitchen/core/navigation/router_navigation.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/dashboard_notifications_firestore_datasource.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/user_information_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/kitchen_join_notification_card.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/notification_list_filter.dart';
import 'package:lottie/lottie.dart';

class NotificationPage extends StatefulWidget {
  final bool showAppbar;
  final bool shouldFetchMembers;
  const NotificationPage({
    super.key,
    this.showAppbar = true,
    this.shouldFetchMembers = true,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final UserCubit _userCubit;
  late final DashboardBloc _dashboardBloc;
  late final Stream<List<Map<String, dynamic>>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _dashboardBloc = context.read<DashboardBloc>();
    _notificationsStream = sl<DashboardNotificationsFirestoreDatasource>()
        .watchNotificationsForHost(_userCubit.state.userId);
    if (widget.shouldFetchMembers) getAllKitchenMembers();
    devLog("User id ${_userCubit.state.userId}");
  }

  void getAllKitchenMembers() async {
    _dashboardBloc.add(
      GetKitchenMembersEvent(
        activeKitchenId: context.read<UserCubit>().state.activeKitchenId,
      ),
    );
  }

  void _navigateUserDetails(String senderId, String kitchenId, bool isLocked) {
    if (isLocked) {
      openPaywallIfEnabled(context);
      AppToast.show(
        "You have reached the limit of users in this kitchen. Upgrade to add more people.",
        ToastType.warning,
        gravity: ToastGravity.TOP,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => UserPage(senderUserId: senderId, kitchenId: kitchenId),
      ),
    );
  }

  void _handleBackNavigation() {
    goNamedAfterFrame(
      name: Routes.dashboard,
      extra: {
        'fromNotification': false,
        'entryType': DashboardEntryType.normal,
      },
      isPageMounted: () => mounted,
      pageContext: () => context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardFailure) {
          getAllKitchenMembers();
        } else if (state is DashboardSuccess) {
          getAllKitchenMembers();
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop) {
              await Future<void>.delayed(Duration.zero);
              _handleBackNavigation();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: widget.showAppbar ? _buildAppBar(context) : null,
            body: (_dashboardBloc.state is DashboardLoading)
                ? Center(child: Lottie.asset("assets/lotties/loader.json"))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _notificationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final filtered = snapshot.hasData
                          ? filterNotificationsByActiveKitchen(
                              snapshot.data!,
                              _userCubit.state.activeKitchenId,
                            )
                          : <Map<String, dynamic>>[];

                      if (filtered.isEmpty && widget.showAppbar) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No notifications yet",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: gapSymmetric(horizontal: 12, vertical: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> data = filtered[index];

                          final currentStatus = readJsonString(
                            data,
                            'kitchen_joining_status',
                          );

                          final isPremium = context
                              .read<UserCubit>()
                              .state
                              .hasPremiumAccess;
                          final state = context.watch<DashboardBloc>().state;
                          int membersCount = 0;

                          if (state is DashboardLoaded) {
                            membersCount = state.kitchenMembers.length;
                          }
                          final isLocked =
                              !isPremium &&
                              membersCount >= 4 &&
                              currentStatus == 'Pending';

                          final Object? idRaw = data['id'];
                          final int notifId = idRaw is int
                              ? idRaw
                              : int.tryParse(idRaw?.toString() ?? '') ?? 0;
                          final String date = readJsonString(data, 'date');

                          return KitchenJoinNotificationCard(
                            id: notifId,
                            kitchenId: readJsonString(data, 'kitchen_id'),
                            title: readJsonString(data, 'title'),
                            senderName: readJsonString(data, 'sender_name'),
                            senderUserId: readJsonString(
                              data,
                              'sender_user_id',
                            ),
                            body: readJsonString(data, 'body'),
                            date: date,
                            joiningStatus: readJsonString(
                              data,
                              'kitchen_joining_status',
                              fallback: 'Pending',
                            ),
                            isActioned: readJsonBool(data, 'status'),
                            isApproveLoading:
                                state is ApproveLoading && state.id == date,
                            isDeclineLoading:
                                state is DeclineLoading && state.id == date,
                            onTap: () => _navigateUserDetails(
                              readJsonString(data, 'sender_user_id'),
                              readJsonString(data, 'kitchen_id'),
                              isLocked,
                            ),
                            onApprove: () => context.read<DashboardBloc>().add(
                              ApproveRequestEvent(
                                date: date,
                                id: notifId,
                                kitchenId: readJsonString(data, 'kitchen_id'),
                                memberId: readJsonString(
                                  data,
                                  'sender_user_id',
                                ),
                              ),
                            ),
                            onDecline: () => context.read<DashboardBloc>().add(
                              DeclineRequestEvent(
                                date: date,
                                id: notifId,
                                kitchenId: readJsonString(data, 'kitchen_id'),
                                memberId: readJsonString(
                                  data,
                                  'sender_user_id',
                                ),
                              ),
                            ),
                            isLocked: isLocked,
                          );
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: _handleBackNavigation,
          ),
        ],
      ),
      title: Text(
        "Notifications",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
