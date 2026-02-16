import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_list.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class YourKitchensSection extends StatelessWidget {
  final List<Kitchen> kitchens;
  final UserCubit userCubit;
  final KitchenBloc kitchenBloc;

  const YourKitchensSection({
    super.key,
    required this.kitchens,
    required this.userCubit,
    required this.kitchenBloc,
  });

  @override
  Widget build(BuildContext context) {
    final owned = kitchens
        .where((k) => k.role.toLowerCase() == "host")
        .toList();

    return owned.isEmpty
        ? SizedBox()
        : UpperTile(
            widget: Column(
              spacing: h(6),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle("All Kitchens", context),

                Text(
                  "${owned.length} kitchen found",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                if (owned.isNotEmpty)
                  KitchenList(
                    kitchens: owned,
                    userCubit: userCubit,
                    kitchenBloc: kitchenBloc,
                    isMember: false,
                  ),
              ],
            ),
          );
  }
}
