import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class RemoveAllButton extends StatelessWidget {
  final VoidCallback callback;

  const RemoveAllButton({super.key, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: h(40),

        child: OutlinedButton(
          onPressed: callback,
          child: Text(
            "Remove All",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(12),
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
