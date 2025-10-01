import 'package:flutter/material.dart';
import 'package:foodkitchen/features/onboarding/model/intro_page_slider.dart';
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
  late PageController _pageController = PageController();
  double _currentPage = 0.0;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  List<IntroPageSlider> _getSlider() {
    return [
      IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg01),
      IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg02),
      IntroPageSlider(imageSource: AppAssets.onBoardingSliderBg01),
    ];
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
            itemCount: _getSlider().length,
            onPageChanged: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            itemBuilder: (context, index) {
              final imagePath = _getSlider()[index].imageSource;
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
          ),
        ),
        gapVertical(23),
        PageIndicator(
          count: _getSlider().length,
          selectedIndex: _selectedIndex,
        ),
      ],
    );
  }
}
