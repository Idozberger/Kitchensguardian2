// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:go_router/go_router.dart';

class LowStockAndExpiryBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const LowStockAndExpiryBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SizedBox.shrink();
        }

        final expiringCount = state.expiringItems.length;
        final lowStockCount = state.lowStockItems.length;
        final totalAlerts = expiringCount + lowStockCount;

        if (totalAlerts == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: gapOnly(left: 16, right: 16, top: 16, bottom: 0),
          child: UpperTile(
            verticalPadding: 14,
            color: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFFDD98),
            widget: GestureDetector(
              onTap: onTap ?? () => context.push(Routes.myPantry),
              child: Row(
                children: [
                  _buildIcon(),
                  gap(width: 14),
                  Expanded(
                    child: _buildAlertText(
                      context,
                      expiringCount,
                      lowStockCount,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildAlertText(
    BuildContext context,
    int expiringCount,
    int lowStockCount,
  ) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primaryColor,
          height: 1.3,
        ),
        children: [
          if (expiringCount > 0) ..._buildExpiringSpans(expiringCount),
          if (expiringCount > 0 && lowStockCount > 0)
            const TextSpan(text: " • "),
          if (lowStockCount > 0) ..._buildLowStockSpans(lowStockCount),
        ],
      ),
    );
  }

  List<TextSpan> _buildExpiringSpans(int count) {
    return [
      TextSpan(
        text: "$count ",
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      TextSpan(text: "item${_getPluralSuffix(count)} expiring soon"),
    ];
  }

  List<TextSpan> _buildLowStockSpans(int count) {
    return [
      TextSpan(
        text: "$count ",
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      TextSpan(
        text: "item${_getPluralSuffix(count)} running low",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ];
  }

  String _getPluralSuffix(int count) {
    return count == 1 ? "" : "s";
  }
}
