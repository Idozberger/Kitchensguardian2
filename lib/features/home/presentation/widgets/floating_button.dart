import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Stack(
          children: [
            Positioned(
              top: h(32),
              right: w(0),
              child: SizedBox(
                width: w(38),
                child: FloatingActionButton(
                  heroTag: "fab_main",

                  key: UniqueKey(),
                  elevation: 4,
                  backgroundColor: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (state.role != "member") {
                      context.push(Routes.scanMeal);
                    } else {
                      AppToast.show(
                        "Only host or co-host can scan a meal",
                        ToastType.error,
                      );
                    }
                  },

                  child: SvgPicture.asset(
                    AppAssets.scanSvg,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
