import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_list.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class JoinedKitchensSection extends StatelessWidget {
  final List<Kitchen> kitchens;
  final UserCubit userCubit;
  final KitchenBloc kitchenBloc;

  const JoinedKitchensSection({
    super.key,
    required this.kitchens,
    required this.userCubit,
    required this.kitchenBloc,
  });

  @override
  Widget build(BuildContext context) {
    List<Kitchen> joined = kitchens.where((k) => k.role != "host").toList();

    return UpperTile(
      widget: Column(
        spacing: h(6),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (joined.isEmpty)
            sectionTitle("Join Kitchen", context)
          else
            sectionTitle("Kitchen You Have Joined", context),
          if (joined.isEmpty)
            SizedBox()
          else
            KitchenList(
              kitchens: joined,
              userCubit: userCubit,
              kitchenBloc: kitchenBloc,
              isMember: true,
            ),

          GenericButtonWidget(
            text: "Join a Kitchen",
            onPressed: () => showJoinKitchenDialog(context),
          ),
        ],
      ),
    );
  }
}
