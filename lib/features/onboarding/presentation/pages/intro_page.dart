import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/discover_text_widget.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/intro_carousel_widget.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingPageData> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      _OnboardingPageData(
        isIntro: true,
        image: AppAssets.onBoardingBg,
        startText: '',
        highLightText: '',
        endText: '',
        subtitle:
            "Explore thousands of recipes from various cuisines and categories, from appetizers to desserts.",
      ),
      _OnboardingPageData(
        image: AppAssets.plannerPng,
        startText: "Get Your ",
        highLightText: "Meal Plan",
        endText: "",
        subtitle:
            "Get your whole week meal plan (Breakfast, Lunch, and Dinner).",
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
        subtitle: "Get expiring notifications before the product goes expired.",
      ),
      _OnboardingPageData(
        image: AppAssets.scanMealPng,
        startText: "Discover ",
        highLightText: "Delicious Recipes ",
        endText: "From Around The World",
        subtitle: "Find and enjoy recipes from different cuisines worldwide.",
      ),
    ];
  }

  void _onNextPressed() {
    if (_currentPage == pages.length - 1) {
      context.read<UserBloc>().add(GetStartedEvent());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserGetStarted) {
          context.go(Routes.signIn);
        }
      },
      builder: (_, state) {
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
                      physics: NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        if (page.isIntro) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const IntroCarousel(),
                              gapVertical(85),
                              Padding(
                                padding: gapOnly(left: 20, right: 20),
                                child: Column(
                                  children: [
                                    DiscoverText(),
                                    gapVertical(11),
                                    Text(
                                      page.subtitle,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: t(14),
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              gapVertical(40),
                            ],
                          );
                        }

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
                                padding: gapSymmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
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

                  // --- Continue / Get Started button ---
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
      },
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
  final bool isIntro;
  final String image;
  final String startText;
  final String highLightText;
  final String endText;
  final String subtitle;

  const _OnboardingPageData({
    this.isIntro = false,
    required this.image,
    required this.startText,
    required this.endText,
    required this.subtitle,
    required this.highLightText,
  });
}
