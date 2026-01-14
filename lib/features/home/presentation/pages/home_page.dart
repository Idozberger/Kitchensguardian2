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
  }

  void _handleToastMessage(HomeState state) {
    final successMsg = state.successMessage;
    final errorMsg = state.errorMessage;

    if (successMsg != null) {
      AppToast.show(successMsg, ToastType.success);
    } else if (errorMsg != null) {
      AppToast.show(errorMsg, ToastType.error);
    }
  }

  void _handleGeneratePressed() {
    final state = _homeBloc.state;

    if (state.groceryList.isNotEmpty) {
      context.push(Routes.smartCart);
      return;
    }

    _homeBloc.add(GenerateGroceryList());
    setState(() => _generatedRecipes = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: BlocListener<HomeBloc, HomeState>(
        listenWhen: (prev, curr) =>
            prev.successMessage != curr.successMessage ||
            prev.errorMessage != curr.errorMessage,
        listener: (_, state) => _handleToastMessage(state),
        child: BlocBuilder<UserCubit, UserState>(
          builder: (_, userState) {
            final hasKitchen = userState.activeKitchenId.isNotEmpty;

            return BlocBuilder<HomeBloc, HomeState>(
              builder: (_, homeState) {
                return _buildBody(
                  userState: userState,
                  homeState: homeState,
                  hasKitchen: hasKitchen,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody({
    required UserState userState,
    required HomeState homeState,
    required bool hasKitchen,
  }) {
    if (!hasKitchen) {
      return const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: NoKitchenView(),
      );
    }

    if (homeState.isLoading) {
      return _buildLoadingView();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildContent(userState: userState, homeState: homeState),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Lottie.asset(AppAssets.loader),
      ),
    );
  }

  Widget _buildContent({
    required UserState userState,
    required HomeState homeState,
  }) {
    final hasStorageAreas = userState.userStorageAreas.isNotEmpty;
    final hasRecipeInProgress = userState.recipeEntity.isNotEmpty;

    return Column(
      children: [
        const LowStockAndExpiryBanner(),
        if (hasRecipeInProgress)
          RecipeInProgressNotification(
            padding: gapOnly(left: 20, right: 20, top: 14, bottom: 0),
            recipeEntity: userState.recipeEntity.first,
          ),
        RepaintBoundary(
          child: _buildAnimatedContent(
            userState: userState,
            homeState: homeState,
            hasStorageAreas: hasStorageAreas,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedContent({
    required UserState userState,
    required HomeState homeState,
    required bool hasStorageAreas,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: hasStorageAreas
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
    );
  }
}
