import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final String email;

  const CreateNewPasswordPage({super.key, required this.email});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isObscurePassword = false;
  bool _isObscureConfirmPassword = false;
  void updateObsecurePassword() {
    setState(() {
      _isObscurePassword = !_isObscurePassword;
    });
  }

  void updateObsecureConfirmPassword() {
    setState(() {
      _isObscureConfirmPassword = !_isObscureConfirmPassword;
    });
  }

  String pin = "";

  void updatePin(String value) {
    setState(() {
      pin = value;
    });
  }

  void onResendCode() {
    context.read<AuthBloc>().add(
      AuthSendPasswordResetEmail(email: widget.email),
    );
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthUserPasswordChanged) {
          AppToast.show(state.successMessage, ToastType.success);
          context.go(Routes.passwordChangedSuccess);
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
                    "Create new password",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    "Create a strong, secure password to update your account and protect your information.",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: h(20)),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verification Code",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: h(15)),
                        OtpField(
                          onCompleted: (code) {
                            updatePin(code);
                            debugPrint("Entered OTP: $code");
                          },
                        ),
                        SizedBox(height: h(20)),
                        AppTextField(
                          controller: _passwordController,
                          label: "New password",
                          // validator: passwordValidator,
                          hintText: "Enter new password",
                          obscureText: !_isObscurePassword,
                          suffixIcon: GestureDetector(
                            onTap: () => updateObsecurePassword(),
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
                        SizedBox(height: h(20)),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: "Confirm new password",
                          obscureText: !_isObscureConfirmPassword,
                          // validator: passwordValidator,
                          hintText: "Enter new password",
                          suffixIcon: GestureDetector(
                            onTap: () => updateObsecureConfirmPassword(),
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

                  Padding(
                    padding: gapOnly(top: 20, bottom: 15),
                    child: GenericButtonWidget(
                      onPressed: () {
                        String password = _passwordController.text.trim();
                        String confirmPassword = _confirmPasswordController.text
                            .trim();

                        if (password.isEmpty) {
                          AppToast.show(
                            "Password is required",
                            ToastType.error,
                          );
                        } else if (password.length < 6) {
                          AppToast.show(
                            "Password must be at least 6 characters",
                            ToastType.error,
                          );
                        } else if (confirmPassword.isEmpty) {
                          AppToast.show(
                            "Confirm password is required",
                            ToastType.error,
                          );
                        } else if (password != confirmPassword) {
                          AppToast.show(
                            "Passwords do not match",
                            ToastType.error,
                          );
                        } else {
                          context.read<AuthBloc>().add(
                            AuthSetUserNewPassword(
                              email: widget.email,
                              newPassword: password,
                              verificationCode: pin,
                            ),
                          );
                        }
                      },
                      text: "Create password",
                      isLoading: state is AuthLoading,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        onResendCode();
                        _showDialog(context);
                      },
                      child: Text(
                        "Resend code",
                        style: Theme.of(context).textTheme.bodyMedium!,
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

  Future<dynamic> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Success",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(20),
                ),
              ),
              SizedBox(height: h(10)),
              Text(
                "Your password has been updated successfully.",
                style: Theme.of(context).textTheme.headlineSmall!,
              ),
              SizedBox(height: h(10)),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: w(72),
                  height: h(28),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(h(10)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: Text(
                      "oK",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(fontSize: t(15), color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
