import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w(8)),
      child: Container(
        width: w(4),
        height: h(4),
        decoration: const BoxDecoration(
          color: Color(0xff787878),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
