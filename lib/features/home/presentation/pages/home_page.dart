import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/kitchen_home_view.dart';
import 'package:foodkitchen/features/home/presentation/widgets/floating_button.dart';

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
    bool hasKitchen = userCubit.state.activeKitchenId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SingleChildScrollView(
        child: MultiBlocListener(
          key: UniqueKey(),
          listeners: [
            BlocListener<HomeBloc, HomeState>(
              listenWhen: (previousState, currentState) =>
                  previousState.successMessage != currentState.successMessage ||
                  previousState.errorMessage != currentState.errorMessage,
              listener: (_, state) {
                if (state.successMessage != null) {
                  AppToast.show(state.successMessage!, ToastType.success);
                  hasKitchen = userCubit.state.activeKitchenId.isNotEmpty;
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

              return KitchenHomeView(
                state: state,
                isGeneratedRecipes: isGeneratedRecipes,
                onGeneratePressed: () =>
                    setState(() => isGeneratedRecipes = true),
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: const FloatingButton(),
    );
  }
}
