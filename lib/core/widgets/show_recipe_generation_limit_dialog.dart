import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:go_router/go_router.dart';

void showLimitDialog(BuildContext context, VoidCallback callback) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return GenericDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Limit Reached",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "You've used all 7 recipe searches today watch an ad or upgrade to keep finding recipes",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
            ),
            const SizedBox(height: 20),

            Row(
              spacing: w(8),
              children: [
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: GenericButtonWidget(
                      isOutlined: true,
                      onPressed: () {
                        callback();
                      },
                      text: "Watch Ad to Continue",
                    ),
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: GenericButtonWidget(
                      onPressed: () {
                        context.pop();
                        context.push(Routes.subscription);
                      },
                      text: "Upgrade",
                    ),
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      );
    },
  );
}
