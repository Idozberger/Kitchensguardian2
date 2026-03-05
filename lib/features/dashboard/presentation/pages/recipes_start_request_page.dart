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
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

class RecipesStartRequestPage extends StatefulWidget {
  final bool showAppbar;
  const RecipesStartRequestPage({super.key, this.showAppbar = true});

  @override
  State<RecipesStartRequestPage> createState() =>
      _RecipesStartRequestPageState();
}

class _RecipesStartRequestPageState extends State<RecipesStartRequestPage> {
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    log("User id ${_userCubit.state.userId}");
  }

  Stream<QuerySnapshot> get _requestsStream => FirebaseFirestore.instance
      .collection('recipe_start_requests')
      .where('kitchen_id', isEqualTo: _userCubit.state.activeKitchenId)
      .orderBy('date', descending: true)
      .snapshots();

  List<QueryDocumentSnapshot> _filterRequests(
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

  void _onCardTap(Map<String, dynamic> data) {
    log("RecipeId: ${data["recipe_id"]}");
    context.pushNamed(
      Routes.recipeRequestsDetail,
      extra: {
        'recipeId': data['recipe_id'] ?? '',
        'kitchenId': data['kitchen_id'] ?? '',
        'completed': data['recipe_status'] ?? 'pending',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: widget.showAppbar ? _buildAppBar(context) : null,
        body: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final filtered = snapshot.hasData
                ? _filterRequests(snapshot.data!.docs)
                : <QueryDocumentSnapshot>[];

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 52,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "No recipe requests yet",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: gapSymmetric(horizontal: 12, vertical: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final data = filtered[index].data() as Map<String, dynamic>;

                return _RecipeRequestCard(
                  senderName: data['sender_name'] ?? '',
                  title: data['title'] ?? '',
                  body: data['body'] ?? '',
                  date: data['date']?.toString() ?? '',
                  status: data['recipe_status'],
                  onTap: () => _onCardTap(data),
                );
              },
            );
          },
        ),
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
            onTap: _handleBackNavigation,
          ),
        ],
      ),
      title: Text(
        "Recipe Requests",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class _RecipeRequestCard extends StatelessWidget {
  final String senderName;
  final String title;
  final String body;
  final String date;
  final String status;
  final VoidCallback onTap;

  const _RecipeRequestCard({
    required this.senderName,
    required this.title,
    required this.body,
    required this.date,
    required this.status,
    required this.onTap,
  });

  ({Color color, Color bg, IconData icon, String label}) get _statusStyle =>
      switch (status) {
        'Completed' => (
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle_rounded,
          label: 'Completed',
        ),
        'Declined' => (
          color: const Color(0xFFC62828),
          bg: const Color(0xFFFFEBEE),
          icon: Icons.cancel_rounded,
          label: 'Declined',
        ),
        _ => (
          color: const Color(0xFFE65100),
          bg: const Color(0xFFFFF3E0),
          icon: Icons.hourglass_top_rounded,
          label: 'Pending',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle;
    final initials = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';

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
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Text(
                    initials,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, color: s.color, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        s.label,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: s.color,
                              fontSize: t(11),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontSize: t(13),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontSize: t(12),
                                color: Colors.grey,
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
