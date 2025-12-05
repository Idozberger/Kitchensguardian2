// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/action_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/create_or_join_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/pantry_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/smart_cart.dart';
import 'package:foodkitchen/features/home/presentation/widgets/suggestion_recipes.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class KitchenHomeView extends StatefulWidget {
  final HomeState state;
  final bool isGeneratedRecipes;
  final VoidCallback onGeneratePressed;

  const KitchenHomeView({
    super.key,
    required this.state,
    required this.isGeneratedRecipes,
    required this.onGeneratePressed,
  });

  @override
  State<KitchenHomeView> createState() => _KitchenHomeViewState();
}

class _KitchenHomeViewState extends State<KitchenHomeView> {
  bool _showGroceryShimmer = true;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showGroceryShimmer = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 0, top: 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            gap(height: 14),
            UpperTile(
              widget: SizedBox(
                height: h(40),
                child: ElevatedButton.icon(
                  icon: SvgPicture.asset(
                    AppAssets.scanSvg,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    PermissionStatus status = await Permission.camera.status;
                    if (status.isGranted) {
                      context.push(Routes.scanMeal);
                    } else {
                      Navigator.pop(context);
                      PermissionStatus result = await Permission.camera
                          .request();
                      if (result.isGranted) {
                        context.push(Routes.scanMeal);
                      } else if (result.isPermanentlyDenied) {
                        openAppSettings();
                      }
                    }
                  },
                  label: Text(
                    "Scan Receipt",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: t(12),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            gap(height: 8),
            PantrySection(state: state),
            gap(height: 8),
            ActionTile(
              title: "Find Recipes",
              buttonText: "Find Recipes",
              svgPath: AppAssets.findRecipesSvg,
              onTap: () {
                final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
                context.pushNamed(
                  Routes.generateRecipes,
                  extra: {
                    "selected_date": date,
                    "selected_meal_type": "Breakfast",
                    "is_plan": false,
                    "is_edit": false,
                  },
                );
              },
            ),
            gap(height: 8),

            if (_showGroceryShimmer)
              Padding(
                padding: gapOnly(bottom: 8),
                child: _buildGroceryShimmer(),
              )
            else
              BlocBuilder<HomeBloc, HomeState>(
                builder: (_, state) {
                  if (state.groceryList.isEmpty) return SizedBox();
                  return Padding(
                    padding: gapOnly(bottom: 8),
                    child: SmartCartTile(
                      infoText: state.groceryList.length > 3
                          ? "+${state.groceryList.length - 3} tap to see more"
                          : null,
                      isGenerated: state.groceryList.isNotEmpty,
                      previewItems: state.groceryList.take(3).toList(),
                      onGenerate: widget.onGeneratePressed,
                    ),
                  );
                },
              ),

            if (state.loadingRecipeSuggestion)
              Padding(
                padding: gapOnly(bottom: 8),
                child: _buildSuggestionShimmer(),
              )
            else if (state.suggestedRecipe.isNotEmpty)
              Padding(
                padding: gapOnly(bottom: 8),
                child: const SuggestionRecipes(),
              ),

            if (state.loadingWeeklyPlans)
              Padding(
                padding: gapOnly(bottom: 8),
                child: _buildTonightShimmer(),
              )
            else if (state.dateBasedPlan.isNotEmpty)
              const TonightRecipeWidget(),

            gap(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGroceryShimmer() {
    return UpperTile(
      widget: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: h(100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionShimmer() {
    return UpperTile(
      widget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: h(20),
                    width: w(120),
                    color: Colors.white,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: h(24),
                    width: h(24),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h(10)),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.maxFinite,
              height: h(260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonightShimmer() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: h(20),
                    width: w(120),
                    color: Colors.white,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: h(24),
                    width: h(24),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h(10)),

          SizedBox(
            height: h(200),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(width: w(14)),
              itemBuilder: (_, __) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: w(260),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: h(10)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: w(4)),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: w(8),
                    height: h(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class NoKitchenView extends StatelessWidget {
  const NoKitchenView({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: gapOnly(left: 20, right: 20, bottom: 20, top: 14),
    child: Column(
      children: [
        const CreateOrJoinKitchenTile(),
        gap(height: 140),
        EmptyStateWidget(
          context,
          imagePath: AppAssets.noKitchenFound,
          title: 'No Kitchen found',
        ),
      ],
    ),
  );
}
