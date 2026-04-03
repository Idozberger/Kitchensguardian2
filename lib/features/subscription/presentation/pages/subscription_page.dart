import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_features_tile.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_option_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = "monthly";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                gap(height: 15),
                _buildPlanSelectionSection(),
                gap(height: 15),
                _buildFeaturesSection(),
                gap(height: 15),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(10),
      children: [
        Text(
          "Unlock Premium Access to Exclusive Features!",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          "Subscribe now and enjoy a more cooking experience with premium features.",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildPlanSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(10),
      children: [
        Text(
          "Choose your plan",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        gap(height: 8),
        _buildPlanOptions(),
      ],
    );
  }

  Widget _buildPlanOptions() {
    return Row(
      spacing: w(15),
      children: [
        Flexible(
          child: PlanOptionTile(
            title: "Monthly",
            price: "\$5.99/mo",
            badgeText: "Save 27%",
            isSelected: _selectedPlan == "monthly",
            onSelected: (_) => setState(() => _selectedPlan = "monthly"),
          ),
        ),
        Flexible(
          child: PlanOptionTile(
            title: "Annual",
            price: "\$55/yr",
            badgeText: "Save 27%",
            isSelected: _selectedPlan == "annual",
            onSelected: (_) => setState(() => _selectedPlan = "annual"),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(10),
      children: [
        Text(
          "What's included",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        _buildComparisonTable(),
      ],
    );
  }

  Widget _buildComparisonTable() {
    return PlanComparisonTable(
      features: [
        PlanFeature(title: "No ads", freeValue: false, premiumValue: true),
        PlanFeature(
          title: "Unlimited Recipe generation",
          freeValue: false,
          premiumValue: true,
        ),
        PlanFeature(
          title: "Full 2-week meal planning access",
          freeValue: false,
          premiumValue: true,
        ),
        PlanFeature(
          title: "Unlimited users per shared kitchen",
          freeValue: false,
          premiumValue: true,
        ),
        PlanFeature(
          title: "See all expiring ingredients",
          freeValue: false,
          premiumValue: true,
        ),
        PlanFeature(
          title: "See all low stock ingredients",
          freeValue: false,
          premiumValue: true,
        ),
        PlanFeature(
          title: "Grocery List Generation",
          freeValue: false,
          premiumValue: true,
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return SafeArea(
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: gapOnly(left: 20, right: 20, bottom: 24, top: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: h(16),
            children: [
              _buildPricingText(),
              GenericButtonWidget(
                onPressed: () => _handleStartTrial(),
                text: 'Start Free Trial',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingText() {
    return TextspanWidget(
      style: Theme.of(context).textTheme.headlineMedium,
      callback: () {},
      text: "Get 7 days free, then only",
      buttonText: _selectedPlan == "monthly" ? " \$5.99/mo" : " \$55/year",
      buttonColor: Colors.black,
    );
  }

  void _handleStartTrial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_subscribed", true);
    AppToast.show("Subscribe successfully. ", ToastType.success);
  }

  AppBar _buildAppBar() {
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
