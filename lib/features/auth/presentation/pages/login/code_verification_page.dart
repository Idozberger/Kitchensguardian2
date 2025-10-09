import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordVerificationPage extends StatefulWidget {
  final String email;
  const ResetPasswordVerificationPage({super.key, required this.email});

  @override
  State<ResetPasswordVerificationPage> createState() =>
      _ResetPasswordVerificationPageState();
}

class _ResetPasswordVerificationPageState
    extends State<ResetPasswordVerificationPage> {
  final _formKey = GlobalKey<FormState>();

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
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthForgotMailSent) {}
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
                    "Resetting your password",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    "Please use the 5 digit PIN we sent you to your email address to reset your password. if you didn’t receive it, check your inbox, spam or promotions folder.",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: h(30)),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        OtpField(
                          onCompleted: (code) {
                            updatePin(code);
                            debugPrint("Entered OTP: $code");
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h(15)),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.push(Routes.createNewPassword);
                      },
                      child: Text(
                        "Continue",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: pin.isNotEmpty
                              ? Colors.black
                              : Color(0xffD5D5D5),
                        ),
                      ),
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
