import 'package:flutter/material.dart';
import 'package:foodkitchen/features/home/presentation/pages/home_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/pantry_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/planner_page.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        drawer: Drawer(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      elevation: 0,

      onTap: (index) {
        updateSelectedIndex(index);
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "pantry"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "planner"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "grocery"),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "profile"),
      ],
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: <Widget>[
        HomePage(),
        PantryPage(),
        PlannerPage(),
        Scaffold(),
        Scaffold(),
      ],
    );
  }
}
