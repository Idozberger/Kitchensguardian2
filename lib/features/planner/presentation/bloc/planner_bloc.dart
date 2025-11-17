import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/planner/data/models/merged_meal_plan_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_meal_type_from_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/favourite_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/generate_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_weekly_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/mark_recipe_finished.dart';
import 'package:foodkitchen/features/planner/domain/usecases/remove_from_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/request_missing_items.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final UserCubit _userCubit;
  // ignore: unused_field
  final HomeBloc _homeBloc;
  final GroceryBloc _groceryBloc;
  final GenerateRecipes _generateRecipes;
  final FavouriteRecipes _favouriteRecipes;
  final AddToFavouriteRecipe _addToFavouriteRecipe;
  final RemoveFromFavouriteRecipe _removeFromFavouriteRecipe;
  final AddToWeeklyPlan _addToWeeklyPlan;
  final GetAllWeeklyPlans _getAllWeeklyPlans;
  final DeletePlan _deletePlan;
  final DeleteMealTypeFromWeeklyPlan _deleteMealTypeFromWeeklyPlan;
  final MarkRecipeFinished _markRecipeFinished;
  final RequestMissingItems _requestMissingItems;

  PlannerBloc({
    required UserCubit userCubit,
    required HomeBloc homeBloc,
    required GenerateRecipes generateRecipes,
    required FavouriteRecipes favouriteRecipes,
    required AddToFavouriteRecipe addToFavouriteRecipe,
    required RemoveFromFavouriteRecipe removeFromFavouriteRecipe,
    required AddToWeeklyPlan addToWeeklyPlan,
    required GetAllWeeklyPlans getAllWeeklyPlans,
    required DeletePlan deletePlan,
    required RequestMissingItems requestMissingItems,
    required GroceryBloc groceryBloc,
    required DeleteMealTypeFromWeeklyPlan deleteMealTypeFromWeeklyPlan,
    required MarkRecipeFinished markRecipeFinished,
  }) : _generateRecipes = generateRecipes,
       _favouriteRecipes = favouriteRecipes,
       _addToFavouriteRecipe = addToFavouriteRecipe,
       _removeFromFavouriteRecipe = removeFromFavouriteRecipe,
       _addToWeeklyPlan = addToWeeklyPlan,
       _getAllWeeklyPlans = getAllWeeklyPlans,
       _deletePlan = deletePlan,
       _homeBloc = homeBloc,
       _deleteMealTypeFromWeeklyPlan = deleteMealTypeFromWeeklyPlan,
       _markRecipeFinished = markRecipeFinished,
       _userCubit = userCubit,
       _requestMissingItems = requestMissingItems,
       _groceryBloc = groceryBloc,

       super(PlannerState()) {
    on<GetFavouriteRecipesEvent>(_onGetFavouriteRecipes);
    on<GenerateRecipesEvent>(_onGenerateRecipes);
    on<AddToFavouriteRecipeEvent>(_onAddToFavouriteRecipe);
    on<RemoveFromFavouriteRecipeEvent>(_onRemoveFromFavouriteRecipe);
    on<ClearAiGeneratedRecipes>(_onClearAiGeneratedRecipes);
    on<AddToWeeklyPlanEvent>(_onAddToWeeklyPlan);
    on<GetAllWeeklyPlansEvent>(_onGetAllWeeklyPlans);
    on<DeletePlanEvent>(_onDeletePlan);
    on<GetDateBasedPlans>(_onGetDateBasedPlans);
    on<DeleteMealTypeFromWeeklyPlanEvent>(_onDeleteMealTypeFromWeeklyPlan);
    on<MarkRecipeFinishedEvent>(_onMarkRecipeFinished);
    on<UpdateStartRecipeEvent>(_onUpdateStartRecipe);
    on<ResetPlannerStateEvent>(_onResetPlanner);
    on<AddMealPlanEvent>(_onAddMealPlan);
    on<RequestMissingItemsEvent>(_onRequestMissingItems);
    on<ResetMealPlanState>(_onResetMealPlanState);
    on<DeleteMealPlanEvent>(_onDeleteMealPlan);
    on<UpdateTypeSelectedAndDateEvent>(_onUpdateMealTypeSelectedAndDate);
  }

  Future<void> _onUpdateMealTypeSelectedAndDate(
    UpdateTypeSelectedAndDateEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(
      state.copyWith(
        mealTypeSelectedIndex: event.index,
        selectedDate: event.date,
      ),
    );
  }

  Future<void> _onGetFavouriteRecipes(
    GetFavouriteRecipesEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _favouriteRecipes(NoParams());

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (favouriteRecipes) {
        emit(
          state.copyWith(favouriteRecipes: favouriteRecipes, isLoading: false),
        );
      },
    );
  }

  Future<void> _onGenerateRecipes(
    GenerateRecipesEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _generateRecipes(
      GenerateRecipesParams(
        instructions: event.instructions,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (recipes) {
        emit(state.copyWith(recipes: recipes, isLoading: false));
      },
    );
  }

  Future<void> _onAddToFavouriteRecipe(
    AddToFavouriteRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _addToFavouriteRecipe(
      AddToFavouriteRecipeParams(recipeId: event.recipeId),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (recipes) {
        add(GetFavouriteRecipesEvent());
      },
    );
  }

  Future<void> _onRemoveFromFavouriteRecipe(
    RemoveFromFavouriteRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _removeFromFavouriteRecipe(
      RemoveFromFavouriteRecipeParams(recipeId: event.recipeId),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (recipes) {
        add(GetFavouriteRecipesEvent());
      },
    );
  }

  Future<void> _onClearAiGeneratedRecipes(
    ClearAiGeneratedRecipes event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(recipes: []));
  }

  Future<void> _onAddToWeeklyPlan(
    AddToWeeklyPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(addingToWeeklyPlan: true));
    var plan = event.mealTypeEntity as MealTypeModel;
    final res = await _addToWeeklyPlan(
      AddToWeeklyPlanParams(plan.copyWith(thumbnail: null)),
    );

    res.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            addingToWeeklyPlan: false,
          ),
        );
      },
      (successMessage) async {
        if (successMessage.toLowerCase().contains("already")) {
          AppToast.show(successMessage, ToastType.error);
        } else {
          AppToast.show(successMessage, ToastType.success);
        }
        emit(state.copyWith(successMessage: successMessage));
        add(GetAllWeeklyPlansEvent());
        final startDate = await getStartDate();
        add(GetDateBasedPlans(startDate ?? formatDate(DateTime.now())));
      },
    );
  }

  Future<String?> getStartDate() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("start-date");
  }

  Future<void> _onGetAllWeeklyPlans(
    GetAllWeeklyPlansEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _getAllWeeklyPlans(NoParams());

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (getAllWeeklyPlans) async {
        List<MergedMealPlanEntity> mergedMealPlanEntities =
            mergeMealPlansByDate(getAllWeeklyPlans);

        emit(
          state.copyWith(
            getAllWeeklyPlans: mergedMealPlanEntities,
            isLoading: false,
          ),
        );
      },
    );
  }

  List<MergedMealPlanEntity> mergeMealPlansByDate(List<MealTypeEntity> meals) {
    final List<MergedMealPlanEntity> grouped = [];

    for (var i = 0; i < meals.length; i++) {
      final currentMeal = meals[i];
      final existingIndex = grouped.indexWhere(
        (element) => element.date == currentMeal.formatedDateString,
      );

      if (existingIndex != -1) {
        MergedMealPlanModel existing = MergedMealPlanModel.fromEntity(
          grouped[existingIndex],
        );

        grouped[existingIndex] = existing.copyWith(
          breakfast: currentMeal.mealType.toLowerCase() == "breakfast"
              ? currentMeal
              : existing.breakfast,
          lunch: currentMeal.mealType.toLowerCase() == "lunch"
              ? currentMeal
              : existing.lunch,
          dinner: currentMeal.mealType.toLowerCase() == "dinner"
              ? currentMeal
              : existing.dinner,
        );
      } else {
        grouped.add(
          MergedMealPlanEntity(
            date: currentMeal.formatedDateString,
            breakfast: currentMeal.mealType.toLowerCase() == "breakfast"
                ? currentMeal
                : null,
            lunch: currentMeal.mealType.toLowerCase() == "lunch"
                ? currentMeal
                : null,
            dinner: currentMeal.mealType.toLowerCase() == "dinner"
                ? currentMeal
                : null,
          ),
        );
      }
    }

    return grouped;
  }

  Future<void> _onDeletePlan(
    DeletePlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _deletePlan(DeletePlanParams(event.dateString));

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (successMessage) async {
        add(GetAllWeeklyPlansEvent());
        await Future.delayed(Duration(milliseconds: 300));
        add(GetDateBasedPlans(event.dateString));
        AppToast.show(successMessage, ToastType.success);
      },
    );
  }

  Future<void> _onAddMealPlan(
    AddMealPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    log(event.mealPlan.mealType);
    if (state.mealPlans.isNotEmpty) {
      var plans = MergedMealPlanModel.fromEntity(state.mealPlans[0]);

      switch (event.mealPlan.mealType.toLowerCase()) {
        case "breakfast":
          plans = plans.copyWith(
            breakfast: event.mealPlan,
            lunch: plans.lunch,
            dinner: plans.dinner,
            date: plans.date,
          );
          break;
        case "lunch":
          plans = plans.copyWith(
            lunch: event.mealPlan,
            breakfast: plans.breakfast,
            dinner: plans.dinner,
            date: plans.date,
          );
          break;
        case "dinner":
          plans = plans.copyWith(
            dinner: event.mealPlan,
            breakfast: plans.breakfast,
            lunch: plans.lunch,
            date: plans.date,
          );
          break;
        default:
      }
      emit(state.copyWith(mealPlans: [plans], isLoading: false));
    } else {
      var plans = MergedMealPlanModel.fromEntity(
        MergedMealPlanEntity(date: event.date),
      );

      // Update plan according to meal type
      switch (event.mealPlan.mealType.toLowerCase()) {
        case "breakfast":
          plans = plans.copyWith(
            breakfast: event.mealPlan,
            lunch: null,
            dinner: null,
          );
          break;

        case "lunch":
          plans = plans.copyWith(
            breakfast: null,
            lunch: event.mealPlan,
            dinner: null,
          );
          break;

        case "dinner":
          plans = plans.copyWith(
            breakfast: null,
            lunch: null,
            dinner: event.mealPlan,
          );
          break;

        default:
          log('Unknown meal type received: ${event.mealPlan.mealType}');
      }

      log('   - Breakfast: ${plans.breakfast != null}');
      log('   - Lunch: ${plans.lunch != null}');
      log('   - Dinner: ${plans.dinner != null}');
      log('   - Plan details: $plans');

      emit(state.copyWith(mealPlans: [plans], isLoading: false));
    }
  }

  Future<void> _onResetMealPlanState(
    ResetMealPlanState event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(mealPlans: []));
  }

  Future<void> _onDeleteMealPlan(
    DeleteMealPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (state.mealPlans.isNotEmpty) {
      var plans = MergedMealPlanModel.fromEntity(state.mealPlans[0]);

      switch (event.mealType.toLowerCase()) {
        case "breakfast":
          plans = plans.copyWith(
            lunch: plans.lunch,
            breakfast: null,
            dinner: plans.dinner,
            date: plans.date,
          );
          break;
        case "lunch":
          plans = plans.copyWith(
            lunch: null,
            breakfast: plans.breakfast,
            dinner: plans.dinner,
            date: plans.date,
          );
          break;
        case "dinner":
          plans = plans.copyWith(
            lunch: plans.lunch,
            breakfast: plans.breakfast,
            dinner: null,
            date: plans.date,
          );
          break;
        default:
      }
      emit(state.copyWith(mealPlans: [plans], isLoading: false));
    }
  }

  Future<void> _onGetDateBasedPlans(
    GetDateBasedPlans event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final allPlans = state.getAllWeeklyPlans;
    List dateBasedPlan = allPlans
        .where((plan) => plan.date == event.dateString)
        .toList();
    emit(
      state.copyWith(
        dateBasedPlan: dateBasedPlan.isNotEmpty ? [dateBasedPlan[0]] : [],
        isLoading: false,
        addingToWeeklyPlan: false,
      ),
    );
  }

  Future<void> _onDeleteMealTypeFromWeeklyPlan(
    DeleteMealTypeFromWeeklyPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _deleteMealTypeFromWeeklyPlan(
      DeleteMealTypeFromWeeklyPlanParams(
        selectedDate: event.selectedDate,
        mealType: event.mealType,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (getAllWeeklyPlans) async {
        List<MergedMealPlanEntity> mergedMealPlanEntities =
            mergeMealPlansByDate(getAllWeeklyPlans);
        add(GetDateBasedPlans(event.selectedDate));
        emit(
          state.copyWith(
            getAllWeeklyPlans: mergedMealPlanEntities,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onMarkRecipeFinished(
    MarkRecipeFinishedEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isFinishingRecipe: true));
    final res = await _markRecipeFinished(
      MarkRecipeFinishedParams(
        kitchenId: event.kitchenId,
        recipeId: event.recipeId,
      ),
    );

    res.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            isFinishingRecipe: false,
            startRecipe: false,
          ),
        );
      },
      (successMessage) async {
        emit(state.copyWith(isFinishingRecipe: false, startRecipe: false));
        AppToast.show(
          successMessage,
          ToastType.success,
          timeInSecForIosWeb: 4,
          gravity: ToastGravity.TOP,
        );
      },
    );
  }

  Future<void> _onUpdateStartRecipe(
    UpdateStartRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(startRecipe: event.startRecipe));
    if (event.startRecipe) {
      emit(
        state.copyWith(
          startedRecipe: event.mealTypeEntity,
          doneSteps: event.doneSteps,
        ),
      );
      _userCubit.updateMealTypeEntity(event.mealTypeEntity, event.doneSteps);
    } else {
      emit(state.copyWith(startedRecipe: [], doneSteps: []));
      _userCubit.updateMealTypeEntity([], []);
    }
  }

  Future<void> _onResetPlanner(
    ResetPlannerStateEvent event,
    Emitter<PlannerState> emit,
  ) async {}

  Future<void> _onRequestMissingItems(
    RequestMissingItemsEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _requestMissingItems(
      RequestMissingItemsParams(pantry: event.pantry),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (message) {
        emit(state.copyWith(successMessage: message, isLoading: false));
        _groceryBloc.add(
          RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
        );
      },
    );
  }
}
