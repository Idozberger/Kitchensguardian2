import 'package:foodkitchen/features/subscription/data/models/backend_subscription_plan.dart';

/// Shared plan ordering and annual savings for subscription UI.
abstract final class SubscriptionPlanCatalog {
  static BackendSubscriptionPlan? monthly(
    List<BackendSubscriptionPlan> plans,
  ) {
    for (final p in plans) {
      if (p.isMonthly) {
        return p;
      }
    }
    return null;
  }

  static BackendSubscriptionPlan? annual(List<BackendSubscriptionPlan> plans) {
    for (final p in plans) {
      if (p.isAnnual) {
        return p;
      }
    }
    return null;
  }

  static BackendSubscriptionPlan? defaultSelection(
    List<BackendSubscriptionPlan> plans,
  ) {
    if (plans.isEmpty) {
      return null;
    }
    return monthly(plans) ?? plans.first;
  }

  static String displayTitle(BackendSubscriptionPlan plan) {
    if (plan.title.isNotEmpty) {
      return plan.title;
    }
    if (plan.isMonthly) {
      return 'Monthly';
    }
    if (plan.isAnnual) {
      return 'Annual';
    }
    return plan.planId;
  }

  static int? annualSavePercent({
    required BackendSubscriptionPlan? monthly,
    required BackendSubscriptionPlan? annual,
  }) {
    final monthlyPrice = monthly?.priceAmount ?? 0;
    final annualPrice = annual?.priceAmount ?? 0;
    if (monthlyPrice <= 0 || annualPrice <= 0) {
      return null;
    }
    final monthlyAnnualTotal = monthlyPrice * 12;
    if (monthlyAnnualTotal <= annualPrice) {
      return null;
    }
    return (((monthlyAnnualTotal - annualPrice) / monthlyAnnualTotal) * 100)
        .round();
  }

  static String? saveBadgeFor({
    required BackendSubscriptionPlan plan,
    required List<BackendSubscriptionPlan> allPlans,
  }) {
    if (!plan.isAnnual) {
      return null;
    }
    final percent = annualSavePercent(
      monthly: monthly(allPlans),
      annual: annual(allPlans) ?? plan,
    );
    if (percent == null || percent <= 0) {
      return null;
    }
    return 'Save $percent%';
  }
}
