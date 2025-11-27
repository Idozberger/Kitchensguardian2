import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:lottie/lottie.dart';

class HistoryLoadingView extends StatelessWidget {
  const HistoryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(AppAssets.loader));
  }
}
