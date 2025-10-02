import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class CircularIconButton extends StatelessWidget {
  final String iconAsset;
  final double size;
  final double padding;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final Color? iconColor;

  const CircularIconButton({
    super.key,
    required this.iconAsset,
    this.size = 36,
    this.padding = 10,
    this.borderColor = const Color(0xffD4D2D2),
    this.borderWidth = 1.5,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(h(44)),
      onTap: onTap,
      child: Ink(
        height: h(size),
        width: w(size),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(iconAsset, color: iconColor),
      ),
    );
  }
}
