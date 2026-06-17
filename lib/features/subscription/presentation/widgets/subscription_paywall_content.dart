import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_features_tile.dart';

class SubscriptionPaywallHeader extends StatelessWidget {
  const SubscriptionPaywallHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(10),
      children: [
        Text(
          'Unlock Premium Access to Exclusive Features!',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          'Subscribe now and enjoy a more cooking experience with premium features.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

/// Feature comparison table for paywall screens.
class SubscriptionIncludedFeatures extends StatelessWidget {
  const SubscriptionIncludedFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's included",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        gap(height: 10),
        PlanComparisonTable(
          features: [
            PlanFeature(title: 'No ads', freeValue: false, premiumValue: true),
            PlanFeature(
              title: 'Unlimited kitchen members',
              freeValue: false,
              premiumValue: true,
            ),
            PlanFeature(
              title: 'Better automations',
              freeValue: false,
              premiumValue: true,
            ),
            PlanFeature(
              title: 'Access to premium features',
              freeValue: false,
              premiumValue: true,
            ),
            PlanFeature(
              title: 'Early access to new features',
              freeValue: false,
              premiumValue: true,
            ),
            PlanFeature(
              title: 'Full week meal planning',
              freeValue: false,
              premiumValue: true,
            ),
          ],
        ),
      ],
    );
  }
}
