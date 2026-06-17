part of 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';

extension _DashboardPageChrome on _DashboardPageState {
  AppBar buildDashboardAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: false,
      leading: buildDashboardDrawerButton(),
      title: Text(
        "Kitchen's Guardian",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        /*buildDashboardSubscriptionButton(),
        SizedBox(width: w(6)),*/
        buildDashboardConsumptionPendingButton(),
        SizedBox(width: w(6)),
        buildDashboardNotificationButton(),

        //buildDashboardSwitchPremiumButton(context),
        SizedBox(width: w(16)),
      ],
    );
  }

  /*Widget buildDashboardSubscriptionButton() {
    return InkWell(
      onTap: () => openPaywallIfEnabled(context),
      child: Image.asset(AppAssets.gemPNG, height: h(16), fit: BoxFit.cover),
    );
  }*/

  Widget buildDashboardDrawerButton() {
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

  Widget buildDashboardConsumptionPendingButton() {
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

/*
  Widget buildDashboardSwitchPremiumButton(BuildContext context) {
    final isPremium = context.watch<UserCubit>().state.isPremiumUser;

    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: isPremium,
        activeThumbColor: AppColors.primaryColor,
        inactiveThumbColor: Colors.grey,
        activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.5),
        inactiveTrackColor: Colors.grey.shade300,
        onChanged: (value) {
          context.read<UserCubit>().updatePremiumStatus(value);
        },
      ),
    );
  }
*/

  Widget buildDashboardNotificationButton() {
    return CircularIconButton(
      size: 32,
      iconAsset: AppAssets.notificationSvg,
      onTap: () => context.push(Routes.notification),
    );
  }

  Widget buildDashboardBottomNav() {
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
        items: buildDashboardNavItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> buildDashboardNavItems() {
    return [
      buildDashboardNavItem(
        activeIcon: AppAssets.homeActiveSvg,
        inactiveIcon: AppAssets.homeInactiveSvg,
        label: "Home",
      ),
      buildDashboardNavItem(
        activeIcon: AppAssets.plannerActiveSvg,
        inactiveIcon: AppAssets.plannerInactiveSvg,
        label: "Planner",
      ),
      buildDashboardNavItem(
        activeIcon: AppAssets.groceryActiveSvg,
        inactiveIcon: AppAssets.groceryInactiveSvg,
        label: "Grocery",
      ),
      buildDashboardNavItem(
        activeIcon: AppAssets.profileActiveSvg,
        inactiveIcon: AppAssets.profileInactiveSvg,
        label: "Profile",
      ),
    ];
  }

  BottomNavigationBarItem buildDashboardNavItem({
    required String activeIcon,
    required String inactiveIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      activeIcon: buildDashboardNavIcon(activeIcon),
      icon: buildDashboardNavIcon(inactiveIcon),
      label: label,
    );
  }

  Widget buildDashboardNavIcon(String assetPath) {
    return Padding(
      padding: gapOnly(top: 8),
      child: SvgPicture.asset(assetPath),
    );
  }

  void showDashboardExitSnackBar() {
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
        duration: _DashboardPageState._backPressWindow,
        elevation: 2,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
