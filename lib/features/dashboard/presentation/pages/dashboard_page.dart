import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_view.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_page.dart';
import 'package:foodkitchen/features/home/presentation/pages/home_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/planner_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/profile_page.dart';
import 'package:go_router/go_router.dart';

enum DashboardEntryType { normal, notification, planner }

class DashboardPage extends StatefulWidget {
  final bool isFromNotification;
  final DashboardEntryType entryType;

  const DashboardPage({
    super.key,
    required this.isFromNotification,
    required this.entryType,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _pages = [
    HomePage(),
    PlannerPage(),
    GroceryPage(),
    ProfilePage(),
  ];

  static const _backPressWindow = Duration(seconds: 2);

  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  late final UserCubit _userCubit;
  late final DashboardBloc _dashboardBloc;
  @override
  void initState() {
    super.initState();

    _userCubit = context.read<UserCubit>();
    _dashboardBloc = context.read<DashboardBloc>();

    _fetchConsumptionData();
    log(
      "check notification tapped: ${widget.isFromNotification} ${widget.entryType}",
    );
    if (widget.isFromNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationEntry();
      });
    }
  }

  void _handleNotificationEntry() {
    if (widget.entryType == DashboardEntryType.planner) {
      _selectedIndex = 1;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handleBackPress(),
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: false,
      leading: _buildDrawerButton(),
      title: Text(
        "Kitchen's Guardian",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        _buildSubscriptionButton(),
        SizedBox(width: w(6)),
        _buildConsumptionPendingButton(),
        SizedBox(width: w(6)),
        _buildNotificationButton(),

        IconButton(
          onPressed: () async {
            // await FCMService().sendNotification(
            //   "dAZmZpQ9l7_FWKqJo-r5oy:APA91bFiqOhV9Uh9kGLZ-YNxQP3HKfDf_UBaxEvzTyjDQQdfm-qNaH4xIx3rsVYCDH5HE6be7jNj6g45wqZdEQhJ1ueYCI8IT8voqjhKX70jbNPxg7M32fE",
            //   "You have been added to the kitchen",
            //   "Your request to join the kitchen \"${_userCubit.state.kitchenName}\" has been approved by the host. You are now added to the kitchen. You can access it anytime using this invitation code: ${_userCubit.state.invitationCode}",
            //   _userCubit.state.invitationCode,
            //   _userCubit.state.kitchenName,
            //   _userCubit.state.role,
            //   _userCubit.state.activeKitchenId,
            // );
            // NotificationService().showNotification(
            //   id: 1,
            //   title: "sdaf",
            //   body: "sdfa",
            //   payload: jsonEncode({
            //     "item": {"itemId": "1fda2bb52bcb453abecb0c184744094c"},

            //     'type': 'meal_plan_reminder',
            //     "invitationCode": _userCubit.state.invitationCode,
            //     "kitchenName": _userCubit.state.kitchenName,
            //     "role": _userCubit.state.role,
            //     'kitchenId': _userCubit.state.activeKitchenId,
            //   }),
            // );
          },
          icon: Icon(Icons.abc),
        ),
      ],
    );
  }

  Widget _buildSubscriptionButton() {
    return InkWell(
      onTap: () => context.push(Routes.subscription),
      child: Image.asset(AppAssets.gemPNG, height: h(16), fit: BoxFit.cover),
    );
  }

  Widget _buildDrawerButton() {
    return Builder(
      builder: (context) => Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            size: 32,
            iconAsset: AppAssets.drawerSvg,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionPendingButton() {
    return BlocBuilder<ConsumptionBloc, ConsumptionState>(
      builder: (context, state) {
        final String pendingCount =
            state.comsumptionConfirmationPendingCount != "0"
            ? state.comsumptionConfirmationPendingCount
            : "";

        final bool showBadge = pendingCount.isNotEmpty;

        return Badge(
          backgroundColor: const Color(0xffFF3300),
          isLabelVisible: showBadge,
          label: Text(
            pendingCount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: CircularIconButton(
            size: 32,
            iconAsset: AppAssets.consumptionPending,
            onTap: () => context.pushNamed(
              Routes.pendingconsumptionconfirmation,
              extra: _userCubit.state.activeKitchenId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton() {
    return CircularIconButton(
      size: 32,
      iconAsset: AppAssets.notificationSvg,
      onTap: () => context.push(Routes.notification),
    );
  }

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.shade200,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        elevation: 0,
        onTap: _onItemTapped,
        items: _buildNavItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      _buildNavItem(
        activeIcon: AppAssets.homeActiveSvg,
        inactiveIcon: AppAssets.homeInactiveSvg,
        label: "Home",
      ),
      _buildNavItem(
        activeIcon: AppAssets.plannerActiveSvg,
        inactiveIcon: AppAssets.plannerInactiveSvg,
        label: "Planner",
      ),
      _buildNavItem(
        activeIcon: AppAssets.groceryActiveSvg,
        inactiveIcon: AppAssets.groceryInactiveSvg,
        label: "Grocery",
      ),
      _buildNavItem(
        activeIcon: AppAssets.profileActiveSvg,
        inactiveIcon: AppAssets.profileInactiveSvg,
        label: "Profile",
      ),
    ];
  }

  BottomNavigationBarItem _buildNavItem({
    required String activeIcon,
    required String inactiveIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      activeIcon: _buildNavIcon(activeIcon),
      icon: _buildNavIcon(inactiveIcon),
      label: label,
    );
  }

  Widget _buildNavIcon(String assetPath) {
    return Padding(
      padding: gapOnly(top: 8),
      child: SvgPicture.asset(assetPath),
    );
  }

  void _showExitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.exit_to_app_rounded,
              color: Color(0xFF2D3142),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Press back again to exit",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: _backPressWindow,
        elevation: 2,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  Future<void> _handleBackPress() async {
    if (_selectedIndex != 0) {
      _onItemTapped(0);
      return;
    }

    final now = DateTime.now();
    final isDoublePress =
        _lastBackPressed != null &&
        now.difference(_lastBackPressed!) <= _backPressWindow;

    if (isDoublePress) {
      _lastBackPressed = null;
      SystemNavigator.pop();
      return;
    }

    _lastBackPressed = now;
    _showExitSnackBar();
  }

  void _fetchConsumptionData() {
    context.read<ConsumptionBloc>().add(
      GetConsumptionConfirmationPendingCountEvent(
        kitchenId: _userCubit.state.activeKitchenId,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }
}
