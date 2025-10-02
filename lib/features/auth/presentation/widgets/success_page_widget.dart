import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/extensions/theme_extension.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

/// A reusable success screen widget
class SuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText = "Go to login",
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: gapSymmetric(horizontal: 19, vertical: 24),
                decoration: BoxDecoration(
                  color: context.isDarkTheme
                      ? Colors.white
                      : AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(AppAssets.success),
              ),
              SizedBox(height: h(20)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: h(5)),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 33),
            child: GenericButtonWidget(
              onPressed: onButtonPressed,

              text: buttonText,
            ),
          ),
        ],
      ),
    );
  }
}
