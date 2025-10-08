import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/code_resend.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  final UserModel userModel;
  const VerifyEmailPage({super.key, required this.userModel});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late UserModel userModel;
  late AuthBloc authBloc;
  final _formKey = GlobalKey<FormState>();

  String verificationCode = "";

  void updatePin(String code) {
    setState(() {
      verificationCode = code;
    });
  }

  @override
  void initState() {
    userModel = widget.userModel;
    authBloc = context.read<AuthBloc>();
    sendVerificationCode();
    super.initState();
  }

  void sendVerificationCode() async {
    authBloc.add(
      AuthSendUserEmailVerficationCode(
        email: userModel.email,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        password: userModel.password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthUserVerified) {
          AppToast.show(state.successMessage, ToastType.success);
          context.go(Routes.emailVerifiedSuccess);
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                    "Verification Code",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: h(5)),
                  Text(
                    "Please type the verification code sent to",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextspanWidget(
                    textAlign: TextAlign.left,
                    callback: () {
                      Navigator.pop(context);
                    },
                    style: Theme.of(context).textTheme.headlineMedium,
                    text: userModel.email,
                    buttonText: "(change Email)",

                    buttonColor: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: h(20)),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enter Code",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: t(15),
                              ),
                        ),
                        SizedBox(height: h(10)),
                        OtpField(
                          onCompleted: (code) {
                            updatePin(code);
                            debugPrint("Entered OTP: $code");
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: gapOnly(top: 20, bottom: 25),
                    child: GenericButtonWidget(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          authBloc.add(
                            AuthVerifyEmail(
                              email: userModel.email,
                              verificationCode: verificationCode,
                            ),
                          );
                        }
                      },
                      text: "Verify",
                      isLoading: state is AuthLoading,
                    ),
                  ),

                  Center(
                    child: TextspanWidget(
                      buttonColor: AppColors.primaryColor,
                      callback: () {
                        sendVerificationCode();

                        _showDialog(context);
                      },
                      text: "I don’t receive a verification code!",
                      buttonText: "Resend",
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
                "Verification code resend successfully",
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
