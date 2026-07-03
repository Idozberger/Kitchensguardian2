import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/onboarding_theme.dart';
import 'package:go_router/go_router.dart';

/// Onboarding screen 1 — "Run Your Kitchen Smarter" welcome. Shown to
/// unauthenticated users before the sign-in / sign-up flow.
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  void _onGetStarted(BuildContext context) {
    context.read<UserBloc>().add(GetStartedEvent());
  }

  void _handleStateChange(BuildContext context, UserState state) {
    if (state is UserGetStarted) {
      context.go(Routes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: _handleStateChange,
      builder: (context, state) => Scaffold(
        body: OnboardingBackground(
          child: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20),
              child: Column(
                children: [
                  gapVertical(24),
                  const OnboardingTitle([
                    OnboardingTitleSpan('Run Your\nKitchen '),
                    OnboardingTitleSpan('Smarter', accent: true),
                  ]),
                  const Spacer(),
                  Image.asset(
                    'assets/images/onb_welcome.png',
                    fit: BoxFit.contain,
                    height: h(320),
                  ),
                  const Spacer(),
                  const _WelcomeCaption(),
                  gapVertical(40),
                  GenericOnboardingButton(
                    text: 'Get Started',
                    isLoading: state is UserLoading,
                    onPressed: () => _onGetStarted(context),
                  ),
                  gapVertical(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCaption extends StatelessWidget {
  const _WelcomeCaption();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Turn Ingredients Into Meals',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: t(16),
            fontWeight: FontWeight.w700,
            color: OnboardingColors.bodyStrong,
          ),
        ),
        gapVertical(10),
        Padding(
          padding: gapSymmetric(horizontal: 30),
          child: Text(
            'Smart inventory, zero waste, tailored recipes and meal plans.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: t(13),
              fontWeight: FontWeight.w400,
              color: OnboardingColors.bodyMuted,
            ),
          ),
        ),
      ],
    );
  }
}
