import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';

Future<dynamic> showDialogForItemDeletion(
  BuildContext context, {
  required VoidCallback callback,
}) {
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
            Text(
              "Remove Item",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            SizedBox(height: h(10)),
            Text(
              "Are you sure you want to delete this item?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(12),
                color: Color(0xff7B7B7B),
              ),
            ),
            SizedBox(height: h(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    height: h(40),
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: t(12),
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: h(10)),
                Flexible(
                  child: GenericButtonWidget(
                    onPressed: () {
                      callback();
                      Navigator.pop(context);
                    },

                    text: "Yes",
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
