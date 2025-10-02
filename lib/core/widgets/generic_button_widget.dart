import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class GenericButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final double? width;
  final bool isOutlined;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const GenericButtonWidget({
    super.key,
    required this.onPressed,

    required this.text,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.isLoading = false,
    this.height,
    this.isOutlined = false,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(14),
                  color: AppColors.primaryColor,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      text,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(fontSize: t(14), color: Colors.black),
                    ),
            ),
    );
  }
}
