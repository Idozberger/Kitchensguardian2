import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/code_resend.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

Future<dynamic> showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return GenericDialog(
        borderRadius: h(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Log Out", style: Theme.of(context).textTheme.headlineLarge),

            SizedBox(height: h(15)),
            Text(
              "Are you sure you want to log out?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            SizedBox(height: h(20)),
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
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              fontSize: t(14),
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: w(10)),

                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    height: h(40),
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(Routes.signIn);
                      },

                      child: Text(
                        "Log out",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
