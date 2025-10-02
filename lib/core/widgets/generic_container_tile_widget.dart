import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class UpperTile extends StatelessWidget {
  final Widget widget;

  const UpperTile({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: gapSymmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h(14)),
        border: Border.all(color: const Color(0xffD4D2D2)),
        color: Colors.white,
      ),
      child: widget,
    );
  }
}
