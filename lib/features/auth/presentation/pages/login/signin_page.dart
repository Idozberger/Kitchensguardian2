import 'package:easy_localization/easy_localization.dart';
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

  void onLogin() {
    context.push(Routes.dashboard);
    // String email = _emailController.text.trim();
    // String password = _passwordController.text.trim();

    // if (email.isEmpty) {
    //   AppToast.show("Email is required", ToastType.error);
    // } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
    //   AppToast.show("Please enter a valid email address", ToastType.error);
    // } else if (password.isEmpty) {
    //   AppToast.show("Password is required", ToastType.error);
    // } else if (password.length < 6) {
    //   AppToast.show("Password must be at least 6 characters", ToastType.error);
    // } else {
    //   context.push(Routes.dashboard);
    // }
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
                    tr("welcome_back"),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    tr("login_to_your_account"),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: h(39)),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: tr("email_address"),
                          // validator: emailValidator,
                          keyboardType: TextInputType.emailAddress,
                          hintText: tr("enter_your_email_address"),
                        ),

                        SizedBox(height: h(20)),
                        AppTextField(
                          controller: _passwordController,
                          label: "password".tr(),

                          // validator: passwordValidator,
                          hintText: "enter_your_password".tr(),
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
                        "forgot_password_question".tr(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: gapOnly(top: 20, bottom: 25),
                    child: GenericButtonWidget(
                      onPressed: () => onLogin(),
                      text: tr("login"),
                    ),
                  ),

                  Center(
                    child: TextspanWidget(
                      buttonColor: AppColors.primaryColor,
                      callback: () {
                        context.push(Routes.signUp);
                      },
                      text: "dont_have_account".tr(),
                      buttonText: "sign_up".tr(),
                    ),
                  ),
                  SizedBox(height: h(20)),
                  Center(
                    child: Text(
                      "or_with".tr(),
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
                      onTap: () {
                        onLogin();
                      },
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
                              "sign_in_with_google".tr(),
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
                    "terms_and_conditions_text".tr(),
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
