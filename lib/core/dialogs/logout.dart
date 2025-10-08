import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:go_router/go_router.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: gapSymmetric(horizontal: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppAssets.logoutPng,
                height: h(202),
                width: w(250),
                fit: BoxFit.cover,
              ),
            ),
            gap(height: 20),
            Text(
              "Comeback Soon!",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            gap(height: 5),
            Text(
              "Are you sure you want to log out?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gap(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    height: h(40),
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                      },

                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: t(13),
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: w(10)),

                Flexible(
                  child: GenericButtonWidget(
                    onPressed: () {
                      context.go(Routes.signIn);
                    },
                    text: "Log out",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
