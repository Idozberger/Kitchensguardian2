import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/join_request_info.dart';

class AllJoinRequestsPage extends StatelessWidget {
  final List<JoinRequestInfo> requests;

  const AllJoinRequestsPage({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Text(
              'Join Requests',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: gapSymmetric(horizontal: 16, vertical: 16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final info = requests[index];
          return Padding(
            padding: gapOnly(bottom: 8),
            child: UpperTile(
              verticalPadding: 14,
              color: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFFDD98),
              widget: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.notificationSvg,
                    width: w(18),
                    height: w(18),
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  gap(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.primaryColor,
                                    height: 1.3,
                                  ),
                              children: [
                                const TextSpan(text: 'Your request to join '),
                                TextSpan(
                                  text: info.kitchenName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' is '),
                                TextSpan(
                                  text: _statusLabel(info.status),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        gap(width: 8),
                        _StatusPill(status: info.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'Approved' => 'approved',
    'Declined' => 'declined',
    _ => 'pending',
  };
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 4),
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
