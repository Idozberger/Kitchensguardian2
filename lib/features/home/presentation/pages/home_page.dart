import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_recipe_is_under_progress_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/kitchen_home_view.dart';
import 'package:foodkitchen/features/home/presentation/widgets/Low_stock_and_expiry_banner.dart';
import 'package:foodkitchen/features/home/presentation/widgets/storage_area_section.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserCubit _userCubit;
  late final HomeBloc _homeBloc;

  bool _generatedRecipes = false;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _homeBloc = context.read<HomeBloc>();

    _loadData();
  }

  void _loadData() async {
    final kitchenId = _userCubit.state.activeKitchenId;
    if (kitchenId.isEmpty) return;

    _homeBloc
      ..add(GetAllWeeklyPlansEventForHome())
      ..add(GetUserStorageAreaEvent(kitchenId))
      ..add(GetRecipeSuggestionEvent(kitchenId))
      ..add(GetPantriesItemsEventForHome(kitchenId: kitchenId))
      ..add(GenerateGroceryList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (_, userState) {
          final hasKitchen = userState.activeKitchenId.isNotEmpty;

          return BlocBuilder<HomeBloc, HomeState>(
            builder: (_, state) {
              return SingleChildScrollView(
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<HomeBloc, HomeState>(
                      listenWhen: (prev, curr) =>
                          prev.successMessage != curr.successMessage ||
                          prev.errorMessage != curr.errorMessage,
                      listener: (_, state) {
                        final msg = state.successMessage ?? state.errorMessage;
                        final type = state.successMessage != null
                            ? ToastType.success
                            : ToastType.error;

                        if (msg != null) AppToast.show(msg, type);
                      },
                    ),
                  ],
                  child: _buildContent(
                    userState: userState,
                    homeState: state,
                    hasKitchen: hasKitchen,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required UserState userState,
    required HomeState homeState,
    required bool hasKitchen,
  }) {
    debugPrint("${userState.userStorageAreas}");
    if (!hasKitchen) return const NoKitchenView();

    if (homeState.isLoading) {
      return Center(
        child: Padding(
          padding: gapOnly(top: MediaQuery.of(context).size.height * 0.14),
          child: Lottie.asset(AppAssets.loader),
        ),
      );
    }

    return Column(
      children: [
        LowStockAndExpiryBanner(),
        if (userState.recipeEntity.isNotEmpty)
          RecipeInProgressNotification(
            padding: gapOnly(left: 20, right: 20, top: 14, bottom: 0),
            recipeEntity: userState.recipeEntity.first,
          ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: userState.userStorageAreas.isNotEmpty
              ? KitchenHomeView(
                  key: ValueKey(
                    "kitchen_view_${userState.userStorageAreas.length}",
                  ),
                  state: homeState,
                  isGeneratedRecipes: _generatedRecipes,
                  onGeneratePressed: _handleGeneratePressed,
                )
              : StorageAreasSection(
                  key: ValueKey(
                    "storage_view_${userState.userStorageAreas.length}",
                  ),
                  state: userState,
                ),
        ),
      ],
    );
  }

  void _handleGeneratePressed() {
    final state = _homeBloc.state;

    if (_generatedRecipes && state.groceryList.isNotEmpty) {
      context.push(Routes.smartCart);
    }

    _homeBloc.add(GenerateGroceryList());
    setState(() => _generatedRecipes = true);
  }
}
