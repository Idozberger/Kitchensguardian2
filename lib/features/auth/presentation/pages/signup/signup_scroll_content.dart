import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/utils/name_formatter.dart';
import 'package:foodkitchen/core/utils/password_formatter.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';

class SignUpScrollContent extends StatelessWidget {
  const SignUpScrollContent({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isObscure,
    required this.isConfirmPasswordObscure,
    required this.onTogglePasswordObscure,
    required this.onToggleConfirmPasswordObscure,
    required this.onSignUp,
    required this.authState,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isObscure;
  final bool isConfirmPasswordObscure;
  final VoidCallback onTogglePasswordObscure;
  final VoidCallback onToggleConfirmPasswordObscure;
  final VoidCallback onSignUp;
  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: gapSymmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: firstNameController,
                        label: "First name",
                        textInputAction: TextInputAction.next,
                        hintText: "First name",
                        inputFormatters: [OnlyLettersFormatter(maxLength: 20)],
                      ),
                    ),
                    SizedBox(width: w(12)),
                    Expanded(
                      child: AppTextField(
                        controller: lastNameController,
                        label: "Last name",
                        textInputAction: TextInputAction.next,
                        hintText: "Last name",
                        inputFormatters: [OnlyLettersFormatter(maxLength: 20)],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h(20)),

                AppTextField(
                  controller: emailController,
                  label: "Email address",
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  hintText: "your.email@example.com",
                  inputFormatters: [SingleAtSingleDotAfterAtFormatter()],
                ),
                SizedBox(height: h(20)),

                AppTextField(
                  controller: passwordController,
                  label: "Password",
                  textInputAction: TextInputAction.next,
                  hintText: "At least 6 characters",
                  obscureText: isObscure,
                  inputFormatters: [NoSpacePasswordFormatter()],
                  suffixIcon: GestureDetector(
                    onTap: onTogglePasswordObscure,
                    child: Padding(
                      padding: gapSymmetric(vertical: 13, horizontal: 15),
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
                ),
                SizedBox(height: h(20)),

                AppTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  textInputAction: TextInputAction.done,
                  hintText: "Re-enter your password",
                  obscureText: isConfirmPasswordObscure,
                  inputFormatters: [NoSpacePasswordFormatter()],
                  suffixIcon: GestureDetector(
                    onTap: onToggleConfirmPasswordObscure,
                    child: Padding(
                      padding: gapSymmetric(vertical: 13, horizontal: 15),
                      child: SvgPicture.asset(
                        isConfirmPasswordObscure == false
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
                ),
              ],
            ),
          ),

          Padding(
            padding: gapOnly(top: 28, bottom: 16),
            child: GenericButtonWidget(
              onPressed: onSignUp,
              text: "Sign up",
              isLoading: authState is AuthLoading,
            ),
          ),

          Padding(
            padding: gapSymmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
                Padding(
                  padding: gapSymmetric(horizontal: 12),
                  child: Text(
                    "Or",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: t(12),
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
              ],
            ),
          ),
          SocialAuthButton(
            isLoading: authState is GoogleAuthsignUpLoading,
            iconPath: AppAssets.googleSvg,
            text: "Continue with Google",
            onTap: () {
              context.read<AuthBloc>().add(GoogleSignUpEvent());
            },
          ),
          if (Platform.isIOS)
            SocialAuthButton(
              isLoading: authState is AppleSignUpLoading,
              iconPath: AppAssets.appleSvg,
              text: "Continue with Apple",
              onTap: () {
                context.read<AuthBloc>().add(AppleSignUpEvent());
              },
            ),

          Padding(
            padding: gapOnly(top: 20),
            child: Center(
              child: TextspanWidget(
                buttonColor: AppColors.primaryColor,
                callback: () {
                  Navigator.of(context).pop();
                },
                text: "Already have an account?",
                buttonText: "Login",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
