import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/discover_text_widget.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/intro_carousel_widget.dart';
import 'package:go_router/go_router.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController;
  late final List<_OnboardingPageData> _pages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = _initializePages();
  }

  List<_OnboardingPageData> _initializePages() {
    return [
      _OnboardingPageData(
        isIntro: true,
        image: AppAssets.onBoardingBg,
        subtitle:
            "Explore thousands of recipes from various cuisines and categories, from appetizers to desserts.",
      ),
      _OnboardingPageData(
        image: AppAssets.plannerPng,
        startText: "Get Your ",
        highLightText: "Meal Plan",
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
    if (_currentPage == _pages.length - 1) {
      context.read<UserBloc>().add(GetStartedEvent());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: _handleStateChange,
      builder: (context, state) => _buildScaffold(state),
    );
  }

  void _handleStateChange(BuildContext context, UserState state) {
    if (state is UserGetStarted) {
      context.go(Routes.signIn);
    }
  }

  Widget _buildScaffold(UserState userState) {
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
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => _buildPageContent(index),
                ),
              ),
              _buildBottomSection(userState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    final page = _pages[index];
    if (page.isIntro) {
      return _buildIntroPage(page);
    }
    return _buildContentPage(page);
  }

  Widget _buildIntroPage(_OnboardingPageData page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const IntroCarousel(),
        gapVertical(85),
        Padding(
          padding: gapSymmetric(horizontal: 20),
          child: Column(
            children: [
              const DiscoverText(),
              gapVertical(11),
              _buildSubtitle(page.subtitle),
            ],
          ),
        ),
        gapVertical(40),
      ],
    );
  }

  Widget _buildContentPage(_OnboardingPageData page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(page.image, height: h(400), width: double.infinity),
        SizedBox(
          height: h(144),
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitleText(page),
                gapVertical(10),
                _buildSubtitle(page.subtitle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleText(_OnboardingPageData page) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: page.startText, style: _getTitleStyle()),
          TextSpan(
            text: page.highLightText,
            style: _getTitleStyle().copyWith(color: AppColors.primaryColor),
          ),
          TextSpan(text: page.endText, style: _getTitleStyle()),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: t(14),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildBottomSection(UserState userState) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
      child: Column(
        children: [
          GenericButtonWidget(
            onPressed: _onNextPressed,
            isLoading: userState is UserLoading,
            text: _currentPage == _pages.length - 1
                ? "Get Started"
                : "Continue",
          ),
          gapVertical(14),
        ],
      ),
    );
  }

  TextStyle _getTitleStyle() {
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
    this.startText = '',
    this.highLightText = '',
    this.endText = '',
    required this.subtitle,
  });
}
