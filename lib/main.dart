import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/ads/ad_service.dart';
import 'package:foodkitchen/core/common/cubits/app_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/services/firebase_messenging/firebase_messenging_service.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:foodkitchen/firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    await AdService.instance.initialize();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await AppLogger.configureCrashReporting();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await Future.wait([
      initDependencies(),
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    ]);

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
          BlocProvider<UserCubit>(create: (_) => sl<UserCubit>()),
          BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
          BlocProvider<AppCubit>(create: (_) => sl<AppCubit>()),
        ],
        child: const AppBase(),
      ),
    );
  }, (Object error, StackTrace stack) {
    // Always surface the underlying error; Crashlytics may be unavailable if the
    // failure happened before Firebase.initializeApp() completed.
    debugPrint('Uncaught zone error: $error\n$stack');
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (e) {
      debugPrint('Crashlytics unavailable, could not record error: $e');
    }
  });
}
