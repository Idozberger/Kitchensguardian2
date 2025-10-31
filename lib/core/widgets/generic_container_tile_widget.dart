import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class UpperTile extends StatelessWidget {
  final Widget widget;
  final Color? color;
  final Color? borderColor;
  final double? height;
  final VoidCallback? callback;
  final double? horizontalPadding;
  final double? verticalPadding;

  const UpperTile({
    super.key,
    required this.widget,
    this.height,
    this.color,
    this.borderColor,
    this.callback,
    this.horizontalPadding = 15,
    this.verticalPadding = 15,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(h(10)),
      onTap: callback == null
          ? null
          : () {
              callback!();
            },
      child: Container(
        height: height,
        width: double.maxFinite,
        padding: gapSymmetric(
          horizontal: horizontalPadding!,
          vertical: verticalPadding!,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h(14)),
          border: Border.all(color: borderColor ?? const Color(0xffD4D2D2)),
          color: color ?? Colors.white,
        ),
        child: widget,
      ),
    );
  }
}
