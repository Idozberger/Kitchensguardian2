import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:go_router/go_router.dart';

class MissingItemsListWidget extends StatelessWidget {
  const MissingItemsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Request List",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(10)),
          Text(
            "Request host to buy missing items",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(15),
              color: const Color(0xff787878),
            ),
          ),
          SizedBox(height: h(20)),
          GenericButtonWidget(
            onPressed: () {
              context.push(Routes.requestNow);
            },
            text: "Request Now",
          ),
        ],
      ),
    );
  }
}
