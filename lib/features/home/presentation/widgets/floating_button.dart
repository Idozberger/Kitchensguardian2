import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: h(32),
          right: w(0),
          child: SizedBox(
            width: w(38),
            child: FloatingActionButton(
              key: UniqueKey(),
              elevation: 4,
              backgroundColor: AppColors.primaryColor,
              shape: const CircleBorder(),
              onPressed: () {
                context.push(Routes.scanMeal);
              },
              child: SvgPicture.asset(AppAssets.scanSvg, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
