import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/env.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';

/// Single entry for navigating to the subscription / paywall flow.
void openPaywallIfEnabled(BuildContext context) {
  if (!Env.billingUiEnabled) {
    AppToast.show(
      'Subscriptions are not available yet.',
      ToastType.info,
    );
    return;
  }
  context.push(Routes.subscription);
}
