import 'package:foodkitchen/features/auth/presentation/pages/create_new_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/reset_password_verification_page.dart'
    show ResetPasswordVerificationPage;
import 'package:foodkitchen/features/auth/presentation/pages/signin_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/intro_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/language_selection_page.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(path: Routes.onBoarding, builder: (context, state) => IntroPage()),
    GoRoute(
      path: Routes.languageSelection,
      builder: (context, state) => LanguageSelectionPage(),
    ),
    GoRoute(path: Routes.signIn, builder: (context, state) => SignInPage()),
    GoRoute(path: Routes.signUp, builder: (context, state) => SignUpPage()),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    GoRoute(
      path: Routes.resetPasswordVerification,
      builder: (context, state) => ResetPasswordVerificationPage(),
    ),
    GoRoute(
      path: Routes.createNewPassword,
      builder: (context, state) => CreateNewPasswordPage(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => DashboardPage(),
    ),
  ],
);
