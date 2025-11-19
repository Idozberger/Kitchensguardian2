import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/firebase_messenging/firebase_messenging_service.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_page.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';

import 'package:foodkitchen/features/home/presentation/pages/home_page.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/pages/planner_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/profile_page.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late UserCubit userCubit;
  @override
  void initState() {
    userCubit = context.read<UserCubit>();
    cancelNotificationsForItemExpiring();
    _initializeFirebaseMessaging();
    super.initState();
  }

  Future<void> cancelNotificationsForItemExpiring() async {
    await NotificationService().cancelAllNotifications();
  }

  final List<Widget> _pages = const [
    HomePage(),
    PlannerPage(),
    GroceryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      context.read<HomeBloc>().add(GetAllWeeklyPlansEventForHome());

      _selectedIndex = index;
    });
  }

  Future<void> _initializeFirebaseMessaging() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));

      try {
        final userState = userCubit.state;
        if (userState.userId.isNotEmpty && userState.email.isNotEmpty) {
          await FirebaseMessagingService.instance().init(
            userId: userState.userId,
            firstName: userState.firstName,
            lastName: userState.lastName,
            email: userState.email,
          );
        } else {
          debugPrint('Skipping FCM init — missing userId or email.');
        }
      } catch (e, st) {
        debugPrint('Error initializing FCM: $e');
        debugPrint('Stack trace: $st');
      }
    });
  }

  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_selectedIndex != 0) {
          _onItemTapped(0);
          return;
        }

        final now = DateTime.now();

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
            ),
          );

          return;
        }

        _lastBackPressed = null;
        SystemNavigator.pop();
      },
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
      leading: Builder(
        builder: (context) {
          return Row(
            children: [
              SizedBox(width: w(16)),
              CircularIconButton(
                iconAsset: AppAssets.drawerSvg,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(Routes.subscription),
          icon: Image.asset(AppAssets.gemPNG, height: h(16), width: w(22)),
        ),
        CircularIconButton(
          iconAsset: AppAssets.notificationSvg,
          onTap: () => context.push(Routes.notification),
        ),
        SizedBox(width: w(20)),
      ],
      title: Text(
        "Kitchen’s Guardian",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
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
        items: [
          BottomNavigationBarItem(
            activeIcon: icon(AppAssets.homeActiveSvg),
            icon: icon(AppAssets.homeInactiveSvg),
            label: "Home",
          ),
          BottomNavigationBarItem(
            activeIcon: icon(AppAssets.plannerActiveSvg),
            icon: icon(AppAssets.plannerInactiveSvg),
            label: "Planner",
          ),
          BottomNavigationBarItem(
            activeIcon: icon(AppAssets.groceryActiveSvg),
            icon: icon(AppAssets.groceryInactiveSvg),
            label: "Grocery",
          ),
          BottomNavigationBarItem(
            activeIcon: icon(AppAssets.profileActiveSvg),
            icon: icon(AppAssets.profileInactiveSvg),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget icon(String assetPath) {
    return Padding(
      padding: gapOnly(top: 8),
      child: SvgPicture.asset(assetPath),
    );
  }
}
