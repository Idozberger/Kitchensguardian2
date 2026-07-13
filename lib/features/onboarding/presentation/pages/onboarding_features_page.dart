import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/onboarding_theme.dart';
import 'package:go_router/go_router.dart';

/// Onboarding screens 2–4 — feature highlights shown once, right after the
/// user picks their first kitchen (created or joined) on the kitchen selection
/// screen. Finishing (or skipping) marks `onboarding_completed` on the backend
/// and routes onwards: host/co-host of a not-yet-scanned kitchen goes to the
/// fridge scan, everyone else to the dashboard.
class OnboardingFeaturesPage extends StatefulWidget {
  const OnboardingFeaturesPage({super.key});

  @override
  State<OnboardingFeaturesPage> createState() => _OnboardingFeaturesPageState();
}

class _OnboardingFeaturesPageState extends State<OnboardingFeaturesPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_FeaturePageData> _pages = [
    _FeaturePageData(
      image: 'assets/images/onb_features_1.png',
      title: [
        OnboardingTitleSpan('Getting Your\nKitchen '),
        OnboardingTitleSpan('Ready', accent: true),
      ],
    ),
    _FeaturePageData(
      image: 'assets/images/onb_features_2.png',
      title: [
        OnboardingTitleSpan('Smart Lists\nfor Your '),
        OnboardingTitleSpan('Needs', accent: true),
      ],
    ),
    _FeaturePageData(
      image: 'assets/images/onb_features_3.png',
      title: [
        OnboardingTitleSpan('Plan', accent: true),
        OnboardingTitleSpan(' Meals\nfor the Week'),
      ],
    ),
  ];

  /// The "Scan Your Products" screen is appended after the feature pages.
  int get _pageCount => _pages.length + 1;

  bool get _isLastPage => _currentPage == _pageCount - 1;

  void _onNext() {
    if (_isLastPage) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Marks onboarding as completed and routes onwards: host/co-host of a
  /// kitchen without storage areas goes to the fridge scan, a plain member
  /// (or an already scanned kitchen) goes to the dashboard.
  void _finishOnboarding() {
    final userCubit = context.read<UserCubit>();
    userCubit.completeOnboarding();

    final userState = userCubit.state;
    final bool needsScan =
        userState.role != 'member' && userState.userStorageAreas.isEmpty;
    if (needsScan) {
      context.goNamed(Routes.smartKitchenSetup, extra: false);
    } else {
      context.go(Routes.dashboard);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        gradient: _isLastPage
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  OnboardingColors.scanGradientTop,
                  OnboardingColors.scanGradientBottom,
                ],
              )
            : null,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => index < _pages.length
                      ? _FeaturePageContent(data: _pages[index])
                      : const _ScanProductsPageContent(),
                ),
              ),
              OnboardingDots(count: _pageCount, activeIndex: _currentPage),
              gapVertical(20),
              _buildBottomBar(),
              gapVertical(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: t(17),
                fontWeight: FontWeight.w500,
                color: OnboardingColors.bodyStrong,
              ),
            ),
          ),
          GenericOnboardingButton(
            text: 'Next',
            width: w(200),
            onPressed: _onNext,
          ),
        ],
      ),
    );
  }
}

class _FeaturePageData {
  final String image;
  final List<OnboardingTitleSpan> title;

  const _FeaturePageData({required this.image, required this.title});
}

/// The final "Scan Your Products" onboarding screen: white title over the
/// orange gradient and a frosted card with a product inside a scan frame.
class _ScanProductsPageContent extends StatelessWidget {
  const _ScanProductsPageContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: Column(
        children: [
          gapVertical(24),
          const OnboardingTitle([
            OnboardingTitleSpan('Scan\nYour Products'),
          ], color: Colors.white),
          const Expanded(child: Center(child: _ScanCard())),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w(280),
      height: w(280),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF08200).withValues(alpha: 0.13),
            blurRadius: 20,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/svgs/onb_scan_frame.svg',
            width: w(230),
            height: w(230),
          ),
          Image.asset(
            'assets/images/onb_scan_product.png',
            height: w(169),
            fit: BoxFit.contain,
          ),
          Transform.translate(
            offset: Offset(0, w(45)),
            child: Transform.rotate(
              angle: -0.94 * math.pi / 180,
              child: Container(
                width: w(150),
                height: 3,
                decoration: BoxDecoration(
                  color: OnboardingColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePageContent extends StatelessWidget {
  final _FeaturePageData data;

  const _FeaturePageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: Column(
        children: [
          gapVertical(24),
          OnboardingTitle(data.title),
          Expanded(
            child: Center(child: Image.asset(data.image, fit: BoxFit.contain)),
          ),
        ],
      ),
    );
  }
}
