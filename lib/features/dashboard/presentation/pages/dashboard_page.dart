import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_page.dart';
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
  void updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
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
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            AppToast.show("Premium", ToastType.success);
          },
          icon: Image.asset(AppAssets.gemPNG, height: h(16), width: w(22)),
        ),
        CircularIconButton(
          iconAsset: AppAssets.notificationSvg,
          onTap: () {
            context.push(Routes.notification);
          },
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
      currentIndex: _selectedIndex,
      elevation: 0,

      onTap: (index) {
        updateSelectedIndex(index);
      },
      items: [
        BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(AppAssets.homeActiveSvg),
          icon: SvgPicture.asset(AppAssets.homeInactiveSvg),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(AppAssets.plannerInactiveSvg),
          activeIcon: SvgPicture.asset(AppAssets.plannerActiveSvg),
          label: "Planner",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(AppAssets.groceryInactiveSvg),
          activeIcon: SvgPicture.asset(AppAssets.groceryActiveSvg),
          label: "Grocery",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(AppAssets.profileInactiveSvg),
          activeIcon: SvgPicture.asset(AppAssets.profileActiveSvg),
          label: "Profile",
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          HomePage(),
          PlannerPage(),
          GroceryPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
