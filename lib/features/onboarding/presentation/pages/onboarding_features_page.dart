import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/onboarding_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screens 2–4 — feature highlights shown to a newly registered
/// user. "Next" on the last page creates a default kitchen and opens the fridge
/// scan; "Skip" exits to the dashboard. Country/currency is collected first if
/// not set yet.
const String _defaultKitchenName = 'Kitchen';

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

  final HomeBloc _homeBloc = sl<HomeBloc>();
  bool _isCreatingKitchen = false;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onNext() {
    if (_isLastPage) {
      _createDefaultKitchenAndScan();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Creates a default "Kitchen" so the fridge scan has an active kitchen,
  /// then routes to it (via country/currency setup if not set yet).
  void _createDefaultKitchenAndScan() {
    setState(() => _isCreatingKitchen = true);
    _homeBloc.add(CreateKitchenEventForHome(_defaultKitchenName));
  }

  void _onKitchenState(BuildContext context, HomeState state) {
    if (!_isCreatingKitchen) return;

    if (state.isLoading) return;

    if (state.errorMessage != null) {
      setState(() => _isCreatingKitchen = false);
      AppToast.show(state.errorMessage!, ToastType.error);
      return;
    }
    if (state.successMessage != null) {
      _isCreatingKitchen = false;
      _goToNext(Routes.smartKitchenSetup);
    }
  }

  /// Exits onboarding to the dashboard (no kitchen is created).
  void _onSkip() {
    _goToNext(Routes.dashboard);
  }

  /// Routes to [destination], collecting country/currency first if not set.
  void _goToNext(String destination) {
    final prefs = sl<SharedPreferences>();
    final country = prefs.getString('country');
    final currency = prefs.getString('currency');
    if (country == null || currency == null) {
      context.goNamed(
        Routes.countryAndCurrencySetup,
        extra: false,
        queryParameters: {'next': destination},
      );
    } else if (destination == Routes.smartKitchenSetup) {
      context.goNamed(destination, extra: false);
    } else {
      context.go(destination);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: _homeBloc,
      listener: _onKitchenState,
      child: Scaffold(
        body: OnboardingBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        _FeaturePageContent(data: _pages[index]),
                  ),
                ),
                OnboardingDots(count: _pages.length, activeIndex: _currentPage),
                gapVertical(20),
                _buildBottomBar(),
                gapVertical(24),
              ],
            ),
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
            onPressed: _isCreatingKitchen ? null : _onSkip,
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
            isLoading: _isCreatingKitchen,
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
