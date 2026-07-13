import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/success_page_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerifiedSuccessPage extends StatelessWidget {
  const EmailVerifiedSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleStateChange,
      builder: (context, state) =>
          _buildSuccessScreen(context, state is FetchingUserDetails),
    );
  }

  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is FetchedUserDetails) {
      // New user goes straight to the kitchen selection screen (create or
      // join); the feature onboarding runs only after that choice.
      final prefs = sl<SharedPreferences>();
      final country = prefs.getString('country');
      final currency = prefs.getString('currency');
      if (country == null || currency == null) {
        context.goNamed(Routes.countryAndCurrencySetup, extra: false);
      } else {
        context.go(Routes.kitchenSelection);
      }
    }

    if (state is ErrorFetchingUserDetails) {
      _showErrorToast(state.errorMessage);
    }
  }

  Widget _buildSuccessScreen(BuildContext context, bool loading) {
    return SuccessScreen(
      isLoading: loading,
      title: "Email Verified Successfully!",
      subtitle:
          "Your email has been verified. Let's get started with your kitchen!",
      buttonText: "Let's Start",
      onButtonPressed: () => _triggerCurrentUserEvent(context),
    );
  }

  void _triggerCurrentUserEvent(BuildContext context) {
    context.read<AuthBloc>().add(MoveSignUpUserToHome());
  }

  void _showErrorToast(String message) {
    AppToast.show(message, ToastType.error);
  }
}
