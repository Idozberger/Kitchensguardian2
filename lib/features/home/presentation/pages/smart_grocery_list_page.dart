// ignore_for_file: unnecessary_underscores

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:share_plus/share_plus.dart';

class SmartCartPage extends StatefulWidget {
  const SmartCartPage({super.key});

  @override
  State<SmartCartPage> createState() => _SmartCartPageState();
}

class _SmartCartPageState extends State<SmartCartPage> {
  late List<int> quantities;
  late HomeBloc homeBloc;

  @override
  void initState() {
    super.initState();
    homeBloc = context.read<HomeBloc>();
    quantities = [];
    for (int i = 0; i < homeBloc.state.groceryList.length; i++) {
      log("Amount: ${homeBloc.state.groceryList[i].amount}");
      quantities.add(
        double.tryParse(homeBloc.state.groceryList[i].amount)?.toInt() ?? 1,
      );
    }
  }

  void increase(int index) {
    setState(() {
      quantities[index] = quantities[index] + 1;
    });
  }

  void decrease(int index) {
    setState(() {
      if (quantities[index] > 1) {
        quantities[index] = quantities[index] - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = homeBloc.state.groceryList;

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: items.isEmpty ? _buildEmptyState() : _buildGroceryList(items),
      bottomNavigationBar: items.isEmpty
          ? SizedBox()
          : _buildBottomActions(context, items),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.groceryEmpty, height: h(54)),

          gap(height: 20),

          Text(
            "Your grocery list is empty",
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontSize: t(16),
              color: Colors.grey.shade400,
            ),
          ),

          gap(height: 20),
        ],
      ),
    );
  }

  Widget _buildGroceryList(List<IngredientEntity> items) {
    return Padding(
      padding: gapSymmetric(horizontal: 20, vertical: 10),
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => gap(height: 12),
        itemBuilder: (context, index) {
          final ingredient = items[index];
          final qty = quantities[index];

          return UpperTile(
            widget: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        ingredient.unit,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quantityButton(Icons.remove, () => decrease(index)),
                    SizedBox(
                      width: w(32),
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    _quantityButton(Icons.add, () => increase(index)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(h(20)),
      child: Container(
        padding: gapAll(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(h(20)),
        ),
        child: Icon(icon, size: t(14), color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    List<IngredientEntity> items,
  ) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Row(
        children: [
          Expanded(
            child: GenericButtonWidget(
              text: "Share",
              onPressed: () => _shareList(items),
            ),
          ),
          gap(width: 12),
          Expanded(
            child: GenericButtonWidget(
              text: "Copy List",
              onPressed: () => _copyList(items),
            ),
          ),
        ],
      ),
    );
  }

  void _copyList(List<IngredientEntity> items) {
    String result = "My Grocery List\n\n";

    for (int i = 0; i < items.length; i++) {
      final ingredient = items[i];
      int qty = quantities[i].toInt();

      if (qty > 1) {
        result +=
            "• $qty × ${ingredient.amount} ${ingredient.unit} ${ingredient.name}\n";
      } else {
        result +=
            "• ${ingredient.amount} ${ingredient.unit} ${ingredient.name}\n";
      }
    }

    Clipboard.setData(ClipboardData(text: result));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("List copied!")));
  }

  void _shareList(List<IngredientEntity> items) {
    String result = "My Grocery List\n\n";

    for (int i = 0; i < items.length; i++) {
      final ingredient = items[i];
      int qty = quantities[i].toInt();

      if (qty > 1) {
        result +=
            "• $qty × ${ingredient.amount} ${ingredient.unit} ${ingredient.name}\n";
      } else {
        result +=
            "• ${ingredient.amount} ${ingredient.unit} ${ingredient.name}\n";
      }
    }

    Share.share(result, subject: "My Grocery List");
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: w(70),
      leading: Row(
        children: [
          gap(width: 16),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Smart Grocery List",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      centerTitle: true,
    );
  }
}
