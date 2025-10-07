import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/code_resend.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';

Future<dynamic> showCreateKitchenDialog(BuildContext context) {
  final TextEditingController _kitchenNameController = TextEditingController();
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return GenericDialog(
        borderRadius: h(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kitchen Name",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: t(20),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: SvgPicture.asset(AppAssets.cancelSvg),
                ),
              ],
            ),
            SizedBox(height: h(10)),
            AppTextField(
              isLabled: false,
              label: "e.g: Emily Kitchen",
              hintText: "e.g: Emily Kitchen",
              controller: _kitchenNameController,
            ),
            SizedBox(height: h(10)),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: w(147),
                height: h(40),
                child: GenericButtonWidget(
                  onPressed: () {
                    if (_kitchenNameController.text.isNotEmpty) {
                      Navigator.pop(context, true);
                    } else {
                      AppToast.show(
                        "Kitchen name cannot be empty",
                        ToastType.error,
                      );
                    }
                  },

                  text: "Create",
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
