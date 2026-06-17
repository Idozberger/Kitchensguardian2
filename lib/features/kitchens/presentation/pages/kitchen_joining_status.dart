import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_join_status_firestore_datasource.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/join_request_info.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/all_join_request_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/joining_request_shimmer.dart';

class KitchenJoiningStatus extends StatefulWidget {
  final String userId;

  const KitchenJoiningStatus({super.key, required this.userId});

  @override
  State<KitchenJoiningStatus> createState() => _KitchenJoiningStatusState();
}

class _KitchenJoiningStatusState extends State<KitchenJoiningStatus> {
  late final Stream<List<JoinRequestInfo>> _statusStream;

  @override
  void initState() {
    super.initState();
    _statusStream = sl<KitchenJoinStatusFirestoreDatasource>()
        .watchPendingJoinRequestsForSender(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JoinRequestInfo>>(
      stream: _statusStream,
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
                    MaterialPageRoute<void>(
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
