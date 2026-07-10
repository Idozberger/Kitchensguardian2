import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/subscription/data/datasource/subscription_remote_datasource.dart';
import 'package:foodkitchen/features/subscription/data/models/backend_subscription_plan.dart';
import 'package:foodkitchen/features/subscription/presentation/subscription_plan_catalog.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/plan_option_tile.dart';
import 'package:foodkitchen/features/subscription/presentation/widgets/subscription_paywall_content.dart';

/// Dummy / server-managed subscription (no App Store or Play billing).
class BackendSubscriptionPage extends StatefulWidget {
  const BackendSubscriptionPage({super.key});

  @override
  State<BackendSubscriptionPage> createState() =>
      _BackendSubscriptionPageState();
}

class _BackendSubscriptionPageState extends State<BackendSubscriptionPage> {
  final SubscriptionRemoteDatasource _subscriptionApi =
      sl<SubscriptionRemoteDatasource>();

  List<BackendSubscriptionPlan> _plans = [];
  BackendSubscriptionPlan? _selected;
  bool _loading = true;
  String? _loadError;
  bool _subscribing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPlans());
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final plans = await _subscriptionApi.fetchPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selected = SubscriptionPlanCatalog.defaultSelection(plans);
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final result = await _subscriptionApi.restoreSubscription();
      if (!mounted) return;
      await context.read<UserCubit>().setUser();
      if (!mounted) return;
      final active = result['entitlement_is_active'] == true;
      if (active) {
        AppToast.show(
          _readApiMessage(result, fallback: 'Subscription restored.'),
          ToastType.success,
        );
        Navigator.of(context).pop();
      } else {
        AppToast.show(
          'No active subscription found on your account.',
          ToastType.warning,
        );
      }
    } on Object catch (e) {
      AppToast.show(e.toString(), ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _restoring = false);
      }
    }
  }

  Future<void> _subscribe() async {
    final plan = _selected;
    if (plan == null) {
      AppToast.show('Select a plan to continue.', ToastType.warning);
      return;
    }
    setState(() => _subscribing = true);
    try {
      final result = await _subscriptionApi.subscribe(planId: plan.planId);
      if (!mounted) return;
      await context.read<UserCubit>().setUser();
      if (!mounted) return;
      final active = result['entitlement_is_active'] == true;
      if (!active) {
        AppToast.show(
          'Subscription could not be activated. Try again.',
          ToastType.error,
        );
        return;
      }
      AppToast.show(
        _readApiMessage(result, fallback: 'Welcome to Premium!'),
        ToastType.success,
      );
      Navigator.of(context).pop();
    } on Object catch (e) {
      AppToast.show(e.toString(), ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _subscribing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _loading || _loadError != null
          ? null
          : _buildBottomSection(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: gapSymmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Could not load subscription plans.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              gap(height: 12),
              Text(
                _loadError!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              gap(height: 16),
              GenericButtonWidget(onPressed: _loadPlans, text: 'Retry'),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubscriptionPaywallHeader(),
              gap(height: 15),
              _buildPlanSelectionSection(),
              gap(height: 15),
              const SubscriptionIncludedFeatures(),
              gap(height: 15),
              Text(
                'Premium access is managed by your Kitchen Guardian account. '
                'For testing, your backend can activate plans without App Store '
                'or Google Play billing.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xff787878),
                  height: 1.4,
                ),
              ),
              gap(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelectionSection() {
    if (_plans.isEmpty) {
      return Text(
        'No plans returned from GET /api/subscription/plans.',
        style: Theme.of(context).textTheme.headlineMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(10),
      children: [
        Text(
          'Choose your plan',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        gap(height: 8),
        _buildPlanOptions(),
      ],
    );
  }

  Widget _buildPlanOptions() {
    final monthly = SubscriptionPlanCatalog.monthly(_plans);
    final annual = SubscriptionPlanCatalog.annual(_plans);

    if (monthly != null && annual != null && _plans.length == 2) {
      return Row(
        spacing: w(15),
        children: [
          Expanded(child: _planTile(monthly)),
          Expanded(child: _planTile(annual)),
        ],
      );
    }

    return Wrap(
      spacing: w(15),
      runSpacing: h(12),
      children: _plans.map(_planTile).toList(),
    );
  }

  Widget _planTile(BackendSubscriptionPlan plan) {
    final selected = _selected?.planId == plan.planId;
    return PlanOptionTile(
      title: SubscriptionPlanCatalog.displayTitle(plan),
      price: plan.priceDisplay,
      badgeText: SubscriptionPlanCatalog.saveBadgeFor(
        plan: plan,
        allPlans: _plans,
      ),
      isSelected: selected,
      onSelected: (_) => setState(() => _selected = plan),
    );
  }

  Widget _buildBottomSection() {
    final plan = _selected;
    final priceLabel = plan?.priceDisplay ?? '';

    return SafeArea(
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: gapOnly(left: 20, right: 20, bottom: 24, top: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: h(16),
            children: [
              TextspanWidget(
                style: Theme.of(context).textTheme.headlineMedium,
                callback: () {},
                text: 'Subscribe for ',
                buttonText: priceLabel.isEmpty ? '—' : ' $priceLabel',
                buttonColor: Colors.black,
              ),
              GenericButtonWidget(
                onPressed: _subscribe,
                text: _subscribing ? 'Processing…' : 'Subscribe',
                isDisabled: _plans.isEmpty || _subscribing || _restoring,
                isLoading: _subscribing,
              ),
            ],
          ),
        ),
      ),
    );
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
      title: Text('Premium', style: Theme.of(context).textTheme.headlineLarge),
      actions: [
        TextButton(
          onPressed: _restoring || _subscribing ? null : _restore,
          child: Text(_restoring ? 'Restoring…' : 'Restore'),
        ),
      ],
    );
  }
}

String _readApiMessage(Map<String, dynamic> json, {required String fallback}) {
  final message = json['message'];
  if (message is String && message.trim().isNotEmpty) {
    return message.trim();
  }
  return fallback;
}
