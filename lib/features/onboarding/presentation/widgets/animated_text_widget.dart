import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class AnimatedText extends StatelessWidget {
  final AnimationController controller;
  final String text;

  const AnimatedText({super.key, required this.controller, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(text.length, (index) {
        final delay = index / text.length;
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay,
              delay + (1 / text.length),
              curve: Curves.easeIn,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: Text(
            text[index],
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: t(28),
              color: Colors.black87,
            ),
          ),
        );
      }),
    );
  }
}
