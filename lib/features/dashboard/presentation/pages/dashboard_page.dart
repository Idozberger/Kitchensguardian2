import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_page.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';

import 'package:foodkitchen/features/home/presentation/pages/home_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_selectedIndex != 0) _onItemTapped(0);
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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      elevation: 0,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(AppAssets.homeActiveSvg),
          icon: SvgPicture.asset(AppAssets.homeInactiveSvg),
          label: "Home",
        ),
        BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(AppAssets.plannerActiveSvg),
          icon: SvgPicture.asset(AppAssets.plannerInactiveSvg),
          label: "Planner",
        ),
        BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(AppAssets.groceryActiveSvg),
          icon: SvgPicture.asset(AppAssets.groceryInactiveSvg),
          label: "Grocery",
        ),
        BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(AppAssets.profileActiveSvg),
          icon: SvgPicture.asset(AppAssets.profileInactiveSvg),
          label: "Profile",
        ),
      ],
    );
  }
}
