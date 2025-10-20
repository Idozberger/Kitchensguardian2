import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class RoundedTextContainer extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final double width;
  final double horizontalPad;
  final double verticalPad;
  final bool isBordered;
  final Color? borderColor;
  const RoundedTextContainer({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xffF6F6F6),
    this.textColor = const Color(0xff787878),
    this.radius = 20,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.width = 124,
    this.horizontalPad = 12,
    this.verticalPad = 6,
    this.isBordered = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapSymmetric(vertical: verticalPad, horizontal: horizontalPad),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(h(radius)),
        border: isBordered ? Border.all(color: borderColor!) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
