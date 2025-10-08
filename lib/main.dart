import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/app/di.dart';

import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initDependencies(),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())],
      child: const AppBase(),
    ),
  );
}
