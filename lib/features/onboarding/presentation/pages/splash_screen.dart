// ignore_for_file: type_literal_in_constant_pattern, use_build_context_synchronously
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/no_internet_view.dart';
import 'package:foodkitchen/features/onboarding/presentation/widgets/splash_content_widget.dart';
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
    try {
      await Future.wait([_getCurrentUser(), _updatePlansStartDate()]);
    } catch (e) {
      log('Error initializing app: $e');
    }
  }

  void navigateAuthenticatedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString("country");
    final currency = prefs.getString("currency");
    if (country == null || currency == null) {
      if (mounted) {
        context.goNamed(Routes.countryAndCurrencySetup, extra: false);
      }
    } else {
      context.go(Routes.kitchenSelection);
    }
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
        navigateAuthenticatedUser();
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
              return NoInternetView(
                onRetry: _getCurrentUser,
                isLoading: state is UserLoading,
              );
            }

            return SplashContent(
              animationController: _animationController,
              text: _fullText,
            );
          },
        ),
      ),
    );
  }
}
