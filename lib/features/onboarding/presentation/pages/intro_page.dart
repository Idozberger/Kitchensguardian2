import 'package:flutter/material.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/discover_text_widget.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/intro_carousel_widget.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:go_router/go_router.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.onBoardingBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IntroCarousel(),
            gapVertical(85),
            IntroTextContent(),
            gapVertical(40),
          ],
        ),
      ),
    );
  }
}

class IntroTextContent extends StatelessWidget {
  const IntroTextContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20),
      child: Column(
        children: [
          DiscoverText(),
          gapVertical(11),
          Text(
            "Explore thousands of recipes from various cuisines and categories, from appetizers to desserts.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: t(14),
              fontWeight: FontWeight.w400,
            ),
          ),

          Padding(
            padding: gapOnly(bottom: 14, top: 34),
            child: GenericButtonWidget(
              onPressed: () {
                context.go(Routes.introAppFeatures);
              },
              text: "Continue",
            ),
          ),
        ],
      ),
    );
  }
}
