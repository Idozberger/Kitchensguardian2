import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:go_router/go_router.dart';

class PremiumCardWidget extends StatelessWidget {
  final String titleLine1;
  final String titleLine2;
  final String description;
  final bool isGoProButtonEnabled;
  const PremiumCardWidget({
    super.key,
    this.titleLine1 = "Unlock Premium",
    this.titleLine2 = "Features!",
    this.description =
        "Subscribe now and enjoy a more cooking experience with premium features.",
    this.isGoProButtonEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(h(12)),
      onTap: () => context.push(Routes.subscription),
      child: Container(
        width: double.infinity,
        padding: gapSymmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xffF6A500),
          borderRadius: BorderRadius.circular(h(12)),
          image: DecorationImage(
            image: AssetImage(AppAssets.premiumBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleLine1, style: Theme.of(context).textTheme.headlineLarge),
            Text(titleLine2, style: Theme.of(context).textTheme.headlineLarge),
            gap(height: 5),
            Text(
              description,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: t(12),
                color: Colors.black,
              ),
            ),
            if (isGoProButtonEnabled) ...[
              gap(height: 10),
              GenericButtonWidget(
                onPressed: () {
                  context.push(Routes.subscription);
                },
                width: w(110),
                height: h(24),
                text: "Go Pro",
                color: Color(0xffDE7600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
