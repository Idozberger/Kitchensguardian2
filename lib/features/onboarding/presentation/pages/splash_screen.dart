// ignore_for_file: type_literal_in_constant_pattern

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/no_internet.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final UserBloc _userBloc;
  late final UserCubit _userCubit;
  late final AnimationController _animationController;

  static const String _fullText = "KITCHEN GUARDIAN";
  static const Duration _animationDuration = Duration(milliseconds: 1700);

  @override
  void initState() {
    super.initState();

    _userBloc = context.read<UserBloc>();
    _userCubit = context.read<UserCubit>();

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();

    _configureSystemUI();

    _initializeApp();
  }

  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    await Future.wait([_getCurrentUser(), _updatePlansStartDate()]);
  }

  Future<void> _getCurrentUser() async {
    _userBloc.add(GetCurrentUser());
    _userCubit.updateActiveKitchenIdInvitationCodeAndRole(
      activeKitchenId: "",
      invitationCode: "",
      role: "",
    );
  }

  Future<void> _updatePlansStartDate() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final endDateString = sharedPreferences.getString("end-date");

      if (endDateString == null) return;

      final today = _getStartOfDay(DateTime.now());
      final endDate = parseDate(endDateString);

      if (today.isAfter(endDate)) {
        final newEndDate = today.add(const Duration(days: 3));
        await Future.wait([
          sharedPreferences.setString("start-date", formatDate(today)),
          sharedPreferences.setString("end-date", formatDate(newEndDate)),
        ]);
      }
    } catch (e) {
      log('Error updating plans start date: $e');
    }
  }

  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _handleUserState(UserState state) {
    if (!mounted) return;

    switch (state.runtimeType) {
      case TokenExpired:
        _showErrorAndNavigate(
          "Your session has ended. You've been logged out, please sign in again!",
          Routes.signIn,
        );
        break;
      case NoInternet:
        _showError("No Internet Connection");
        break;
      case UserInitial:
        context.go(Routes.onBoarding);
        break;
      case UserOnBoarded:
        context.go(Routes.signIn);
        break;
      case UserSuccess:
        context.go(Routes.kitchenSelection);
        break;
    }
  }

  void _showError(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showErrorAndNavigate(String message, String route) {
    _showSnackBar(message, Colors.red);
    context.go(route);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) => _handleUserState(state),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is NoInternet) {
              return _NoInternetView(
                onRetry: _getCurrentUser,
                isLoading: state is UserLoading,
              );
            }

            return _SplashContent(
              animationController: _animationController,
              text: _fullText,
            );
          },
        ),
      ),
    );
  }
}

class _NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isLoading;

  const _NoInternetView({required this.onRetry, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: NoInternetDialog(callback: onRetry, loading: isLoading),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final AnimationController animationController;
  final String text;

  const _SplashContent({required this.animationController, required this.text});

  @override
  Widget build(BuildContext context) {
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
      child: _AnimatedText(controller: animationController, text: text),
    );
  }
}

class _AnimatedText extends StatelessWidget {
  final AnimationController controller;
  final String text;

  const _AnimatedText({required this.controller, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(text.length, (index) {
        final delay = index / text.length;
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay,
              delay + (1 / text.length),
              curve: Curves.easeIn,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: Text(
            text[index],
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: t(28),
              color: Colors.black87,
            ),
          ),
        );
      }),
    );
  }
}
