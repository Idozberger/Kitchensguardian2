import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
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
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final HomeBloc _homeBloc;
  final GenerateRecipes _generateRecipes;
  final FavouriteRecipes _favouriteRecipes;
  final AddToFavouriteRecipe _addToFavouriteRecipe;
  final RemoveFromFavouriteRecipe _removeFromFavouriteRecipe;
  final AddToWeeklyPlan _addToWeeklyPlan;
  final GetAllWeeklyPlans _getAllWeeklyPlans;
  final DeletePlan _deletePlan;
  final DeleteMealTypeFromWeeklyPlan _deleteMealTypeFromWeeklyPlan;
  final MarkRecipeFinished _markRecipeFinished;

  PlannerBloc({
    required HomeBloc homeBloc,
    required GenerateRecipes generateRecipes,
    required FavouriteRecipes favouriteRecipes,
    required AddToFavouriteRecipe addToFavouriteRecipe,
    required RemoveFromFavouriteRecipe removeFromFavouriteRecipe,
    required AddToWeeklyPlan addToWeeklyPlan,
    required GetAllWeeklyPlans getAllWeeklyPlans,
    required DeletePlan deletePlan,
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
    final res = await _addToWeeklyPlan(
      AddToWeeklyPlanParams(event.mealTypeEntity),
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
  }
}
