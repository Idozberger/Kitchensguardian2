import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
          appBar: AppBar(),
          body: Column(
            children: [
              GenericButtonWidget(
                isLoading: (state is AuthLoading),
                onPressed: () {
                  context.read<AuthBloc>().add(
                    AuthSignUp(
                      email: "email@email.com",
                      firstName: "firstName",
                      lastName: "lastName",
                      password: "password",
                    ),
                  );
                },
                text: "SignUp",
              ),
            ],
          ),
        );
      },
    );
  }
}
