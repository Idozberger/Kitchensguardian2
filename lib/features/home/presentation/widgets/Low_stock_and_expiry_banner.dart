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
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:go_router/go_router.dart';

class LowStockAndExpiryBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const LowStockAndExpiryBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryBloc, PantryState>(
      builder: (context, state) {
        if (state is! PantryLoaded) {
          return const SizedBox.shrink();
        }

        final expiringCount = state.expiringItems.length ?? 0;
        final lowStockCount = state.lowStockItems.length ?? 0;
        final total = expiringCount + lowStockCount;

        if (total == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: gapOnly(left: 16, right: 16, top: 16, bottom: 0),
          child: UpperTile(
            verticalPadding: 14,
            color: Color(0xffFFFBEB),
            borderColor: Color(0xffFFDD98),

            widget: GestureDetector(
              onTap: onTap ?? () => context.push(Routes.myPantry),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.notificationSvg,
                    width: w(18),
                    height: w(18),
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ), // white base
                  ),
                  gap(width: 14),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.primaryColor,
                              height: 1.3,
                            ),
                        children: [
                          if (expiringCount > 0) ...[
                            TextSpan(
                              text: "$expiringCount ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "item${expiringCount == 1 ? "" : "s"} expiring soon",
                            ),
                            if (lowStockCount > 0) const TextSpan(text: " • "),
                          ],
                          if (lowStockCount > 0) ...[
                            TextSpan(
                              text: "$lowStockCount ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "item${lowStockCount == 1 ? "" : "s"} running low",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
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
}
