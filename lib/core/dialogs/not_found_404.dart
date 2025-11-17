import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:go_router/go_router.dart';

class NotFound404Dialog extends StatelessWidget {
  const NotFound404Dialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: gapSymmetric(horizontal: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppAssets.notFoundPng,
                height: h(202),
                width: w(250),
                fit: BoxFit.cover,
              ),
            ),
            gap(height: 20),
            Text(
              "Something Went Wrong",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            gap(height: 5),
            Text(
              "We encountered an error",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            Text(
              "while trying to connect with our server",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gap(height: 5),
            Text(
              "Please try after some time.",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gap(height: 20),
            GenericButtonWidget(
              onPressed: () {
                context.pop();
              },
              text: "Close",
            ),
          ],
        ),
      ),
    );
  }
}
