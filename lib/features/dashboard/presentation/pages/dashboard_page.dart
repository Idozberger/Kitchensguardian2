import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
//import 'package:foodkitchen/core/navigation/paywall_navigation.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
//import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_view.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_page.dart';
import 'package:foodkitchen/features/home/presentation/pages/home_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/planner_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/profile_page.dart';
import 'package:go_router/go_router.dart';

part 'dashboard_page_part.dart';

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
  late final List<bool> _tabEverOpened;

  static const _backPressWindow = Duration(seconds: 2);

  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  late final UserCubit _userCubit;
  @override
  void initState() {
    super.initState();
    _tabEverOpened = [true, false, false, false];

    _userCubit = context.read<UserCubit>();

    _fetchConsumptionData();
    devLog(
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
      setState(() {
        _selectedIndex = 1;
        _tabEverOpened[1] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handleBackPress(),
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: buildDashboardAppBar(context),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: List<Widget>.generate(4, _lazyTab),
          ),
        ),
        bottomNavigationBar: buildDashboardBottomNav(),
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
    showDashboardExitSnackBar();
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
      setState(() {
        _tabEverOpened[index] = true;
        _selectedIndex = index;
      });
    }
  }

  Widget _lazyTab(int i) {
    if (!_tabEverOpened[i]) {
      return const SizedBox.shrink();
    }
    return _pageForIndex(i);
  }

  Widget _pageForIndex(int i) {
    switch (i) {
      case 0:
        return const HomePage();
      case 1:
        return const PlannerPage();
      case 2:
        return const GroceryPage();
      case 3:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }
}
