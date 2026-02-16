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
  final bool isDisabled;

  const GenericButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.isLoading = false,
    this.height = 40,
    this.isDisabled = false,
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
          ? _buildOutlinedButton(context)
          : _buildElevatedButton(context),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      child: isLoading
          ? _buildLoadingIndicator(color: AppColors.primaryColor)
          : Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(12),
                color: AppColors.primaryColor,
              ),
            ),
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      style: _buildButtonStyle(),
      onPressed: isDisabled ? null : onPressed,
      child: isLoading ? _buildLoadingIndicator() : _buildButtonText(context),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : null,
      disabledBackgroundColor: AppColors.disabledPrimaryColor,
    );
  }

  Widget _buildLoadingIndicator({Color? color}) {
    return Transform.scale(
      scale: 0.7,
      child: CircularProgressIndicator(color: color),
    );
  }

  Widget _buildButtonText(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: _getTextColor(),
      ),
    );
  }

  Color _getTextColor() {
    if (isDisabled) return Colors.grey;
    return color != null ? Colors.white : Colors.black;
  }
}
