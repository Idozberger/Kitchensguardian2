import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/signup_scroll_content.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/appbar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userCubit.setGoogleSignUpUserModel(
        firstName: "",
        lastName: "",
        email: "",
      );
    });
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
          _clearStaleSocialSignUpState();
        }
        if (state is AuthUserCreatedSuccess) {
          AppToast.show(state.successMessage, ToastType.success);
          context.pushNamed(
            "verify_email",
            extra: _userModelForVerifyEmail(),
          );
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
            child: SignUpScrollContent(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              isObscure: _isObscure,
              isConfirmPasswordObscure: _isConfirmPasswordObscure,
              onTogglePasswordObscure: updateObscure,
              onToggleConfirmPasswordObscure: updateIsConfirmPasswordObscure,
              onSignUp: () => _handleSignUp(context, state),
              authState: state,
            ),
          ),
        );
      },
    );
  }

  void _clearStaleSocialSignUpState() {
    _userCubit.setGoogleSignUpUserModel(
      firstName: "",
      lastName: "",
      email: "",
    );
  }

  /// Prefer form fields (email signup); fall back to cubit (Google/Apple signup).
  UserModel _userModelForVerifyEmail() {
    final formEmail = _emailController.text.trim();
    if (formEmail.isNotEmpty) {
      return UserModel(
        email: formEmail,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
    final cubitModel = _userCubit.state.userModel;
    return UserModel(
      email: cubitModel?.email ?? "",
      firstName: cubitModel?.firstName ?? "",
      lastName: cubitModel?.lastName ?? "",
      password: cubitModel?.password ?? "",
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
