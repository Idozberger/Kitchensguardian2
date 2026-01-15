import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late UserCubit _userCubit;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  void updateObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _userCubit.setGoogleSignUpUserModel(firstName: "", lastName: "", email: "");
  }

  void _handleLogin(AuthState state) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty) {
      AppToast.show("Email is required", ToastType.error);
      return;
    }
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      AppToast.show("Please enter a valid email address", ToastType.error);
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

    context.read<AuthBloc>().add(AuthSignIn(email: email, password: password));
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInEvent());
  }

  void _navigateToVerifyEmail(String email, String password) {
    if (_userCubit.state.userModel != null &&
        _userCubit.state.userModel!.email.isNotEmpty) {
      context.pushNamed(
        "verify_email",
        extra: UserModel(
          email: _userCubit.state.userModel!.email,
          firstName: "",
          lastName: "",
          password: "",
        ),
      );
    } else {
      context.pushNamed(
        "verify_email",
        extra: UserModel(
          email: email,
          firstName: "",
          lastName: "",
          password: password,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthSuccess) {
          AppToast.show(state.successMessage, ToastType.success);
          context.go(Routes.kitchenSelection);
        }
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);

          if (state.message == "User not verified") {
            _navigateToVerifyEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
          }
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
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
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: h(8)),
                        Text(
                          "Login to your account",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                            key: _formKey,
                            child: Column(
                              children: [
                                AppTextField(
                                  textInputAction: TextInputAction.next,
                                  controller: _emailController,
                                  label: "Email address",
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: "your.email@example.com",
                                ),
                                SizedBox(height: h(20)),
                                AppTextField(
                                  controller: _passwordController,
                                  label: "Password",
                                  textInputAction: TextInputAction.done,
                                  hintText: "At least 6 characters",
                                  obscureText: _isObscure,
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
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: gapOnly(top: 0, bottom: 24),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(Routes.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot Password?",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ),

                        GenericButtonWidget(
                          onPressed: () => _handleLogin(state),
                          text: "Login",
                          isLoading: state is AuthLoading,
                        ),

                        Padding(
                          padding: gapSymmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
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
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SocialAuthButton(
                          isLoading: state is GoogleAuthLoading,
                          iconPath: AppAssets.googleSvg,
                          text: "Continue with Google",
                          onTap: () {
                            _handleGoogleSignIn();
                          },
                        ),
                        if (Platform.isIOS)
                          SocialAuthButton(
                            isLoading: state is AppleSignInLoading,
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
            ),
          ),
        );
      },
    );
  }
}
