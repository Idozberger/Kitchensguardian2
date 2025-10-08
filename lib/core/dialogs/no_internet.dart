import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:go_router/go_router.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.noInternetPng,
              height: h(488),
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
          gap(height: 35),
          Padding(
            padding: gapSymmetric(horizontal: 30),
            child: Column(
              children: [
                Text(
                  "No Internet",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                gap(height: 5),
                Text(
                  "Seem you have no internet connected. Please",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                Text(
                  "try again",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                gap(height: 20),
                GenericButtonWidget(
                  onPressed: () {
                    context.go(Routes.signIn);
                  },
                  text: "Try Again",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
