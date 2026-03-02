// ignore_for_file: use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/action_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/create_or_join_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/items_request_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/pantry_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/smart_cart.dart';
import 'package:foodkitchen/features/home/presentation/widgets/suggestion_recipes.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 0, top: 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            gap(height: 14),
            _buildScanReceiptButton(context),
            if (state.itemsRequest.isNotEmpty) ...[
              gap(height: 12),
              ItemRequestSection(state: state),
            ],
            gap(height: 12),
            PantrySection(state: state),

            gap(height: 12),
            _buildFindRecipesButton(context),
            gap(height: 12),
            _buildGrocerySection(state),
            gap(height: 12),
            _buildRecipeSuggestionsSection(state),
            gap(height: 12),
            _buildTonightRecipeSection(state),
            gap(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildScanReceiptButton(BuildContext context) {
    final state = context.watch<UserCubit>().state;
    final bool isMember = state.role == "member";

    return UpperTile(
      widget: SizedBox(
        height: h(40),
        child: ElevatedButton.icon(
          icon: SvgPicture.asset(AppAssets.scanSvg, color: Colors.black),
          onPressed: () {
            if (isMember) {
              AppToast.show(
                "Only the host or co-host can scan receipts.",
                ToastType.error,
                gravity: ToastGravity.TOP,
              );
              return;
            }

            scanDocument(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isMember
                ? Colors.grey.shade300
                : AppColors.primaryColor,
          ),
          label: Text(
            "Scan Receipt",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(12),
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void scanDocument(BuildContext context) async {
    final state = context.read<UserCubit>().state;

    if (state.role == "member") {
      AppToast.show(
        "Only host and co-host can scan or add items.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    final status = await Permission.camera.request();

    if (status.isGranted) {
      await DocumentScannerService().scanDocument(context);
    } else if (status.isDenied) {
      AppToast.show(
        "Camera permission is required to scan receipts.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context, isPermanent: true);
    }
  }

  void _showPermissionDialog(BuildContext context, {bool isPermanent = false}) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(isPermanent: isPermanent),
    );
  }

  Widget _buildFindRecipesButton(BuildContext context) {
    return ActionTile(
      title: "Find Recipes",
      buttonText: "Find Recipes",
      svgPath: AppAssets.findRecipesSvg,
      onTap: () => navigateToGenerateRecipes(),
    );
  }

  void navigateToGenerateRecipes() {
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
  }

  Widget _buildGrocerySection(HomeState state) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.dateBasedPlan != current.dateBasedPlan,
      listener: (context, state) {
        context.read<HomeBloc>().add(GenerateGroceryList());
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: state.showGroceryShimmer
            ? _buildGroceryShimmer()
            : state.groceryList.isEmpty
            ? const SizedBox.shrink()
            : SmartCartTile(
                infoText: state.groceryList.length > 3
                    ? "+${state.groceryList.length - 3} tap to see more"
                    : null,
                isGenerated: true,
                previewItems: state.groceryList
                    .take(3)
                    .map((item) => item.name)
                    .toList(),
                onGenerate: widget.onGeneratePressed,
              ),
      ),
    );
  }

  Widget _buildRecipeSuggestionsSection(HomeState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: state.loadingRecipeSuggestion
          ? _buildSuggestionShimmer()
          : state.suggestedRecipe.isNotEmpty
          ? const SuggestionRecipes()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTonightRecipeSection(HomeState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: state.loadingWeeklyPlans
          ? _buildTonightShimmer()
          : state.dateBasedPlan.isNotEmpty
          ? const TonightRecipeWidget()
          : const SizedBox.shrink(),
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
            borderRadius: BorderRadius.circular(h(12)),
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
                child: Container(
                  height: h(20),
                  width: w(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(24),
                  width: h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h(12)),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.maxFinite,
              height: h(260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(h(14)),
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
                child: Container(
                  height: h(20),
                  width: w(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(24),
                  width: h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h(12)),
          SizedBox(
            height: h(200),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(width: w(14)),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: w(260),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(14)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: h(12)),
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
                      borderRadius: BorderRadius.circular(w(4)),
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
  Widget build(BuildContext context) {
    return Padding(
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
}
