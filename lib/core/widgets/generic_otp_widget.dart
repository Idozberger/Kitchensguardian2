import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class OtpField extends StatelessWidget {
  final bool preFilledStar;
  final void Function(String)? onCompleted;

  const OtpField({super.key, this.onCompleted, this.preFilledStar = false});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: w(50),
      height: h(55),
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        borderRadius: BorderRadius.circular(h(10)),
      ),
    );

    return Pinput(
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(h(10)),
        ),
      ),
      errorPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.errorColor, width: 2),
          borderRadius: BorderRadius.circular(h(10)),
        ),
      ),
      preFilledWidget: preFilledStar
          ? Text(
              "*",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.greyColor,
                fontWeight: FontWeight.w400,
                fontSize: t(25),
              ),
            )
          : null,
      keyboardType: TextInputType.number,
      onCompleted: onCompleted,
    );
  }
}
