import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_recipe_is_under_progress_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/kitchen_home_view.dart';
import 'package:foodkitchen/features/home/presentation/widgets/floating_button.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/invite_member_page.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserCubit userCubit;
  late final HomeBloc homeBloc;

  bool isGeneratedRecipes = false;

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    homeBloc = context.read<HomeBloc>();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final kitchenId = userCubit.state.activeKitchenId;
    if (kitchenId.isNotEmpty) {
      homeBloc
        ..add(GetAllWeeklyPlansEventForHome())
        ..add(GetPantriesItemsEventForHome(kitchenId: kitchenId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final hasKitchen = userState.activeKitchenId.isNotEmpty;

          return SingleChildScrollView(
            child: MultiBlocListener(
              key: UniqueKey(),
              listeners: [
                BlocListener<HomeBloc, HomeState>(
                  listenWhen: (previous, current) =>
                      previous.successMessage != current.successMessage ||
                      previous.errorMessage != current.errorMessage,
                  listener: (_, state) {
                    if (state.successMessage != null) {
                      AppToast.show(state.successMessage!, ToastType.success);
                    } else if (state.errorMessage != null) {
                      AppToast.show(state.errorMessage!, ToastType.error);
                    }
                  },
                ),
              ],
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (_, state) {
                  if (!hasKitchen) return const NoKitchenView();

                  if (state.isLoading) {
                    return Padding(
                      padding: gapOnly(
                        top: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (userState.mealTypeEntity.isNotEmpty)
                        RecipeInProgressNotification(
                          padding: gapOnly(
                            left: 20,
                            right: 20,
                            bottom: 0,
                            top: 14,
                          ),
                          mealTypeEntity: userState.mealTypeEntity[0],
                        ),
                      KitchenHomeView(
                        state: state,
                        isGeneratedRecipes: isGeneratedRecipes,
                        onGeneratePressed: () =>
                            setState(() => isGeneratedRecipes = true),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: const FloatingButton(),
    );
  }
}
