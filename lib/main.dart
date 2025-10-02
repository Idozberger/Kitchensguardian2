import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/app/di.dart';

import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/config/localization_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initDependencies(),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),

    LocalizationConfig.instance.initialize(),
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: LocalizationConfig.instance.supportedLocales,
      path: 'assets/langs',
      fallbackLocale: const Locale('en', 'US'),
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())],
        child: const AppBase(),
      ),
    ),
  );
}
