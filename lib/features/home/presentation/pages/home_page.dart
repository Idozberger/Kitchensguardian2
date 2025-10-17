import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/join_kitchen.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserCubit userCubit;
  late final HomeBloc homeBloc;

  bool isGeneratedRecipes = false;

  final List<String> ingredients = [
    "Tomatoes",
    "Olive Oil",
    "Garlic",
    "Onions",
    "Cheese",
  ];

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    homeBloc = context.read<HomeBloc>();
    _getUserPantriesAndWeeklyPlans();
  }

  void _getUserPantriesAndWeeklyPlans() {
    final kitchenId = userCubit.state.activeKitchenId;
    if (kitchenId.isNotEmpty) {
      homeBloc.add(GetAllWeeklyPlansEventForHome());
      homeBloc.add(GetPantriesItemsEventForHome(kitchenId: kitchenId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasKitchen = userCubit.state.activeKitchenId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (_, state) {
          if (state.successMessage != null) {
            AppToast.show(state.successMessage!, ToastType.success);
          }
          if (state.errorMessage != null) {
            AppToast.show(state.errorMessage!, ToastType.error);
          }
        },
        builder: (_, state) => Padding(
          padding: gapOnly(left: 20, right: 20, bottom: 20, top: 10),
          child: ListView(
            children: [
              if (hasKitchen) ...[
                // ActionTile(
                //   title: "Scan to log in your food!",
                //   buttonText: "Scan",
                //   svgPath: AppAssets.scanSvg,
                //   onTap: () => context.push(Routes.scanMeal),
                // ),
                gap(height: 15),
                state.isLoading
                    ? UpperTile(
                        widget: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : PantrySection(state: state),
                gap(height: 15),
                ActionTile(
                  title: "Find Recipes",
                  buttonText: "Find Recipes",
                  svgPath: AppAssets.findRecipesSvg,
                  onTap: () {
                    final date = DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.now());
                    context.pushNamed(
                      Routes.generateRecipes,
                      extra: {
                        "selected_date": date,
                        "selected_meal_type": "Breakfast",
                        "is_plan": false,
                      },
                    );
                  },
                ),
                gap(height: 15),
                SmartCartTile(
                  isGenerated: isGeneratedRecipes,
                  ingredients: ingredients,
                  onGenerate: () => setState(() => isGeneratedRecipes = true),
                ),
                gap(height: 15),
                if (state.dateBasedPlan.isNotEmpty) TonightRecipeWidget(),
              ] else ...[
                CreateOrJoinKitchenTile(),
                gap(height: 140),
                EmptyStateWidget(
                  context,
                  imagePath: AppAssets.noKitchenFound,
                  title: 'No Kitchen found',
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        shape: CircleBorder(),
        onPressed: () {
          context.push(Routes.scanMeal);
        },
        child: SvgPicture.asset(AppAssets.scanSvg, color: Colors.black),
      ),
    );
  }
}

class CreateOrJoinKitchenTile extends StatelessWidget {
  const CreateOrJoinKitchenTile({super.key});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have to:",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 15),
          Row(
            children: [
              Expanded(
                child: GenericButtonWidget(
                  isOutlined: true,
                  text: "Create",
                  onPressed: () => showCreateKitchenDialog(context),
                ),
              ),
              gap(width: 10),
              Expanded(
                child: GenericButtonWidget(
                  text: "Join",
                  onPressed: () => showJoinKitchenDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PantrySection extends StatelessWidget {
  final HomeState state;

  const PantrySection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasItems = state.pantryItems.isNotEmpty;

    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          gap(height: 15),
          _actionButtons(context, hasItems),
          gap(height: 15),
          if (hasItems) _pantryList(context) else _noItemsText(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Pantry", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(AppAssets.pantrySvg),
    ],
  );

  Widget _actionButtons(BuildContext context, bool hasItems) => Row(
    children: [
      if (!hasItems)
        Expanded(
          child: SizedBox(
            height: h(40),
            child: OutlinedButton.icon(
              onPressed: () => context.push(Routes.scanMeal),
              icon: SvgPicture.asset(AppAssets.scanSvg),
              label: Text(
                "Scan",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      if (!hasItems) gap(width: 10),
      Expanded(
        child: SizedBox(
          height: h(40),
          child: ElevatedButton.icon(
            onPressed: () => context.push(Routes.addItem),
            icon: SvgPicture.asset(AppAssets.addSvg),
            label: Text(
              "Add Item",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _pantryList(BuildContext context) => Column(
    children: [
      ListView.separated(
        shrinkWrap: true,
        itemCount: state.pantryItems.length.clamp(0, 3),
        separatorBuilder: (_, __) => const Divider(color: Color(0xffF4F4F4)),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final pantry = state.pantryItems[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListItemWidget(
                  text: pantry.name,
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(
                        fontSize: t(12),
                        color: const Color(0xff787878),
                      ),
                  crossAlignment: CrossAxisAlignment.center,
                ),
              ),
              Text(
                pantry.quantity.toString(),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: const Color(0xff787878),
                ),
              ),
            ],
          );
        },
      ),
      gap(height: 15),
      Center(
        child: SizedBox(
          height: h(40),
          width: w(170),
          child: OutlinedButton.icon(
            onPressed: () => context.push(Routes.myPantry),
            icon: SvgPicture.asset(
              AppAssets.eyeSvg,
              color: AppColors.primaryColor,
              width: w(10),
              height: h(10),
            ),
            label: Text(
              "Tap to see more",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _noItemsText(BuildContext context) => Text(
    "No items available in Pantry",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}

class ActionTile extends StatelessWidget {
  final String title;
  final String buttonText;
  final String svgPath;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.buttonText,
    required this.svgPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 15),
          SizedBox(
            height: h(40),
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: SvgPicture.asset(svgPath, color: Colors.black),
              label: Text(
                buttonText,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmartCartTile extends StatelessWidget {
  final bool isGenerated;
  final List<String> ingredients;
  final VoidCallback onGenerate;

  const SmartCartTile({
    super.key,
    required this.isGenerated,
    required this.ingredients,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          gap(height: 15),
          isGenerated ? _preview(context) : _noItems(context),
          gap(height: 15),
          GenericButtonWidget(
            text: "Generate Grocery List",
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Smart Cart", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(AppAssets.pantrySvg),
    ],
  );

  Widget _preview(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Preview items:",
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: t(12),
          color: const Color(0xff787878),
        ),
      ),
      gap(height: 15),
      Wrap(
        spacing: w(4),
        runSpacing: w(8),
        children: [
          ...ingredients
              .take(3)
              .map(
                (e) =>
                    RoundedTextContainer(text: e, fontWeight: FontWeight.w500),
              ),
          if (ingredients.length > 3)
            RoundedTextContainer(text: "+${ingredients.length - 3} more"),
        ],
      ),
    ],
  );

  Widget _noItems(BuildContext context) => Text(
    "No items available in Pantry",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}
