import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/no_internet.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isLoading;

  const NoInternetView({
    super.key,
    required this.onRetry,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: NoInternetDialog(callback: onRetry, loading: isLoading),
    );
  }
}
