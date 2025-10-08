import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool isNaviagted = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthForgotMailSent) {
          if (isNaviagted == false) {
            context.pushNamed(
              'create_new_password',
              extra: _emailController.text.trim(),
            );
            isNaviagted = true;
          }
        }
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: gapSymmetric(horizontal: 20, vertical: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(h(55)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Ink(
                      padding: gapSymmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xffD4D2D2)),
                      ),
                      child: SvgPicture.asset(AppAssets.backArrowiOS),
                    ),
                  ),
                  SizedBox(height: h(24)),
                  Text(
                    "Forgot Password",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    "Enter your email address to reset your password",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: h(24)),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailController,
                          label: "Email address",
                          keyboardType: TextInputType.emailAddress,
                          // validator: emailValidator,
                          hintText: "Enter your email",
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: gapOnly(top: 20, bottom: 25),
                    child: GenericButtonWidget(
                      onPressed: () {
                        String email = _emailController.text.trim();

                        if (email.isEmpty) {
                          AppToast.show("Email is required", ToastType.error);
                        } else if (!RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        ).hasMatch(email)) {
                          AppToast.show(
                            "Please enter a valid email address",
                            ToastType.error,
                          );
                        } else {
                          isNaviagted = false;
                          context.read<AuthBloc>().add(
                            AuthSendPasswordResetEmail(email: email),
                          );
                        }
                      },
                      text: "Send link",
                      isLoading: state is AuthLoading,
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
}
