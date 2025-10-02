import 'package:foodkitchen/features/auth/presentation/pages/login/create_new_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/forgot_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/password_changed_success_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/code_verification_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/signin_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/email_verfied_succes_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/verify_email_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/notification_page.dart';
import 'package:foodkitchen/features/history/presentation/pages/history_page.dart';
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
      path: Routes.passwordChangedSuccess,
      builder: (context, state) => PasswordChangedSuccessPage(),
    ),
    GoRoute(
      name: "verify_email",
      path: Routes.verifyEmail,
      builder: (context, state) {
        return VerifyEmailPage(
          emailAddress: state.uri.queryParameters["email"] ?? "",
        );
      },
    ),
    GoRoute(
      path: Routes.emailVerifiedSuccess,
      builder: (context, state) => EmailVerfiedSuccesPage(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => DashboardPage(),
    ),
    GoRoute(
      path: Routes.notification,
      builder: (context, state) => NotificationPage(),
    ),
    GoRoute(
      path: Routes.scanHistory,
      builder: (context, state) => ScanHistoryPage(),
    ),
  ],
);
