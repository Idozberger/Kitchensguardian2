import 'package:flutter/material.dart';

class HistoryEmptyView extends StatelessWidget {
  const HistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No scan history available.",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
