import 'package:flutter/material.dart';
import 'package:foodkitchen/features/subscription/presentation/pages/backend_subscription_page.dart';

/// Backend-managed subscription paywall ([docs/api/dummy_subscription_api.md]).
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackendSubscriptionPage();
  }
}
