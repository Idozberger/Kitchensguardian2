import 'package:flutter/material.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class IntroAppFeaturesWidget extends StatefulWidget {
  const IntroAppFeaturesWidget({super.key});

  @override
  State<IntroAppFeaturesWidget> createState() => _IntroAppFeaturesWidgetState();
}

class _IntroAppFeaturesWidgetState extends State<IntroAppFeaturesWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> pages = [
    _OnboardingPageData(
      image: AppAssets.plannerPng,
      startText: "Get Your ",
      highLightText: "Meal Plan",
      endText: "",
      subtitle: "Get your whole week meal plan ( Breakfast. Lunch and Dinner).",
    ),
    _OnboardingPageData(
      image: AppAssets.scanMealPng,
      startText: "Scan To ",
      highLightText: "Log In ",
      endText: "Ingredients",
      subtitle: "Scan Receipt to add items in your grocery list.",
    ),
    _OnboardingPageData(
      image: AppAssets.alertsPng,
      startText: "Expiry ",
      highLightText: "Alerts",
      endText: "",
      subtitle: "Get expiring notification before the product goneexpired.",
    ),
    _OnboardingPageData(
      image: AppAssets.scanMealPng,
      startText: "Discover ",
      highLightText: "Delicious Recipes ",
      endText: "From Around The World",
      subtitle: "Scan Receipt to add items in your grocery list.",
    ),
  ];

  void _onNextPressed() {
    if (_currentPage == pages.length - 1) {
      context.go(Routes.signIn);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          page.image,
                          height: h(400),
                          width: double.infinity,
                        ),

                        SizedBox(
                          height: h(144),
                          child: Padding(
                            padding: gapSymmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: page.startText,
                                        style: textStyle(context),
                                      ),
                                      TextSpan(
                                        text: page.highLightText,
                                        style: textStyle(context).copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: page.endText,
                                        style: textStyle(context),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                gapVertical(10),
                                Text(
                                  page.subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontSize: t(14),
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Padding(
                padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
                child: GenericButtonWidget(
                  onPressed: _onNextPressed,
                  text: _currentPage == pages.length - 1
                      ? "Get Started"
                      : "Continue",
                ),
              ),
              gapVertical(14),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: t(16),
      fontWeight: FontWeight.w600,
    );
  }
}

class _OnboardingPageData {
  final String image;
  final String startText;
  final String highLightText;
  final String endText;
  final String subtitle;

  const _OnboardingPageData({
    required this.image,
    required this.startText,
    required this.endText,
    required this.subtitle,
    required this.highLightText,
  });
}
