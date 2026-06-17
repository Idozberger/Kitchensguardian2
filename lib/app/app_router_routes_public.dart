part of 'package:foodkitchen/app/app_router.dart';

/// Routes that only need app-root providers ([UserBloc], [UserCubit], [AuthBloc], [AppCubit]).
List<RouteBase> buildPublicRoutes() => [
  GoRoute(
    path: Routes.splash,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, const SplashScreen()),
  ),
  GoRoute(
    path: Routes.onBoarding,
    pageBuilder: (context, state) => buildPage(state.pageKey, IntroPage()),
  ),
  GoRoute(
    path: Routes.signIn,
    pageBuilder: (context, state) => buildPage(state.pageKey, SignInPage()),
  ),
  GoRoute(
    path: Routes.signUp,
    pageBuilder: (context, state) => buildPage(state.pageKey, SignUpPage()),
  ),
  GoRoute(
    path: Routes.forgotPassword,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, ForgotPasswordPage()),
  ),
  GoRoute(
    name: "reset_password_verification",
    path: Routes.resetPasswordVerification,
    pageBuilder: (context, state) {
      final String email = state.extra as String;
      return buildPage(
        state.pageKey,
        ResetPasswordVerificationPage(email: email),
      );
    },
  ),
  GoRoute(
    name: "create_new_password",
    path: Routes.createNewPassword,
    pageBuilder: (context, state) {
      final String email = state.extra as String;
      return buildPage(state.pageKey, CreateNewPasswordPage(email: email));
    },
  ),
  GoRoute(
    path: Routes.passwordChangedSuccess,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, PasswordChangedSuccessPage()),
  ),
  GoRoute(
    name: "verify_email",
    path: Routes.verifyEmail,
    pageBuilder: (context, state) {
      final UserModel userModel = state.extra as UserModel;
      return buildPage(state.pageKey, VerifyEmailPage(userModel: userModel));
    },
  ),
  GoRoute(
    path: Routes.emailVerifiedSuccess,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, EmailVerifiedSuccessPage()),
  ),
  GoRoute(
    name: Routes.countryAndCurrencySetup,
    path: Routes.countryAndCurrencySetup,
    builder: (context, state) {
      bool extra = state.extra as bool;
      return CountryAndCurrencySetupScreen(isUpdating: extra);
    },
  ),
  GoRoute(
    path: Routes.logout,
    pageBuilder: (context, state) => buildPage(state.pageKey, LogoutDialog()),
  ),
  GoRoute(
    path: Routes.notFound404,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, NotFound404Dialog()),
  ),
];
