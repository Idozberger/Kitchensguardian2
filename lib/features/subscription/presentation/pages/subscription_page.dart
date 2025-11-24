import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_features_tile.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_option_tile.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = "monthly";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unlock Premium Access to Exclusive Features!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                gap(height: 10),
                Text(
                  "Subscribe now and enjoy a more cooking experience with premium features.",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                gap(height: 15),
                Text(
                  "Choose your plan",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                gap(height: 24),
                Row(
                  spacing: w(15),
                  children: [
                    Flexible(
                      child: PlanOptionTile(
                        title: "Monthly",
                        price: "\$5.99/mo",
                        badgeText: "Save 27%",
                        isSelected: selectedPlan == "monthly",
                        onSelected: (_) =>
                            setState(() => selectedPlan = "monthly"),
                      ),
                    ),
                    Flexible(
                      child: PlanOptionTile(
                        title: "Annual",
                        price: "\$55/yr",
                        badgeText: "Save 27%",
                        isSelected: selectedPlan == "annual",
                        onSelected: (_) =>
                            setState(() => selectedPlan = "annual"),
                      ),
                    ),
                  ],
                ),
                gap(height: 15),
                Text(
                  "What’s included",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                PlanComparisonTable(
                  features: [
                    PlanFeature(
                      title: "No ads",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "See unlimited recipes",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "See all nutrition's",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "Unlimited users in kitchen",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "Expiry alerts and suggestive recipes",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "Unlimited pantry history",
                      freeValue: false,
                      premiumValue: true,
                    ),
                    PlanFeature(
                      title: "Auto grocery list from planner",
                      freeValue: false,
                      premiumValue: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: gapOnly(left: 20, right: 20, bottom: 24, top: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextspanWidget(
                style: Theme.of(context).textTheme.headlineMedium,
                callback: () {},
                text: "Get 7 days free, then only",
                buttonText: selectedPlan == "monthly"
                    ? " \$5.99/mo"
                    : " \$55/year",
                buttonColor: Colors.black,
              ),
              gap(height: 16),
              GenericButtonWidget(onPressed: () {}, text: 'Start Free Trail'),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Premium Screen",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
