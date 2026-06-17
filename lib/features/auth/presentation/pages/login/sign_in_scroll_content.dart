import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/utils/password_formatter.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';

class SignInScrollContent extends StatelessWidget {
  const SignInScrollContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isObscure,
    required this.onToggleObscure,
    required this.onLogin,
    required this.onGoogleSignIn,
    required this.authState,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isObscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final VoidCallback onGoogleSignIn;
  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: gapSymmetric(horizontal: 20, vertical: 24),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: h(32)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: h(8)),
                Text(
                  "Login to your account",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            Column(
              children: [
                SizedBox(height: h(32)),

                SizedBox(
                  height: h(180),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          textInputAction: TextInputAction.next,
                          controller: emailController,
                          label: "Email address",
                          keyboardType: TextInputType.emailAddress,
                          hintText: "your.email@example.com",
                          inputFormatters: [
                            SingleAtSingleDotAfterAtFormatter(),
                          ],
                        ),
                        SizedBox(height: h(20)),
                        AppTextField(
                          controller: passwordController,
                          label: "Password",
                          textInputAction: TextInputAction.done,
                          hintText: "At least 6 characters",
                          obscureText: isObscure,
                          suffixIcon: GestureDetector(
                            onTap: onToggleObscure,
                            child: Padding(
                              padding: gapSymmetric(
                                vertical: 13,
                                horizontal: 15,
                              ),
                              child: SvgPicture.asset(
                                isObscure == false
                                    ? AppAssets.eyeVisibilitySvg
                                    : AppAssets.eyeSvg,
                                height: h(16),
                                colorFilter: ColorFilter.mode(
                                  AppColors.greyColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          inputFormatters: [NoSpacePasswordFormatter()],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: gapOnly(top: 0, bottom: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(Routes.forgotPassword),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                GenericButtonWidget(
                  onPressed: onLogin,
                  text: "Login",
                  isLoading: authState is AuthLoading,
                ),

                Padding(
                  padding: gapSymmetric(vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: gapSymmetric(horizontal: 12),
                        child: Text(
                          "Or",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontSize: t(12),
                              ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
                SocialAuthButton(
                  isLoading: authState is GoogleAuthLoading,
                  iconPath: AppAssets.googleSvg,
                  text: "Continue with Google",
                  onTap: onGoogleSignIn,
                ),
                if (Platform.isIOS)
                  SocialAuthButton(
                    isLoading: authState is AppleSignInLoading,
                    iconPath: AppAssets.appleSvg,
                    text: "Continue with Apple",
                    onTap: () {
                      context.read<AuthBloc>().add(AppleSignInEvent());
                    },
                  ),

                Padding(
                  padding: gapOnly(top: 20),
                  child: Center(
                    child: TextspanWidget(
                      buttonColor: AppColors.primaryColor,
                      callback: () {
                        context.push(Routes.signUp);
                      },
                      text: "Don't have an account?",
                      buttonText: "Sign Up",
                    ),
                  ),
                ),
              ],
            ),

            Column(
              children: [
                SizedBox(height: h(18)),
                Text(
                  "By logging in, you agree to the terms and conditions of this application.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: t(12),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
