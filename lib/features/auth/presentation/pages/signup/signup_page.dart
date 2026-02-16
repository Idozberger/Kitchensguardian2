import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/utils/name_formatter.dart';
import 'package:foodkitchen/core/utils/password_formatter.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/appbar.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late UserCubit _userCubit;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _userCubit.setGoogleSignUpUserModel(firstName: "", lastName: "", email: "");
  }

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscure = true;
  bool _isConfirmPasswordObscure = true;

  void updateIsConfirmPasswordObscure() {
    setState(() {
      _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
    });
  }

  void updateObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);
        }
        if (state is AuthUserCreatedSuccess) {
          AppToast.show(state.successMessage, ToastType.success);
          if (_userCubit.state.userModel != null &&
              _userCubit.state.userModel!.email.isNotEmpty) {
            context.pushNamed(
              "verify_email",
              extra: UserModel(
                email: _userCubit.state.userModel!.email,
                firstName: _userCubit.state.userModel!.firstName,
                lastName: _userCubit.state.userModel!.lastName,
                password: _userCubit.state.userModel!.password,
              ),
            );
          } else {
            context.pushNamed(
              "verify_email",
              extra: UserModel(
                email: _emailController.text.trim(),
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                password: _passwordController.text.trim(),
              ),
            );
          }
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          appBar: CustomAppBar(
            preferedHeight: 70,
            title: "Join the Food Kitchen",
            subTitle:
                "Create an account to save your favorite recipes and start cooking like a pro",
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: gapSymmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _firstNameController,
                                label: "First name",
                                textInputAction: TextInputAction.next,
                                hintText: "First name",
                                inputFormatters: [
                                  OnlyLettersFormatter(maxLength: 20),
                                ],
                              ),
                            ),
                            SizedBox(width: w(12)),
                            Expanded(
                              child: AppTextField(
                                controller: _lastNameController,
                                label: "Last name",
                                textInputAction: TextInputAction.next,
                                hintText: "Last name",
                                inputFormatters: [
                                  OnlyLettersFormatter(maxLength: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h(20)),

                        AppTextField(
                          controller: _emailController,
                          label: "Email address",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          hintText: "your.email@example.com",
                          inputFormatters: [
                            SingleAtSingleDotAfterAtFormatter(),
                          ],
                        ),
                        SizedBox(height: h(20)),

                        AppTextField(
                          controller: _passwordController,
                          label: "Password",
                          textInputAction: TextInputAction.next,
                          hintText: "At least 6 characters",
                          obscureText: _isObscure,
                          inputFormatters: [NoSpacePasswordFormatter()],
                          suffixIcon: GestureDetector(
                            onTap: () => updateObscure(),
                            child: Padding(
                              padding: gapSymmetric(
                                vertical: 13,
                                horizontal: 15,
                              ),
                              child: SvgPicture.asset(
                                _isObscure == false
                                    ? AppAssets.eyeVisibilitySvg
                                    : AppAssets.eyeSvg,
                                height: h(16),
                                color: AppColors.greyColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: h(20)),

                        AppTextField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          textInputAction: TextInputAction.done,
                          hintText: "Re-enter your password",
                          obscureText: _isConfirmPasswordObscure,
                          inputFormatters: [NoSpacePasswordFormatter()],
                          suffixIcon: GestureDetector(
                            onTap: () => updateIsConfirmPasswordObscure(),
                            child: Padding(
                              padding: gapSymmetric(
                                vertical: 13,
                                horizontal: 15,
                              ),
                              child: SvgPicture.asset(
                                _isConfirmPasswordObscure == false
                                    ? AppAssets.eyeVisibilitySvg
                                    : AppAssets.eyeSvg,
                                height: h(16),
                                color: AppColors.greyColor,
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
                      onPressed: () => _handleSignUp(context, state),
                      text: "Sign up",
                      isLoading: state is AuthLoading,
                    ),
                  ),

                  Padding(
                    padding: gapSymmetric(vertical: 8),
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
                    isLoading: state is GoogleAuthsignUpLoading,
                    iconPath: AppAssets.googleSvg,
                    text: "Continue with Google",
                    onTap: () {
                      context.read<AuthBloc>().add(GoogleSignUpEvent());
                    },
                  ),
                  if (Platform.isIOS)
                    SocialAuthButton(
                      isLoading: state is AppleSignUpLoading,
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
            ),
          ),
        );
      },
    );
  }

  void _handleSignUp(BuildContext context, AuthState state) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      AppToast.show("First name is required", ToastType.error);
      return;
    }
    if (firstName.length < 2) {
      AppToast.show(
        "First name must be at least 2 characters",
        ToastType.error,
      );
      return;
    }

    if (lastName.isEmpty) {
      AppToast.show("Last name is required", ToastType.error);
      return;
    }
    if (lastName.length < 2) {
      AppToast.show("Last name must be at least 2 characters", ToastType.error);
      return;
    }

    if (email.isEmpty) {
      AppToast.show("Email is required", ToastType.error);
      return;
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      AppToast.show("Please enter a valid email address", ToastType.error);
      return;
    }
    if (!validateEmailLength(
      email: email,
      onError: (message) {
        AppToast.show(message, ToastType.error);
      },
    )) {
      return;
    }

    if (password.isEmpty) {
      AppToast.show("Password is required", ToastType.error);
      return;
    }
    if (password.length < 6) {
      AppToast.show("Password must be at least 6 characters", ToastType.error);
      return;
    }
    if (confirmPassword.isEmpty) {
      AppToast.show("Confirm Password is required", ToastType.error);
      return;
    }
    if (confirmPassword.length < 6) {
      AppToast.show(
        "Confirm Password must be at least 6 characters",
        ToastType.error,
      );
      return;
    }
    if (confirmPassword != password) {
      AppToast.show("Passwords do not match", ToastType.error);
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignUp(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      ),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String text;
  final String iconPath;

  const SocialAuthButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.text,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(h(10)),
        onTap: isLoading ? null : onTap,
        child: Ink(
          height: h(48),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(h(10)),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: w(24),
                    height: h(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(iconPath, height: h(20), width: w(20)),
                    SizedBox(width: w(10)),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: t(14),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
