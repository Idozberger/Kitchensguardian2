import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class NoInternetDialog extends StatelessWidget {
  final VoidCallback callback;
  final bool loading;
  const NoInternetDialog({
    super.key,
    required this.callback,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                isLoading: loading,
                onPressed: callback,
                text: "Try Again",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
