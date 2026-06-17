import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/sign_in_scroll_content.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late UserCubit _userCubit;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
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
    _initSharedPreferencs();
    _userCubit.setGoogleSignUpUserModel(firstName: "", lastName: "", email: "");
  }

  void _initSharedPreferencs() {
    prefs = sl<SharedPreferences>();
  }

  void _handleLogin(AuthState state) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty) {
      AppToast.show("Email is required", ToastType.error);
      return;
    }
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
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

    context.read<AuthBloc>().add(AuthSignIn(email: email, password: password));
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInEvent());
  }

  void _navigateToVerifyEmail(String email, String password) {
    final verifyEmail = email.isNotEmpty
        ? email
        : (_userCubit.state.userModel?.email ?? "");
    context.pushNamed(
      "verify_email",
      extra: UserModel(
        email: verifyEmail,
        firstName: "",
        lastName: "",
        password: password,
      ),
    );
  }

  void _handleSuccessState(AuthSuccess state) {
    AppToast.show(state.successMessage, ToastType.success);
    final country = prefs.getString("country");
    final currency = prefs.getString("currency");
    if (country == null || currency == null) {
      context.goNamed(Routes.countryAndCurrencySetup, extra: false);
    } else {
      context.go(Routes.kitchenSelection);
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
          _handleSuccessState(state);
        }
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);
          if (state.message != "User not verified") {
            _userCubit.setGoogleSignUpUserModel(
              firstName: "",
              lastName: "",
              email: "",
            );
          }

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
            child: SignInScrollContent(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              isObscure: _isObscure,
              onToggleObscure: updateObscure,
              onLogin: () => _handleLogin(state),
              onGoogleSignIn: _handleGoogleSignIn,
              authState: state,
            ),
          ),
        );
      },
    );
  }
}
