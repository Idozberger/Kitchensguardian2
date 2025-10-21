import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/join_kitchen.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/dialogs/create_kitchen.dart';

class CreateOrJoinKitchenTile extends StatelessWidget {
  const CreateOrJoinKitchenTile({super.key});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have to:",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 15),
          Row(
            children: [
              Expanded(
                child: GenericButtonWidget(
                  isOutlined: true,
                  text: "Create",
                  onPressed: () => showCreateKitchenDialog(context),
                ),
              ),
              gap(width: 10),
              Expanded(
                child: GenericButtonWidget(
                  text: "Join",
                  onPressed: () => showJoinKitchenDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
