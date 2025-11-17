import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/user_information_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late UserCubit userCubit;

  @override
  void initState() {
    userCubit = context.read<UserCubit>();
    log("User id ${userCubit.state.userId}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (_, state) {
        return PopScope(
          canPop: false,
          // ignore: deprecated_member_use
          onPopInvoked: (didPop) async {
            if (!didPop) {
              await Future.delayed(Duration.zero);
              _handleBackNavigation();
            }
          },
          child: Scaffold(
            backgroundColor: Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: gapSymmetric(horizontal: 20, vertical: 20),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .where(
                          'host_user_id',
                          isEqualTo: userCubit.state.userId,
                        )
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      final allNotifications = snapshot.data!.docs;

                      final notifications = allNotifications.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status = data['status'] ?? false;
                        final kitchenId = data['kitchen_id'];

                        if (status == true) return true;
                        return kitchenId == userCubit.state.activeKitchenId;
                      }).toList();

                      if (notifications.isEmpty) {
                        return Center(
                          child: Text(
                            "No notifications yet",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) =>
                            Divider(color: Color(0xffF4F4F4)),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final notification =
                              notifications[index].data()
                                  as Map<String, dynamic>;
                          final id = notification['id'];
                          final kitchenId = notification['kitchen_id'];
                          final title = notification['title'];
                          final senderName = notification['sender_name'];
                          final senderUserId = notification['sender_user_id'];
                          final body = notification['body'];
                          final date = notification['date'];
                          final status = notification['status'] ?? false;

                          return UpperTile(
                            widget: InkWell(
                              onTap: () =>
                                  navigateUserDetails(senderUserId, kitchenId),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: h(8),
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        senderName,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      ),
                                      Text(
                                        date,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "$title - $body",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  if (!status) ...[
                                    gap(height: 8),
                                    Row(
                                      spacing: w(12),
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            height: h(40),
                                            child: OutlinedButton(
                                              onPressed: () {
                                                context
                                                    .read<DashboardBloc>()
                                                    .add(
                                                      DeclineRequestEvent(
                                                        id: id,
                                                        kitchenId: kitchenId,
                                                        memberId: senderUserId,
                                                      ),
                                                    );
                                              },
                                              child: state is DeclineLoading
                                                  ? Transform.scale(
                                                      scale: 0.7,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: AppColors
                                                                .primaryColor,
                                                          ),
                                                    )
                                                  : Text(
                                                      "Decline",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium!
                                                          .copyWith(
                                                            fontSize: t(12),
                                                            color: AppColors
                                                                .primaryColor,
                                                          ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: SizedBox(
                                            height: h(40),
                                            child: GenericButtonWidget(
                                              isLoading:
                                                  state is ApproveLoading,
                                              onPressed: () {
                                                context
                                                    .read<DashboardBloc>()
                                                    .add(
                                                      ApproveRequestEvent(
                                                        id: id,
                                                        kitchenId: kitchenId,
                                                        memberId: senderUserId,
                                                      ),
                                                    );
                                              },
                                              text: "Approve",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> navigateUserDetails(String senderId, String kitchenId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserPage(senderUserId: senderId, kitchenId: kitchenId),
      ),
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
            onTap: () => _handleBackNavigation(),
          ),
        ],
      ),
      title: Text(
        "Notifications",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  void _handleBackNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(Routes.dashboard);
    });
  }
}
