import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/user_information_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    log("User id ${_userCubit.state.userId}");
  }

  Stream<QuerySnapshot> get _notificationsStream => FirebaseFirestore.instance
      .collection('notifications')
      .where('host_user_id', isEqualTo: _userCubit.state.userId)
      .orderBy('date', descending: true)
      .snapshots();

  List<QueryDocumentSnapshot> _filterNotifications(
    List<QueryDocumentSnapshot> docs,
  ) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? false;
      final kitchenId = data['kitchen_id'];
      if (status == true) return true;
      return kitchenId == _userCubit.state.activeKitchenId;
    }).toList();
  }

  void _navigateUserDetails(String senderId, String kitchenId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserPage(senderUserId: senderId, kitchenId: kitchenId),
      ),
    );
  }

  void _handleBackNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goNamed(
        Routes.dashboard,
        extra: {
          'fromNotification': false,
          'entryType': DashboardEntryType.normal,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (!didPop) {
              await Future.delayed(Duration.zero);
              _handleBackNavigation();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: StreamBuilder<QuerySnapshot>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = snapshot.hasData
                    ? _filterNotifications(snapshot.data!.docs)
                    : <QueryDocumentSnapshot>[];

                if (filtered.isEmpty) {
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
                          style: Theme.of(context).textTheme.headlineMedium
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
                    final data = filtered[index].data() as Map<String, dynamic>;
                    final notifId = data['id'];
                    final date = data['date'];

                    return _NotificationCard(
                      id: notifId,
                      kitchenId: data['kitchen_id'] ?? '',
                      title: data['title'] ?? '',
                      senderName: data['sender_name'] ?? '',
                      senderUserId: data['sender_user_id'] ?? '',
                      body: data['body'] ?? '',
                      date: data['date'] ?? '',
                      joiningStatus:
                          data['kitchen_joining_status'] ?? 'Pending',
                      isActioned: data['status'] ?? false,
                      isApproveLoading:
                          state is ApproveLoading &&
                          (state).id == date.toString(),
                      isDeclineLoading:
                          state is DeclineLoading &&
                          (state).id == date.toString(),
                      onTap: () => _navigateUserDetails(
                        data['sender_user_id'] ?? '',
                        data['kitchen_id'] ?? '',
                      ),
                      onApprove: () => context.read<DashboardBloc>().add(
                        ApproveRequestEvent(
                          date: date,
                          id: notifId,
                          kitchenId: data['kitchen_id'],
                          memberId: data['sender_user_id'],
                        ),
                      ),
                      onDecline: () => context.read<DashboardBloc>().add(
                        DeclineRequestEvent(
                          date: date,
                          id: notifId,
                          kitchenId: data['kitchen_id'],
                          memberId: data['sender_user_id'],
                        ),
                      ),
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

class _NotificationCard extends StatelessWidget {
  final dynamic id;
  final String kitchenId;
  final String title;
  final String senderName;
  final String senderUserId;
  final String body;
  final String date;
  final String joiningStatus;
  final bool isActioned;
  final bool isApproveLoading;
  final bool isDeclineLoading;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const _NotificationCard({
    required this.id,
    required this.kitchenId,
    required this.title,
    required this.senderName,
    required this.senderUserId,
    required this.body,
    required this.date,
    required this.joiningStatus,
    required this.isActioned,
    required this.isApproveLoading,
    required this.isDeclineLoading,
    required this.onTap,
    required this.onApprove,
    required this.onDecline,
  });

  ({Color color, Color bg, Color border, IconData icon}) get _statusStyle =>
      switch (joiningStatus) {
        'Approved' => (
          color: Colors.grey.shade800,
          bg: Colors.grey.shade100,
          border: Colors.grey.shade100,
          icon: Icons.check_circle_rounded,
        ),
        'Declined' => (
          color: Colors.grey.shade800,
          bg: Colors.grey.shade100,
          border: Colors.grey.shade100,
          icon: Icons.cancel_rounded,
        ),
        _ => (
          color: Colors.grey.shade800,
          bg: Colors.grey.shade100,
          border: Colors.grey.shade100,
          icon: Icons.check_circle_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: s.bg,
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: s.color,
                      fontWeight: FontWeight.w800,
                      fontSize: t(18),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: t(14),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: s.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, color: s.color, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        joiningStatus,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: s.color,
                              fontSize: t(12),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: t(13),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: t(12),
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            if (!isActioned) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      height: 40,
                      child: GenericButtonWidget(
                        isOutlined: true,
                        onPressed: isDeclineLoading ? () {} : onDecline,
                        text: "Decline",
                        isLoading: isDeclineLoading,
                      ),
                    ),
                  ),
                  gap(width: 12),
                  Flexible(
                    child: SizedBox(
                      height: 40,
                      child: GenericButtonWidget(
                        onPressed: isApproveLoading ? () {} : onApprove,
                        text: "Approve",
                        isLoading: isApproveLoading,
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
  }
}
