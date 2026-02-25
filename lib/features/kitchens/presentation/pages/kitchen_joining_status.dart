import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/all_join_request_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/joining_request_shimmer.dart';

class JoinRequestInfo {
  final String status;
  final String kitchenName;
  final String kitchenId;
  final String date;

  const JoinRequestInfo({
    required this.status,
    required this.kitchenName,
    required this.kitchenId,
    required this.date,
  });
}

class KitchenJoiningStatus extends StatelessWidget {
  final String userId;

  const KitchenJoiningStatus({super.key, required this.userId});

  Stream<List<JoinRequestInfo>> _statusStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('sender_user_id', isEqualTo: userId)
        .where('approved_by', isNotEqualTo: userId)
        .where('kitchen_joining_status', isEqualTo: 'Pending')
        .orderBy('approved_by')
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          final results = <JoinRequestInfo>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final kitchenId = data['kitchen_id'] as String? ?? '';
            String kitchenName = data['kitchen_name'] as String? ?? '';

            if (kitchenName.isEmpty && kitchenId.isNotEmpty) {
              final kitchenDoc = await FirebaseFirestore.instance
                  .collection('kitchens')
                  .doc(kitchenId)
                  .get();
              kitchenName =
                  kitchenDoc.data()?['kitchen_name'] as String? ??
                  'Unknown Kitchen';
            }

            results.add(
              JoinRequestInfo(
                status: data['kitchen_joining_status'] as String? ?? 'Pending',
                kitchenName: kitchenName,
                kitchenId: kitchenId,
                date: data['date'] as String? ?? '',
              ),
            );
          }
          return results;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JoinRequestInfo>>(
      stream: _statusStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const JoinRequestShimmer();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final requests = snapshot.data!;
        final hasMore = requests.length > 2;
        final visible = hasMore ? requests.take(2).toList() : requests;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...visible.map((req) => _buildBannerItem(context, req)),
            if (hasMore)
              Padding(
                padding: gapOnly(bottom: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllJoinRequestsPage(requests: requests),
                    ),
                  ),
                  child: UpperTile(
                    verticalPadding: 10,
                    color: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFFDD98),
                    widget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.primaryColor,
                          size: w(18),
                        ),
                        gap(width: 6),
                        Text(
                          'See ${requests.length - 2} more',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBannerItem(BuildContext context, JoinRequestInfo info) {
    return Padding(
      padding: gapOnly(left: 0, right: 0, top: 0, bottom: 8),
      child: UpperTile(
        verticalPadding: 14,
        color: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFFDD98),
        widget: Row(
          children: [
            _buildIcon(),
            gap(width: 14),
            Expanded(child: _buildAlertText(context, info)),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      AppAssets.notificationSvg,
      width: w(18),
      height: w(18),
      colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
    );
  }

  Widget _buildAlertText(BuildContext context, JoinRequestInfo info) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryColor,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'Your request to join '),
                TextSpan(
                  text: info.kitchenName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' is '),
                TextSpan(
                  text: _statusMessage(info.status),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        gap(width: 8),
        _buildStatusPill(info.status),
      ],
    );
  }

  String _statusMessage(String status) => switch (status) {
    'Approved' => 'approved',
    'Declined' => 'declined',
    _ => 'pending',
  };

  Widget _buildStatusPill(String status) {
    log("status: $status");

    final (color, bg) = switch (status) {
      'Approved' => (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      'Declined' => (const Color(0xFFC62828), const Color(0xFFFFEBEE)),
      _ => (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
