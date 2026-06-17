import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class EmptyStateWidget extends StatelessWidget {
  final String imagePath;
  final String title;

  const EmptyStateWidget({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: w(140),
            height: h(150),
            fit: BoxFit.contain,
          ),
          SizedBox(height: h(20)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: const Color(0xffC3C3C3),
            ),
          ),
        ],
      ),
    );
  }
}
