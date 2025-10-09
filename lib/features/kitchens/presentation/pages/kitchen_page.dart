import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/join_kitchen.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/auth/presentation/widgets/textspan_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/home/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_cubit.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:go_router/go_router.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  late KitchenCubit kitchenCubit;
  @override
  void initState() {
    kitchenCubit = context.read<KitchenCubit>();
    getKichen();
    super.initState();
  }

  getKichen() async {
    await kitchenCubit.getKitchens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<KitchenCubit, KitchenState>(
        listener: (context, state) {},
        builder: (_, kitchenState) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context),
                    SizedBox(height: h(20)),
                    _buildCreateKitchenTile(context),
                    SizedBox(height: h(20)),
                    _buildKitchenHaveSection(context, kitchenState),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      title: Text(
        "Kitchen’s",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen You Have Joined",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: h(15)),
          Text(
            "No Kitchen Found",
            style: Theme.of(context).textTheme.headlineMedium!,
          ),
          SizedBox(height: h(15)),

          GenericButtonWidget(
            onPressed: () {
              showJoinKitchenDialog(context);
            },
            text: "Join a Kitchen",
          ),
        ],
      ),
    );
  }

  Widget _buildCreateKitchenTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create a kitchen",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: h(15)),
          SizedBox(
            width: double.infinity,
            height: h(40),
            child: OutlinedButton(
              onPressed: () {
                showCreateKitchenDialog(context);
              },

              child: Text(
                "Create New",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(14),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenHaveSection(
    BuildContext context,
    KitchenState kitchenState,
  ) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have:",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: h(15)),

          Text(
            kitchenState.kitchenList != null
                ? "${kitchenState.kitchenList!.length} kitchen found: "
                : "1 kitchen found:",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: t(15)),
          ),
          SizedBox(height: h(14)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(AppAssets.avatar, width: w(40), height: h(38)),
                  SizedBox(width: w(5)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextspanWidget(
                        callback: () {},
                        text: "Emily David",
                        buttonText: "(1k Members)",
                        buttonColor: Colors.grey,
                        fontSize: t(12),
                        fontSizeTitle: t(15),
                        titleFontWeight: FontWeight.w500,
                      ),

                      Text(
                        "fakemail@example.coms",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: t(12),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              GenericButtonWidget(
                onPressed: () {
                  context.pop();
                },
                text: "View",
                width: w(90),
                height: h(23),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
