import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/validators.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = false;

  void updateObsecure() {
    setState(() {
      _isObscure = !_isObscure;
    });
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
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: gapSymmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Welcome back!".tr(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    "Login to your account.!".tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: h(39)),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: "Email address".tr(),
                          validator: emailValidator,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Enter your email".tr(),
                        ),

                        SizedBox(height: h(20)),
                        AppTextField(
                          controller: _passwordController,
                          label: "Password".tr(),

                          validator: passwordValidator,
                          hintText: "Enter your password".tr(),
                          obscureText: _isObscure,
                          suffixIcon: GestureDetector(
                            onTap: () => updateObsecure(),
                            child: Padding(
                              padding: gapSymmetric(
                                vertical: 13,
                                horizontal: 15,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.eyeVisibilitySvg,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h(20)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(Routes.forgotPassword),
                      child: Text(
                        "Forgot Password?",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: gapOnly(top: 20, bottom: 25),
                    child: GenericButtonWidget(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {}
                      },
                      text: tr("Login"),
                    ),
                  ),

                  TextspanWidget(
                    onSignUpTap: () {
                      context.push(Routes.signUp);
                    },
                    text: "Don't have an account?".tr(),
                    buttonText: "Sign Up".tr(),
                  ),
                  SizedBox(height: h(20)),
                  Center(
                    child: Text(
                      "Or with",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: h(20)),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(h(10)),
                      onTap: () {},
                      child: Ink(
                        width: w(209),
                        padding: gapAll(10),
                        decoration: BoxDecoration(
                          color: Color(0xffF9F8F8),
                          borderRadius: BorderRadius.circular(h(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAssets.googlePng,
                              height: h(22),
                              width: w(22),
                            ),
                            SizedBox(width: w(6)),
                            Text(
                              "Sign In with Google",
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontSize: t(12),
                                    color: Color(0xff757575),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h(110)),
                  Text(
                    "By logging in, you agree to the terms and conditions of this application.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: t(14),
                      color: Color(0xff8F8F8F),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: h(37)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
