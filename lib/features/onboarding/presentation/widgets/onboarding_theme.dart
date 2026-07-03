import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

/// Colors and shared building blocks for the Figma onboarding flow.
///
/// The onboarding uses its own warm-orange accent (`#F4690F`), which is
/// intentionally different from the app-wide amber [AppColors.primaryColor].
class OnboardingColors {
  const OnboardingColors._();

  static const Color background = Color(0xFFFAF1E6);
  static const Color titleDark = Color(0xFF1A1A1A);
  static const Color accent = Color(0xFFF4690F);
  static const Color button = Color(0xFFF4600D);
  static const Color bodyStrong = Color(0xFF000000);
  static const Color bodyMuted = Color(0xFF4A4A4A);
  static const Color dotActive = Color(0xFFF08200);
  static const Color dotInactive = Color(0xFFF7D0A1);
}

/// A single run of onboarding title text: [text] rendered dark or [accent].
class OnboardingTitleSpan {
  final String text;
  final bool accent;

  const OnboardingTitleSpan(this.text, {this.accent = false});
}

/// Builds the large split-color onboarding title (Inter ExtraBold 32/40 in the
/// design; rendered with the app font at [FontWeight.w800]).
class OnboardingTitle extends StatelessWidget {
  final List<OnboardingTitleSpan> spans;

  const OnboardingTitle(this.spans, {super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: t(30),
      height: 1.25,
      fontWeight: FontWeight.w800,
    );

    return Text.rich(
      TextSpan(
        children: [
          for (final span in spans)
            TextSpan(
              text: span.text,
              style: baseStyle.copyWith(
                color: span.accent
                    ? OnboardingColors.accent
                    : OnboardingColors.titleDark,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Cream background with the faint decorative food-icon pattern from the design.
class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OnboardingColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/onb_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// The solid orange onboarding CTA (radius 28, height 50, white bold label).
class GenericOnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;

  const GenericOnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: h(50),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: OnboardingColors.button,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? Transform.scale(
                scale: 0.7,
                child: const CircularProgressIndicator(color: Colors.white),
              )
            : Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: t(17),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

/// Elongated active pill + round inactive dots, matching the design.
class OnboardingDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: w(3)),
          width: isActive ? w(30) : w(9),
          height: h(9),
          decoration: BoxDecoration(
            color: isActive
                ? OnboardingColors.dotActive
                : OnboardingColors.dotInactive,
            borderRadius: BorderRadius.circular(9),
          ),
        );
      }),
    );
  }
}
