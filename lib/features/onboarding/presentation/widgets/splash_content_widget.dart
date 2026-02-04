import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/animated_text_widget.dart';

class SplashContent extends StatelessWidget {
  final AnimationController animationController;
  final String text;

  const SplashContent({
    super.key,
    required this.animationController,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.onBoardingBg),
          fit: BoxFit.cover,
        ),
      ),
      child: AnimatedText(controller: animationController, text: text),
    );
  }
}
