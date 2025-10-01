import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class PageIndicator extends StatelessWidget {
  final int selectedIndex;
  final int count;

  const PageIndicator({
    super.key,
    required this.selectedIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: gapSymmetric(horizontal: 2),
            width: index == selectedIndex ? h(34) : h(6),
            height: h(6),
            decoration: BoxDecoration(
              color: index == selectedIndex
                  ? Theme.of(context).primaryColor
                  : const Color(0xffE0DCD2),
              borderRadius: BorderRadius.circular(54),
            ),
          ),
        ),
      ),
    );
  }
}
