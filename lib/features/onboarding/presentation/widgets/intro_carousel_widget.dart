import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/intro_page_slider.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/intro_page_indicator_widget.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class IntroCarousel extends StatefulWidget {
  const IntroCarousel({super.key});

  @override
  State<IntroCarousel> createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> {
  late final PageController _pageController;
  double _currentPage = 0.0;
  int _selectedIndex = 0;
  final List<IntroPageSlider> _sliders = [
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg01),
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg02),
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg01),
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg02),
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg01),
    IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg02),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 1000 * _sliders.length,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: h(321),
          child: PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final actualIndex = index % _sliders.length;
              final imagePath = _sliders[actualIndex].imageSource;
              final distance = (_currentPage - index).abs();
              final scale = (1 + distance * 0.1).clamp(1.0, 1.15);
              final height = h(294) * scale;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index % _sliders.length;
              });
            },
          ),
        ),
        gapVertical(23),
        PageIndicator(count: _sliders.length, selectedIndex: _selectedIndex),
      ],
    );
  }
}
