import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppBase extends StatelessWidget {
  const AppBase({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey.shade300,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      builder: (context, child) {
        return MediaQuery.withNoTextScaling(child: child!);
      },

      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
