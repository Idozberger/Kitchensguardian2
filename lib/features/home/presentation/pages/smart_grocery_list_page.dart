// ignore_for_file: unnecessary_underscores

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:share_plus/share_plus.dart';

class SmartCartPage extends StatefulWidget {
  const SmartCartPage({super.key});

  @override
  State<SmartCartPage> createState() => _SmartCartPageState();
}

class _SmartCartPageState extends State<SmartCartPage> {
  List<int> quantities = [];

  void _syncQuantities(List<RequestedItemEntity> items) {
    if (quantities.length != items.length) {
      quantities = List.generate(
        items.length,
        (i) => double.tryParse(items[i].quantity)?.toInt() ?? 1,
      );

      for (var item in items) {
        log("Amount: ${item.quantity}");
      }
    }
  }

  void increase(int index) {
    setState(() {
      quantities[index]++;
    });
  }

  void decrease(int index) {
    setState(() {
      if (quantities[index] > 1) {
        quantities[index]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),

      body: BlocBuilder<GroceryBloc, GroceryState>(
        builder: (context, groceryState) {
          final items = groceryState.aiGeneratedList ?? [];

          _syncQuantities(items);

          return items.isEmpty ? _buildEmptyState() : _buildGroceryList(items);
        },
      ),

      bottomNavigationBar: BlocBuilder<GroceryBloc, GroceryState>(
        builder: (context, groceryState) {
          final items = groceryState.aiGeneratedList ?? [];

          return items.isEmpty
              ? const SizedBox()
              : _buildBottomActions(context, items);
        },
      ),
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

  Widget _buildGroceryList(List<RequestedItemEntity> items) {
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
    List<RequestedItemEntity> items,
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

  void _copyList(List<RequestedItemEntity> items) {
    String result = "My Grocery List\n\n";

    for (int i = 0; i < items.length; i++) {
      final ingredient = items[i];
      int qty = quantities[i];

      if (qty > 1) {
        result +=
            "• $qty × ${ingredient.quantity} ${ingredient.unit} ${ingredient.name}\n";
      } else {
        result +=
            "• ${ingredient.quantity} ${ingredient.unit} ${ingredient.name}\n";
      }
    }

    Clipboard.setData(ClipboardData(text: result));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("List copied!")));
  }

  void _shareList(List<RequestedItemEntity> items) {
    String result = "My Grocery List\n\n";

    for (int i = 0; i < items.length; i++) {
      final ingredient = items[i];
      int qty = quantities[i];

      if (qty > 1) {
        result +=
            "• $qty × ${ingredient.quantity} ${ingredient.unit} ${ingredient.name}\n";
      } else {
        result +=
            "• ${ingredient.quantity} ${ingredient.unit} ${ingredient.name}\n";
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
