import 'package:flutter/material.dart';
import 'package:foodkitchen/core/extensions/theme_extension.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final bool isLabled;
  final bool enabled;
  final String hintText;
  final TextEditingController controller;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isFilled;
  final Color? color;
  final Color? fillColor;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool textAlignCentered;
  final TextInputAction? textInputAction;
  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.contentPadding,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.isLabled = true,
    this.enabled = true,
    this.onFieldSubmitted,
    this.isFilled = false,
    this.textInputAction = TextInputAction.done,
    this.textAlignCentered = false,
    this.fillColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLabled) ...[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),

          SizedBox(height: h(10)),
        ],

        TextFormField(
          enabled: enabled,
          obscuringCharacter: "*",
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onFieldSubmitted: onFieldSubmitted,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color),
          validator: validator,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            filled: isFilled,
            fillColor: fillColor,
            contentPadding: gapAll(12),
            hintText: hintText,

            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor),
            border: outlineInputBorder(context),
            errorBorder: outlineInputBorder(
              context,
            ).copyWith(borderSide: BorderSide(color: AppColors.errorColor)),
            focusedBorder: outlineInputBorder(context),
            disabledBorder: outlineInputBorder(context),
            enabledBorder: outlineInputBorder(context),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),

        if (errorText != null && errorText!.isNotEmpty) ...[
          SizedBox(height: h(10)),
          Text(
            errorText!,
            textAlign: textAlignCentered ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.errorColor,
              fontSize: t(12),
            ),
          ),
        ],
      ],
    );
  }
}

OutlineInputBorder outlineInputBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(h(10)),
    borderSide: BorderSide(
      color: context.isDarkTheme
          ? Colors.white
          : AppColors.appTextFieldBorderColor,
      width: 1.2,
    ),
  );
}
