import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/no_internet.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
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

  String fullText = "FOOD KITCHEN";
  List<bool> visibleLetters = [];
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    userBloc = context.read<UserBloc>();
    userCubit = context.read<UserCubit>();
    getCurrentUser();
    visibleLetters = List.filled(fullText.length, false);
    _startTextAnimation();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    updatePlansStartDate();
  }

  void updatePlansStartDate() async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final sharedPreferences = await SharedPreferences.getInstance();

    String? endTime = sharedPreferences.getString("end-date");
    debugPrint("Fetched end-time from prefs: $endTime");

    if (endTime != null) {
      DateTime endDateTime = parseDate(endTime);

      final endDateInDaysMonthYear = DateTime(
        endDateTime.year,
        endDateTime.month,
        endDateTime.day,
      );

      if (endDateInDaysMonthYear.isBefore(today)) {
        debugPrint("End date reached! Resetting start and end dates...");

        sharedPreferences.setString("start-date", formatDate(today));
        debugPrint("Start date updated to today: ${formatDate(today)}");

        if (AppConstants.entitlementIsActive == false) {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 2)));
          sharedPreferences.setString("end-date", newEndDate);
          debugPrint("Free user — new end-date set to: $newEndDate");
        } else {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 6)));
          sharedPreferences.setString("end-date", newEndDate);
          debugPrint("Premium user — new end-date set to: $newEndDate");
        }
      }
    }
  }

  void _startTextAnimation() {
    const duration = Duration(milliseconds: 150);
    _timer = Timer.periodic(duration, (timer) {
      if (_charIndex < fullText.length) {
        setState(() {
          visibleLetters[_charIndex] = true;
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is TokenExpired) {
            showErrorSnackBar(
              context,
              "Your session has ended. You’ve been logged out, please sign in again!",
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
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.onBoardingBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(fullText.length, (index) {
                final letter = fullText[index];
                return AnimatedOpacity(
                  opacity: visibleLetters[index] ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: t(28),
                      color: Colors.black87,
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    rootScaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        key: UniqueKey(),
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
