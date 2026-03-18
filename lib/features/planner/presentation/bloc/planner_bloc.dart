// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/planner/data/models/merged_meal_plan_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/check_missing_ingredients.dart';
import 'package:foodkitchen/features/planner/domain/usecases/create_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_meal_type_from_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan_remote_db.dart';
import 'package:foodkitchen/features/planner/domain/usecases/favourite_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/generate_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_weekly_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_meal_by_date.dart';
import 'package:foodkitchen/features/planner/domain/usecases/mark_recipe_finished.dart';
import 'package:foodkitchen/features/planner/domain/usecases/remove_from_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/request_missing_items.dart';
import 'package:foodkitchen/features/planner/domain/usecases/set_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/update_meal_plan.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_date_formatter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final UserCubit _userCubit;
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
  final CreatePlan _createPlan;
  final DeletePlanRemoteDb _deletePlanRemoteDb;
  final UpdateMealPlan _updateMealPlan;
  final GetMealByDate _getMealByDate;
  final GetAllPlans _getAllPlans;
  final GetDateRange _getDateRange;
  final SetDateRange _setDateRange;
  final CheckMissingIngredients _checkMissingIngredients;

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
    required CreatePlan createPlan,
    required DeletePlanRemoteDb deletePlanRemoteDb,
    required UpdateMealPlan updateMealPlan,
    required GetMealByDate getMealByDate,
    required GetAllPlans getAllPlans,
    required GetDateRange getDateRange,
    required SetDateRange setDateRange,
    required CheckMissingIngredients checkMissingIngredients,
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
       _createPlan = createPlan,
       _deletePlanRemoteDb = deletePlanRemoteDb,
       _updateMealPlan = updateMealPlan,
       _getMealByDate = getMealByDate,
       _getAllPlans = getAllPlans,
       _getDateRange = getDateRange,
       _setDateRange = setDateRange,
       _checkMissingIngredients = checkMissingIngredients,

       super(PlannerState()) {
    on<GetFavouriteRecipesEvent>(_onGetFavouriteRecipes);
    on<GenerateRecipesEvent>(_onGenerateRecipes);
    on<AddToFavouriteRecipeEvent>(_onAddToFavouriteRecipe);
    on<RemoveFromFavouriteRecipeEvent>(_onRemoveFromFavouriteRecipe);
    on<ClearAiGeneratedRecipes>(_onClearAiGeneratedRecipes);
    on<AddToWeeklyPlanEvent>(_onAddToWeeklyPlan);
    on<GetAllWeeklyPlansEvent>(_onGetAllMealPlans);
    on<DeletePlanEvent>(_onDeletePlan);
    on<GetDateBasedPlans>(_onGetDateBasedPlans);
    on<DeleteMealTypeFromWeeklyPlanEvent>(_onDeleteMealTypeFromWeeklyPlan);
    on<MarkRecipeFinishedEvent>(_onMarkRecipeFinished);
    on<UpdateStartRecipeEvent>(_onUpdateStartRecipe);
    on<CancelInProgressRecipeEvent>(_onCancelInProgressRecipe);
    on<ResetPlannerStateEvent>(_onResetPlanner);
    on<AddMealPlanEvent>(_onAddMealPlan);
    on<RequestMissingItemsEvent>(_onRequestMissingItems);
    on<RemoveMissingIngredientEvent>(_onRemoveMissingIngredient);
    on<ResetMealPlanState>(_onResetMealPlanState);
    on<DeleteMealPlanEvent>(_onDeleteMealPlan);
    on<UpdateTypeSelectedAndDateEvent>(_onUpdateMealTypeSelectedAndDate);
    on<CreatePlanEvent>(_onCreatePlan);
    on<DeletePlanFromRemoteDbEvent>(_onDeletePlanFromRemoteDb);
    on<UpdateMealPlanEvent>(_onUpdateMealPlan);
    on<GetMealByDateEvent>(_onGetMealByDate);
    on<EditMealEvent>(_onEditMeal);
    on<GetDateRangeEvent>(_onGetDateRangeEvent);
    on<SetDateRangeEvent>(_onSetDateRange);
    on<UpdateRecipeFinishedState>(_onUpdateRecipeFinishedState);
    on<RequestStartRecipeEvent>(_onRequestStartRecipe);
    on<RemoveMissingIngredientFromPlanEvent>(
      _onRemoveMissingIngredientFromPlanEvent,
    );
    on<CheckMissingIngredientsEvent>(_onCheckMissingIngredientsEvent);
  }
  Future<void> _onCheckMissingIngredientsEvent(
    CheckMissingIngredientsEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(
      state.copyWith(
        isCheckingMissingIngredients: true,
        hasMissingIngredients: false,
      ),
    );
    final res = await _checkMissingIngredients(
      CheckMissingIngredientsParams(
        kitchenId: event.kitchenId,
        recipeId: event.recipeId,
      ),
    );

    res.fold(
      (failure) {
        log("hasMissingIngredients: Error ${failure.message}");
        emit(
          state.copyWith(
            isCheckingMissingIngredients: false,
            hasMissingIngredients: false,
          ),
        );
      },
      (hasMissingIngredients) {
        log("hasMissingIngredients: $hasMissingIngredients");
        emit(
          state.copyWith(
            isCheckingMissingIngredients: false,
            hasMissingIngredients: hasMissingIngredients,
          ),
        );
      },
    );
  }

  Future<void> _onSetDateRange(
    SetDateRangeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (_userCubit.state.activeKitchenId.isEmpty) return;
    final res = await _setDateRange(
      SetDateRangeParams(
        kitchenId: _userCubit.state.activeKitchenId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (dateRange) {
        log(
          "Date Ranges: ${dateRange.startDate} -- End Date ${dateRange.endDate}",
        );
        emit(
          state.copyWith(
            endDate: dateRange.endDate,
            startDate: dateRange.startDate,
          ),
        );
      },
    );
    emit(state.copyWith(isLoading: true));
  }

  Future<void> _onGetDateRangeEvent(
    GetDateRangeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (event.kitchenId.isEmpty) return;
    emit(state.copyWith(isLoading: true));

    final res = await _getDateRange(GetDateRangeParams(event.kitchenId));

    await res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (dateRange) async {
        if (dateRange.endDate.isNotEmpty) {
          final existingEndDate = formatStringDateToMeetBackendDate(
            dateRange.endDate,
          );
          final todayOnly = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );

          if (existingEndDate.isBefore(todayOnly)) {
            updateStartEndDate();
            add(GetDateRangeEvent(kitchenId: _userCubit.state.activeKitchenId));
          }
        }
        emit(
          state.copyWith(
            endDate: dateRange.endDate,
            startDate: dateRange.startDate,
            isLoading: false,
          ),
        );
      },
    );
  }

  void updateStartEndDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isSubscribed = prefs.getBool("is_subscribled") ?? false;
    final today = DateTime.now();
    final nextDays = List.generate(
      isSubscribed ? 7 : 7,
      (i) => today.add(Duration(days: i)),
    );

    final formattedStartDate = formatDateToMeetBackendDate(nextDays.first);
    final formattedEndDate = formatDateToMeetBackendDate(nextDays.last);
    log(
      "formattedStartDate $formattedEndDate || formattedEndDate $formattedEndDate",
    );

    add(
      SetDateRangeEvent(
        kitchenId: _userCubit.state.activeKitchenId,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      ),
    );
  }

  Future<void> _onEditMeal(
    EditMealEvent event,
    Emitter<PlannerState> emit,
  ) async {
    state.copyWith(editMealsPlans: [event.mergedPlans]);
  }

  Future<void> _onGetAllMealPlans(
    GetAllWeeklyPlansEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (event.kitchenId.isEmpty) return;

    emit(state.copyWith(loadingPlans: true));

    final res = await _getAllPlans(
      GetAllPlansParams(kitchenId: event.kitchenId),
    );

    await res.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.message, loadingPlans: false),
        );
      },
      (getAllWeeklyPlans) async {
        List<MergedRecipePlanEntity> mergedMealPlanEntities =
            mergeMealPlansByDate(getAllWeeklyPlans);

        emit(
          state.copyWith(
            getAllWeeklyPlans: mergedMealPlanEntities,
            loadingPlans: false,
          ),
        );

        if (getAllWeeklyPlans.isNotEmpty) {
          await NotificationService()
              .scheduleMealPlanReminders(mergedMealPlanEntities, {
                "kitchenId": event.kitchenId,
                "invitationCode": _userCubit.state.invitationCode,
                "kitchenName": _userCubit.state.kitchenName,
                "role": _userCubit.state.role,
              });
        }
        log(
          "plan: ${state.startDate} || ${PlannerDateFormatter.toBackendFormat(DateTime.now())}",
        );
        add(
          GetDateBasedPlans(
            state.startDate ??
                PlannerDateFormatter.toBackendFormat(DateTime.now()),
          ),
        );
      },
    );
  }

  Future<void> _onGetMealByDate(
    GetMealByDateEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _getMealByDate(
      GetMealByDateParams(date: event.date, kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (successMessage) {
        emit(state.copyWith(successMessage: successMessage, isLoading: false));
      },
    );
  }

  Future<void> _onUpdateMealPlan(
    UpdateMealPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _updateMealPlan(
      UpdateMealPlanParams(
        mealPlanId: event.mealPlanId,
        mealType: event.mealType,
        notes: event.notes,
        recipeId: event.recipeId,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (successMessage) {
        emit(state.copyWith(successMessage: successMessage, isLoading: false));
      },
    );
  }

  Future<void> _onDeletePlanFromRemoteDb(
    DeletePlanFromRemoteDbEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, loadingPlans: true));

    final res = await _deletePlanRemoteDb(
      DeletePlanRemoteDbParams(
        mealPlanId: event.mealPlanId,
        kitchenId: event.kitchenId ?? "",
        date: event.date ?? "",
      ),
    );

    await res.fold(
      (failure) async {
        Future.microtask(() {
          add(
            GetAllWeeklyPlansEvent(
              _userCubit.state.activeKitchenId,
              event.date,
            ),
          );
        });

        emit(
          state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            loadingPlans: false,
          ),
        );
      },
      (successMessage) async {
        await Future.delayed(Duration(seconds: 4));
        Future.microtask(() {
          add(
            GetAllWeeklyPlansEvent(
              _userCubit.state.activeKitchenId,
              event.date,
            ),
          );
        });
        _homeBloc.add(GetAllWeeklyPlansEventForHome());
        emit(
          state.copyWith(
            successMessage: successMessage,
            isLoading: false,
            loadingPlans: false,
          ),
        );
      },
    );
  }

  Future<void> _onCreatePlan(
    CreatePlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _createPlan(CreatePlanParams(event.mealPlans));

    await res.fold(
      (failure) async {
        await Future.delayed(Duration(seconds: 4));
        add(GetAllWeeklyPlansEvent(_userCubit.state.activeKitchenId, null));

        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (successMessage) async {
        if (state.startDate == null || state.startDate!.isEmpty) {
          updateStartEndDate();
        }

        await Future.delayed(Duration(seconds: 4));
        add(GetAllWeeklyPlansEvent(_userCubit.state.activeKitchenId, null));
        _homeBloc.add(GetAllWeeklyPlansEventForHome());

        emit(state.copyWith(successMessage: successMessage, isLoading: false));
      },
    );
  }

  Future<void> _onUpdateRecipeFinishedState(
    UpdateRecipeFinishedState event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isRecipeFinished: false));
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
    emit(state.copyWith(isFavLoading: true));
    final res = await _favouriteRecipes(FavouriteRecipeParams(event.kitchenId));

    res.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            isFavLoading: false,
          ),
        );
      },
      (favouriteRecipes) {
        emit(
          state.copyWith(
            favouriteRecipes: favouriteRecipes,
            isLoading: false,
            isFavLoading: false,
          ),
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
    emit(state.copyWith(isFavLoading: true));
    final res = await _addToFavouriteRecipe(
      AddToFavouriteRecipeParams(
        recipeId: event.recipeId,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.message, isFavLoading: false),
        );
      },
      (recipes) {
        add(GetFavouriteRecipesEvent(event.kitchenId));
      },
    );
  }

  Future<void> _onRemoveFromFavouriteRecipe(
    RemoveFromFavouriteRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(isFavLoading: true));
    final res = await _removeFromFavouriteRecipe(
      RemoveFromFavouriteRecipeParams(
        recipeId: event.recipeId,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) {
        emit(
          state.copyWith(errorMessage: failure.message, isFavLoading: false),
        );
      },
      (recipes) {
        add(GetFavouriteRecipesEvent(event.kitchenId));
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
    var plan = event.recipeEntity;
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
        add(GetAllWeeklyPlansEvent(_userCubit.state.activeKitchenId, null));
      },
    );
  }

  List<MergedRecipePlanEntity> mergeMealPlansByDate(List<RecipeEntity> meals) {
    for (var element in meals) {
      log("ERROR: ${element.title}");
    }
    List<MergedRecipePlanEntity> grouped = [];

    for (var i = 0; i < meals.length; i++) {
      final currentMeal = meals[i];

      final existingIndex = grouped.indexWhere((element) {
        log("EELELLE ${element.date} == ${currentMeal.date}");
        return element.date == currentMeal.date;
      });

      if (existingIndex != -1) {
        MergedMealPlanModel existing = MergedMealPlanModel.fromEntity(
          grouped[existingIndex],
        );

        grouped[existingIndex] = existing.copyWith(
          date: currentMeal.date,
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
        log(
          "No existing meal plan found for date: ${currentMeal.date}, adding new plan",
        );

        grouped.add(
          MergedRecipePlanEntity(
            date: currentMeal.date,
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

    log("Grouped meal plans: $grouped");

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
        add(GetAllWeeklyPlansEvent(_userCubit.state.activeKitchenId, null));
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
        MergedRecipePlanEntity(date: event.date),
      );

      switch (event.mealPlan.mealType.toLowerCase()) {
        case "breakfast":
          plans = plans.copyWith(
            date: event.date,
            breakfast: event.mealPlan,
            lunch: null,
            dinner: null,
          );
          break;

        case "lunch":
          plans = plans.copyWith(
            date: event.date,
            breakfast: null,
            lunch: event.mealPlan,
            dinner: null,
          );
          break;

        case "dinner":
          plans = plans.copyWith(
            date: event.date,
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
    log("datebase bloc: $allPlans");
    List<MergedRecipePlanEntity> dateBasedPlan = allPlans.where((plan) {
      final planDate = formatDateToMeetBackendDate(
        formatStringDateToMeetBackendDate(plan.date),
      );
      log("ppppp: $planDate==${event.dateString}");
      return planDate == event.dateString;
    }).toList();

    emit(
      state.copyWith(
        startDate: state.startDate,
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
        List<MergedRecipePlanEntity> mergedMealPlanEntities =
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
    emit(state.copyWith(isFinishingRecipe: true, isRecipeFinished: false));
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
            isRecipeFinished: false,
          ),
        );
      },
      (successMessage) async {
        emit(
          state.copyWith(
            isFinishingRecipe: false,
            startRecipe: false,
            isRecipeFinished: true,
          ),
        );
        emit(state.copyWith(isRecipeFinished: false));
        _homeBloc.add(GetPantriesItemsEventForHome(kitchenId: event.kitchenId));
        AppToast.show(
          successMessage,
          ToastType.success,
          timeInSecForIosWeb: 4,
          gravity: ToastGravity.TOP,
        );
      },
    );
  }

  Future<void> _onCancelInProgressRecipe(
    CancelInProgressRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final updatedRecipes = List<RecipeModel>.from(state.startedRecipe);
    final updatedDoneSteps = List<List<Map<String, dynamic>>>.from(
      state.doneSteps,
    );
    if (event.inProgressRecipeIndex >= 0 &&
        event.inProgressRecipeIndex < updatedRecipes.length) {
      updatedRecipes.removeAt(event.inProgressRecipeIndex);
      updatedDoneSteps.removeAt(event.inProgressRecipeIndex);
    }
    emit(
      state.copyWith(
        startedRecipe: updatedRecipes,
        doneSteps: updatedDoneSteps,
      ),
    );

    _userCubit.updateRecipeEntity(updatedRecipes);
  }

  Future<void> _onUpdateStartRecipe(
    UpdateStartRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(startRecipe: event.startRecipe));
    if (event.startRecipe) {
      emit(
        state.copyWith(
          startedRecipe: event.recipeEntity,
          doneSteps: [...state.doneSteps, event.doneSteps],
        ),
      );
      _userCubit.updateRecipeEntity(event.recipeEntity);
    } else {
      emit(state.copyWith(startedRecipe: [], doneSteps: []));
      _userCubit.updateRecipeEntity([]);
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
        if (event.isPlan) {
          AppToast.show(message, ToastType.success);

          emit(state.copyWith(isLoading: false));
        } else {
          emit(state.copyWith(successMessage: message, isLoading: false));
        }

        _groceryBloc.add(
          RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
        );
      },
    );
  }

  Future<void> _onRemoveMissingIngredient(
    RemoveMissingIngredientEvent event,
    Emitter<PlannerState> emit,
  ) async {
    _homeBloc.add(
      RemoveMissingIngredientFromSuggestedEvent(
        recipeId: event.recipeId,
        selectedIngredients: event.selectedIngredients,
      ),
    );
    final updatedRecipes = List<RecipeModel>.from(state.recipes ?? []);
    final updatedFavRecipes = List<RecipeModel>.from(
      state.favouriteRecipes ?? [],
    );

    int recipeIndex = -1;
    for (var i = 0; i < updatedRecipes.length; i++) {
      if (updatedRecipes[i].id == event.recipeId) {
        recipeIndex = i;
        break;
      }
    }

    int favRecipeIndex = -1;
    for (var i = 0; i < updatedFavRecipes.length; i++) {
      if (updatedFavRecipes[i].id == event.recipeId) {
        favRecipeIndex = i;
        break;
      }
    }
    int weeklyPlanIndex = -1;
    String? mealType;

    for (int i = 0; i < state.getAllWeeklyPlans.length; i++) {
      final weeklyPlan = state.getAllWeeklyPlans[i];

      final breakfast = weeklyPlan.breakfast;
      if (breakfast != null && breakfast.id == event.recipeId) {
        weeklyPlanIndex = i;
        mealType = 'breakfast';
        break;
      }

      final lunch = weeklyPlan.lunch;
      if (lunch != null && lunch.id == event.recipeId) {
        weeklyPlanIndex = i;
        mealType = 'lunch';
        break;
      }

      final dinner = weeklyPlan.dinner;
      if (dinner != null && dinner.id == event.recipeId) {
        weeklyPlanIndex = i;
        mealType = 'dinner';
        break;
      }
    }

    if (recipeIndex == -1 && favRecipeIndex == -1 && weeklyPlanIndex == -1) {
      log("Recipe not found: ${event.recipeId}");
      return;
    }

    final sourceList = favRecipeIndex != -1
        ? updatedFavRecipes
        : updatedRecipes;
    final sourceIndex = favRecipeIndex != -1 ? favRecipeIndex : recipeIndex;

    final updatedIngredients = List<IngredientEntity>.from(
      sourceList[sourceIndex].missingIngredients,
    );

    for (var item in event.selectedIngredients) {
      for (var i = 0; i < updatedIngredients.length; i++) {
        if (updatedIngredients[i].name == item.name) {
          updatedIngredients.removeAt(i);
          break;
        }
      }

      final r = sourceList[sourceIndex];
      sourceList[sourceIndex] = RecipeModel(
        id: r.id,
        mealplanId: r.mealplanId,
        title: r.title,
        calories: r.calories,
        cookingTime: r.cookingTime,
        recipeShortSummary: r.recipeShortSummary,
        cookingSteps: r.cookingSteps,
        missingItems: r.missingItems,
        available: r.available,
        mealType: r.mealType,
        formatedDateString: r.formatedDateString,
        thumbnail: r.thumbnail,
        missingIngredients: List.from(updatedIngredients),
        recipeId: r.recipeId,
        kitchenId: r.kitchenId,
        date: r.date,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        createdBy: r.createdBy,
        isCompleted: r.isCompleted,
        notes: r.notes,
        ingredients: r.ingredients,
        expiringItems: [],
        expiringItemsCount: r.expiringItemsCount,
        expiringItemsUsed: r.expiringItemsUsed,
      );

      if (favRecipeIndex != -1) {
        emit(state.copyWith(favouriteRecipes: List.from(updatedFavRecipes)));
      } else {
        emit(state.copyWith(recipes: List.from(updatedRecipes)));
      }
    }
  }

  Future<void> _onRemoveMissingIngredientFromPlanEvent(
    RemoveMissingIngredientFromPlanEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final updatedWeeklyPlans = state.getAllWeeklyPlans
        .map(
          (plan) => MergedRecipePlanEntity(
            date: plan.date,
            breakfast: _updateRecipe(
              plan.breakfast as RecipeModel?,
              event.selectedIngredients,
              event.recipeId,
            ),
            lunch: _updateRecipe(
              plan.lunch as RecipeModel?,
              event.selectedIngredients,
              event.recipeId,
            ),
            dinner: _updateRecipe(
              plan.dinner as RecipeModel?,
              event.selectedIngredients,
              event.recipeId,
            ),
          ),
        )
        .toList();

    emit(state.copyWith(getAllWeeklyPlans: updatedWeeklyPlans));
  }

  RecipeEntity? _updateRecipe(
    RecipeModel? recipe,
    List<IngredientEntity> selectedIngredients,
    String recipeId,
  ) {
    if (recipe == null || recipe.id != recipeId) return recipe;

    final updatedMissingIngredients = List<IngredientEntity>.from(
      recipe.missingIngredients,
    );

    for (var ingredient in selectedIngredients) {
      updatedMissingIngredients.removeWhere((i) => i.name == ingredient.name);
    }

    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      calories: recipe.calories,
      cookingTime: recipe.cookingTime,
      recipeShortSummary: recipe.recipeShortSummary,
      cookingSteps: recipe.cookingSteps,
      missingIngredients: updatedMissingIngredients,
      available: recipe.available,
      mealType: recipe.mealType,
      thumbnail: recipe.thumbnail,
      recipeId: recipe.recipeId,
      kitchenId: recipe.kitchenId,
      date: recipe.date,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      createdBy: recipe.createdBy,
      isCompleted: recipe.isCompleted,
      notes: recipe.notes,
      ingredients: recipe.ingredients,
      mealplanId: recipe.mealplanId,
      missingItems: recipe.missingItems,
      formatedDateString: recipe.formatedDateString,
      expiringItems: recipe.expiringItems,
      expiringItemsCount: recipe.expiringItemsCount,
      expiringItemsUsed: recipe.expiringItemsUsed,
    );
  }

  Future<void> _onRequestStartRecipe(
    RequestStartRecipeEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(state.copyWith(requestingStartRecipe: true));

    final hostQuery = await FirebaseFirestore.instance
        .collection('kitchens')
        .where("kitchen_id", isEqualTo: event.kitchenId)
        .get();

    if (hostQuery.docs.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Kitchen not found",
          requestingStartRecipe: false,
        ),
      );
      return;
    }

    final kitchenData = hostQuery.docs.first.data();
    log("kitchenId: ${kitchenData.toString()}");
    final hostUserId = kitchenData['user_id'].toString();
    final kitchenName = kitchenData['kitchen_name'] ?? '';
    final invitationCode = kitchenData['invitation_code'] ?? '';

    final hostDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(hostUserId)
        .get();

    if (!hostDoc.exists) {
      emit(
        state.copyWith(
          errorMessage: "Host not found",
          requestingStartRecipe: false,
        ),
      );
      return;
    }

    final hostDeviceToken = hostDoc.data()?['user_device_token'];

    if (hostDeviceToken == null || hostDeviceToken.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: "Host device token not found",
          requestingStartRecipe: false,
        ),
      );
      return;
    }

    final memberName =
        "${_userCubit.state.firstName} ${_userCubit.state.lastName}";

    final notificationData = {
      'status': false,
      'recipe_status': "Pending",
      'title': "Recipe Start Request",
      'body':
          "$memberName is requesting to start the recipe \"${event.recipeName}\" in the kitchen \"$kitchenName\".",
      'host_user_id': hostUserId,
      'sender_user_id': _userCubit.state.userId,
      'sender_name': memberName,
      'kitchen_id': event.kitchenId,
      'recipe_id': event.recipeId,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'read': false,

      'notification_type': 'start_recipe_request',
    };

    await FCMService().sendNotification(
      hostDeviceToken,
      "Recipe Start Request",
      "$memberName is requesting to start the recipe \"${event.recipeName}\" in the kitchen \"$kitchenName\".",
      invitationCode,
      kitchenName,
      "host",
      event.kitchenId,
      "start_recipe_request",
      event.recipeId,
    );

    await FirebaseFirestore.instance
        .collection('recipe_start_requests')
        .add(notificationData);

    AppToast.show("Request sent to host", ToastType.success);
    emit(state.copyWith(requestingStartRecipe: false));
  }
}
