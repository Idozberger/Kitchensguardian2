import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';

import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/success_page_widget.dart';
import 'package:go_router/go_router.dart';

class EmailVerfiedSuccesPage extends StatelessWidget {
  const EmailVerfiedSuccesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          AppToast.show(state.message, ToastType.error);
        }
      },
      builder: (context, state) {
        return SuccessScreen(
          title: "Successfully Verified",
          subtitle:
              "Successfully verified. You can now log in to your new account.",
          onButtonPressed: () => context.go(Routes.signIn),
        );
      },
    );
  }
}
