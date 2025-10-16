import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/no_internet.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late UserBloc userBloc;
  late UserCubit userCubit;

  @override
  void initState() {
    super.initState();
    userBloc = context.read<UserBloc>();
    userCubit = context.read<UserCubit>();
    getCurrentUser();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? activeKitchenId = prefs.getString('kitchen_id');
    final String? invitationCode = prefs.getString('invitation_code');
    final String? role = prefs.getString('role');

    userBloc.add(GetCurrentUser());
    userCubit.updateActiveKitchenIdInvitationCodeAndRole(
      activeKitchenId: activeKitchenId ?? "",
      invitationCode: invitationCode ?? "",
      role: role ?? "member",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is TokenExpired) {
            showErrorSnackBar(
              context,
              "You are logged out, please sign-in again!",
            );
            context.go(Routes.signIn);
          } else if (state is NoInternet) {
            showErrorSnackBar(context, "No Internet Connection");
          } else if (state is UserInitial) {
            context.go(Routes.onBoarding);
          } else if (state is UserSuccess) {
            context.go(Routes.dashboard);
          }
        },
        builder: (_, state) {
          if (state is NoInternet) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: NoInternetDialog(
                callback: getCurrentUser,
                loading: state is UserLoading,
              ),
            );
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.onBoardingBg),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
