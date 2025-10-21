import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class OtpField extends StatelessWidget {
  final bool preFilledStar;
  final bool isJoining;
  final void Function(String)? onCompleted;

  OtpField({
    super.key,
    this.onCompleted,
    this.preFilledStar = false,
    this.isJoining = false,
  });

  @override
  Widget build(BuildContext context) {
    print("joining $isJoining");
    final defaultPinTheme = PinTheme(
      constraints: BoxConstraints(minWidth: w(55), minHeight: h(55)),
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
      key: ValueKey(isJoining),
      length: isJoining ? 6 : 5,
      separatorBuilder: (index) => SizedBox(width: w(4)),

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
          borderRadius: BorderRadius.circular(h(4)),
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
      keyboardType: TextInputType.text,
      onCompleted: onCompleted,
    );
  }
}
