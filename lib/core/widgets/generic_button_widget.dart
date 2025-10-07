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
  final Color? color;
  const GenericButtonWidget({
    super.key,
    required this.onPressed,

    required this.text,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.isLoading = false,
    this.height = 40,
    this.isOutlined = false,
    this.width = double.infinity,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: h(height!),
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(13),
                  color: AppColors.primaryColor,
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: onPressed,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      text,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontSize: t(13),
                            color: color != null ? Colors.white : Colors.black,
                          ),
                    ),
            ),
    );
  }
}
