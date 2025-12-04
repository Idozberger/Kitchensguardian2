import 'package:flutter/material.dart';
import 'package:foodkitchen/features/kitchen_selection/presentation/widgets/appbar.dart';

class KitchenSelectionPage extends StatelessWidget {
  const KitchenSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: KitchenSelectionAppBar(parentContext: context));
  }
}
