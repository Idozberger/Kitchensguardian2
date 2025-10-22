import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:go_router/go_router.dart';

class CompleteDialogWidget {
  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GenericDialog(
        borderRadius: h(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Recipe Completed!",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            SizedBox(height: h(10)),
            Text(
              "You've successfully completed all the steps!",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(12),
              ),
            ),
            SizedBox(height: h(16)),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: w(147),
                height: h(40),
                child: GenericButtonWidget(
                  isLoading: false,
                  onPressed: () {
                    onConfirm();
                    context.pop();
                  },
                  text: "Ok",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
