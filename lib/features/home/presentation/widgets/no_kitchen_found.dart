import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

Widget buildNoKitchenFound(BuildContext context) {
  return Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/no_kitchen_found.png",
            width: w(140),
            height: h(150),
            fit: BoxFit.contain,
          ),
          SizedBox(height: h(20)),
          Text(
            "No Kitchen Found",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Color(0xffC3C3C3)),
          ),
        ],
      ),
    ),
  );
}
